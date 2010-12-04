//
//  EJEjectableVolumesWatcher.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-03.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EJEjectableVolumesWatcher.h"
#import "EJVolume.h"


@interface EJEjectableVolumesWatcher ()

- (NSMutableArray *)ejectableVolumes;
- (void)addVolume:(EJVolume *)newVolume;
- (void)removeVolumeWithPath:(NSString *)path;

- (void)setupNotifications;
- (void)diskDidMount:(NSNotification *)note;
- (void)diskDidUnmount:(NSNotification *)note;

@end


@implementation EJEjectableVolumesWatcher

@synthesize volumes;

#if 0
#pragma mark -
#pragma mark Init/dealloc
#endif

- (id)init
{
  if ((self = [super init]))
  {
    volumes = [[self ejectableVolumes] retain];
    [self setupNotifications];
  }
  return self;
}

#if 0
#pragma mark -
#pragma mark API
#endif

- (NSMutableArray *)ejectableVolumes
{
  // Build list of volumes using getmntinfo(). Each volume that's mounted under 
  // /Volumes gets added.
  // To determine which volumes are simply partitions on the same disk, each 
  // volume determines its "whole disk" (the entire disk, as opposed to just 
  // one partition). If two or more volumes have the same whole disk, they are 
  // on the same disk, and we then make a whole disk volume to group those 
  // child volumes. Some volumes may not have a whole disk, which typically 
  // means they already are the whole disk.
  NSMutableArray *volumesTemp = [NSMutableArray array];
  NSCountedSet *wholeDiskCount = [NSCountedSet set];
  struct statfs *buf;
  int count = getmntinfo(&buf, 0);
  for (int i = 0; i < count; i++)
  {
    EJVolume *volume = [EJVolume volumeWithStatfs:&buf[i]];
    if (!volume)
      continue;
    [volumesTemp addObject:volume];
    if (volume.wholeDiskBSDName)
      [wholeDiskCount addObject:volume.wholeDiskBSDName];
  }
  NSMutableArray *wholeDisks = [NSMutableArray array];
  for (EJVolume *volume in volumesTemp)
  {
    if (!volume.wholeDiskBSDName || 
        [wholeDiskCount countForObject:volume.wholeDiskBSDName] == 1)
      [wholeDisks addObject:volume];
  }
  for (NSString *BSDName in wholeDiskCount)
  {
    if ([wholeDiskCount countForObject:BSDName] < 2)
      continue;
    EJVolume *wholeDisk = [EJVolume wholeDiskVolumeWithBSDName:BSDName];
    if (!wholeDisk)
    {
      NSLog(@"%@ failed creating whole disk for BSDName %@", 
            NSStringFromSelector(_cmd), BSDName);
      continue;
    }
    NSMutableArray *children = [NSMutableArray array];
    for (EJVolume *volume in volumesTemp)
    {
      if ([volume.wholeDiskBSDName isEqual:BSDName])
        [children addObject:volume];
    }
    wholeDisk.children = children;
    [wholeDisks addObject:wholeDisk];
  }
  return wholeDisks;
}

- (void)addVolume:(EJVolume *)newVolume
{
  EJVolume *sharesWholeDisk = nil;
  for (EJVolume *volume in self.volumes)
  {
    if ([volume.BSDName isEqual:newVolume.wholeDiskBSDName])
    {
      [[volume mutableArrayValueForKey:@"children"] addObject:volume];
      return;
    }
    if ([volume.wholeDiskBSDName isEqual:newVolume.wholeDiskBSDName])
    {
      sharesWholeDisk = volume;
      break;
    }
  }
  NSMutableArray *kvoVolumes = [self mutableArrayValueForKey:@"volumes"];
  if (sharesWholeDisk)
  {
    NSString *BSDName = sharesWholeDisk.wholeDiskBSDName;
    EJVolume *newWhole = [EJVolume wholeDiskVolumeWithBSDName:BSDName];
    newWhole.children = $marray(sharesWholeDisk, newVolume);
    NSUInteger index = [kvoVolumes indexOfObject:sharesWholeDisk];
    [kvoVolumes replaceObjectAtIndex:index withObject:newWhole];
  }
  else
    [kvoVolumes addObject:newVolume];
}

- (void)removeVolumeWithPath:(NSString *)path
{
  EJVolume *wholeWithSingleChild = nil;
  for (EJVolume *volume in [[self.volumes copy] autorelease])
  {
    if ([volume.path isEqual:path])
      [[self mutableArrayValueForKey:@"volumes"] removeObject:volume];
    else
    {
      [volume removeChildVolumeWithPath:path];
      if ([volume.children count] == 1)
        wholeWithSingleChild = volume;
    }
  }
  if (wholeWithSingleChild)
  {
    EJVolume *newlyWhole = [wholeWithSingleChild.children lastObject];
    NSMutableArray *kvoVolumes = [self mutableArrayValueForKey:@"volumes"];
    NSUInteger index = [kvoVolumes indexOfObject:wholeWithSingleChild];
    [kvoVolumes replaceObjectAtIndex:index withObject:newlyWhole];
  }
}

- (void)setupNotifications
{
  NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
  NSNotificationCenter *noteCenter = [workspace notificationCenter];
  [noteCenter addObserver:self
                 selector:@selector(diskDidMount:)
                     name:NSWorkspaceDidMountNotification
                   object:nil];
  [noteCenter addObserver:self
                 selector:@selector(diskDidUnmount:)
                     name:NSWorkspaceDidUnmountNotification
                   object:nil];
}

- (void)diskDidMount:(NSNotification *)note
{
  NSString *path = [[note userInfo] objectForKey:@"NSDevicePath"];
  EJVolume *newlyMounted = [EJVolume volumeWithPath:path];
  [self addVolume:newlyMounted];
}

- (void)diskDidUnmount:(NSNotification *)note
{
  NSString *path = [[note userInfo] objectForKey:@"NSDevicePath"];
  [self removeVolumeWithPath:path];
}

@end
