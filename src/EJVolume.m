//
//  EJVolume.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EJVolume.h"
#include <sys/mount.h>
#import <DiskArbitration/DiskArbitration.h>
#include <errno.h>


@interface EJVolume ()

@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) NSImage *icon;
@property (copy, nonatomic) NSString *BSDName;
@property (copy, nonatomic) NSString *wholeDiskBSDName;
@property (copy, nonatomic) NSString *path;
@property (assign, getter=isLocal, nonatomic) BOOL local;

// Attempt to eject this volume if it's local.
- (void)ejectLocal;

// Attempt to eject this volume if it's on a network.
- (void)ejectNetwork;

@end


@implementation EJVolume

#if 0
#pragma mark -
#pragma mark Properties
#endif

@synthesize name;
@synthesize icon;
@synthesize children;
@synthesize BSDName;
@synthesize wholeDiskBSDName;
@synthesize path;
@synthesize local;

#if 0
#pragma mark -
#pragma mark KVO-compliance
#endif

- (void)insertObject:(EJVolume *)volume inChildrenAtIndex:(NSUInteger)index
{
  [children insertObject:volume atIndex:index];
}

- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index
{
  [children removeObjectAtIndex:index];
}

#if 0
#pragma mark -
#pragma mark Init
#endif

- (id)initWithStatfs:(struct statfs *)stat
{
  DASessionRef session = NULL;
  DADiskRef disk = NULL;
  
  if ((self = [super init]))
  {
    path = [[NSString alloc] initWithUTF8String:stat->f_mntonname];
    if (![path hasPrefix:@"/Volumes/"])
      goto bail;
    name = [[[NSFileManager defaultManager] displayNameAtPath:path] copy];
    icon = [[[NSWorkspace sharedWorkspace] iconForFile:path] retain];
    if (!(stat->f_flags & MNT_LOCAL))
      return self;
    local = YES;
    session = DASessionCreate(NULL);
    if (!session)
      goto bail;
    disk = DADiskCreateFromBSDName(NULL, session, stat->f_mntfromname);
    if (!disk)
      goto bail;
    CFDictionaryRef diskDescription = DADiskCopyDescription(disk);
    if (!diskDescription)
      goto bail;
    CFBooleanRef isWhole;
    CFDictionaryGetValueIfPresent(diskDescription, 
                             kDADiskDescriptionMediaWholeKey, (void *)&isWhole);
    if (isWhole == kCFBooleanFalse)
    {
      DADiskRef wholeDisk = DADiskCopyWholeDisk(disk);
      wholeDiskBSDName = [[NSString alloc] initWithUTF8String:
                                                  DADiskGetBSDName(wholeDisk)];
      CFRelease(wholeDisk);
    }
    BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(disk)];
    CFRelease(diskDescription);
    CFRelease(disk);
    CFRelease(session);
  }
  return self;
  
 bail:
  if (disk)
    CFRelease(disk);
  if (session)
    CFRelease(session);
  [self release];
  return nil;
}

+ (id)volumeWithStatfs:(struct statfs *)stat
{
  return [[[self alloc] initWithStatfs:stat] autorelease];
}

- (id)initWholeDiskWithBSDName:(NSString *)aBSDName
{
  DASessionRef session = NULL;
  DADiskRef disk = NULL;
  if ((self = [super init]))
  {
    session = DASessionCreate(NULL);
    if (!session)
      goto bail;
    disk = DADiskCreateFromBSDName(NULL, session, [aBSDName UTF8String]);
    if (!disk)
      goto bail;
    CFDictionaryRef diskDescription = DADiskCopyDescription(disk);
    if (!diskDescription)
      goto bail;
    CFStringRef mediaName;
    CFDictionaryGetValueIfPresent(diskDescription, 
                                  kDADiskDescriptionMediaNameKey,
                                  (void *)&mediaName);
    name = [[NSString alloc] initWithString:(NSString *)mediaName];
    CFDictionaryRef mediaIcon;
    CFDictionaryGetValueIfPresent(diskDescription, 
                                  kDADiskDescriptionMediaIconKey,
                                  (void *)&mediaIcon);
    if (mediaIcon)
    {
      NSDictionary *iconDict = (NSDictionary *)mediaIcon;
      if ([iconDict objectForKey:@"IOBundleResourceFile"])
      {
        NSString *identifier = [iconDict objectForKey:@"CFBundleIdentifier"];
        NSBundle *bundle = [NSBundle bundleWithIdentifier:identifier];
        if (bundle)
        {
          NSString *resource = [iconDict objectForKey:@"IOBundleResourceFile"];
          NSURL *iconURL = [bundle URLForResource:resource withExtension:nil];
          if (iconURL)
            icon = [[NSImage alloc] initWithContentsOfURL:iconURL];
        }
      }
    }
    CFRelease(diskDescription);
    CFRelease(disk);
    CFRelease(session);
    BSDName = [aBSDName copy];
  }
  return self;
  
 bail:
  if (disk)
    CFRelease(disk);
  if (session)
    CFRelease(session);
  [self release];
  return nil;
}

