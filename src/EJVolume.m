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

@property (copy) NSString *name;
@property (retain) NSImage *icon;
@property (copy) NSString *BSDName;
@property (copy) NSString *wholeDiskBSDName;
@property (copy) NSString *path;

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
#pragma mark Init/dealloc
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
                                  kDADiskDescriptionMediaWholeKey,
                                  (void *)&isWhole);
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
      if ([(NSDictionary *)mediaIcon objectForKey:@"IOBundleResourceFile"])
      {
        NSString *identifier = [(NSDictionary *)mediaIcon objectForKey:
                                                         @"CFBundleIdentifier"];
        NSBundle *bundle = [NSBundle bundleWithIdentifier:identifier];
        if (bundle)
        {
          NSString *resource = [(NSDictionary *)mediaIcon objectForKey:
                                                      @"IOBundleResourceFile"];
          NSURL *iconURL = [bundle URLForResource:resource withExtension:nil];
          if (iconURL)
            icon = [[NSImage alloc] initWithContentsOfURL:iconURL];
        }
      }
    }
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

- (void)dealloc
{
  [path release], path = nil;
  [wholeDiskBSDName release], wholeDiskBSDName = nil;
  [BSDName release], BSDName = nil;
  [children release], children = nil;
  [icon release], icon = nil;
  [name release], name = nil;
  
  [super dealloc];
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

static void UnmountCallback(DADiskRef disk, DADissenterRef dissenter, void *context)
{
  if (dissenter != NULL)
  {
    DADiskEject(disk, kDADiskUnmountOptionDefault, NULL, NULL);
  }
}

- (void)eject
{
  if (self.children && [self.children count])
  {
    [self.children makeObjectsPerformSelector:@selector(eject)];
    return;
  }
  DASessionRef session = DASessionCreate(NULL);
  if (!session)
    return;
  DADiskRef disk = DADiskCreateFromBSDName(NULL, 
                                           session, 
                                           [self.BSDName UTF8String]);
  if (disk)
  {
    DADiskUnmount(disk, kDADiskUnmountOptionDefault, UnmountCallback, NULL);
    CFRelease(disk);
  }
  CFRelease(session);
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