+ (id)wholeDiskVolumeWithBSDName:(NSString *)BSDName
{
  return [[[self alloc] initWholeDiskWithBSDName:BSDName] autorelease];
}

- (id)initWithPath:(NSString *)aPath
{
  struct statfs stat;
  statfs([aPath UTF8String], &stat);
  return [self initWithStatfs:&stat];
}

+ (id)volumeWithPath:(NSString *)path
{
  return [[[self alloc] initWithPath:path] autorelease];
}

#if 0
#pragma mark -
#pragma mark API
#endif

- (void)removeChildVolumeWithPath:(NSString *)childPath
{
  for (EJVolume *child in [[self.children copy] autorelease])
  {
    if ([child.path isEqual:childPath])
    {
      [[self mutableArrayValueForKey:@"children"] removeObject:child];
      break;
    }
  }
}

static void EjectImmediatelyOnUnmountCallback(DADiskRef disk, 
                                              DADissenterRef dissenter, 
                                              void *context)
{
  if (!dissenter)
    DADiskEject(disk, kDADiskUnmountOptionDefault, NULL, NULL);
}

- (void)eject:(id)sender
{
  if (self.children && [self.children count])
  {
    [self.children makeObjectsPerformSelector:@selector(eject:)
                                   withObject:self];
  }
  else
    self.local ? [self ejectLocal] : [self ejectNetwork];
}

- (void)ejectLocal
{
  if (!self.local)
    return;
  DASessionRef session = DASessionCreate(NULL);
  DADiskRef disk = DADiskCreateFromBSDName(NULL, session, 
                                                     [self.BSDName UTF8String]);
  if (disk)
  {
    DADiskUnmount(disk, kDADiskUnmountOptionDefault, 
                                       EjectImmediatelyOnUnmountCallback, NULL);
    CFRelease(disk);
  }
  CFRelease(session);
}

static void DisposeCallback(FSVolumeOperation volumeOp,
                            void *clientData,
                            OSStatus err,
                            FSVolumeRefNum mountedVolumeRefNum,
                            pid_t dissenter)
{
  FSDisposeVolumeOperation(volumeOp);
}

- (void)ejectNetwork
{
  if (self.local)
    return;
  FSRef ref;
  OSErr err;
  err = FSPathMakeRef((const UInt8 *)[self.path fileSystemRepresentation], 
                                                                    &ref, NULL);
  if (err != noErr)
    return;
  FSCatalogInfo catalogInfo;
  err = FSGetCatalogInfo(&ref, kFSCatInfoVolume, &catalogInfo, NULL, NULL, 
                                                                        NULL);
  if (err != noErr)
    return;
  FSVolumeOperation volumeOp;
  err = FSCreateVolumeOperation(&volumeOp);
  if (err != noErr)
    return;
  err = FSUnmountVolumeAsync(catalogInfo.volume, 0, volumeOp, NULL, 
                 DisposeCallback, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
  if (err != noErr)
    FSDisposeVolumeOperation(volumeOp);
}

#if 0
#pragma mark -
#pragma mark NSObject
#endif

- (NSString *)description
{
  return [NSString stringWithFormat:@"<%@ %p name='%@' BSDName=%@", 
                NSStringFromClass([self class]), self, self.name, self.BSDName];
}

@end
