//
//  EjectulateWindowController.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EjectulateWindowController.h"
#import "EJOutlineView.h"
#import "EJVolume.h"
#import "ImageAndTextCell.h"
#import "CollectionUtils.h"


@interface EjectulateWindowController ()

@property (retain) NSMutableArray *volumes;

- (void)sizeWindowToFit;
- (void)diskDidMount:(NSNotification *)note;
- (void)diskDidUnmount:(NSNotification *)note;
- (void)addVolume:(EJVolume *)newVolume;
- (void)removeVolumeWithPath:(NSString *)path;
- (void)buildVolumesList;
- (void)applicationWillTerminate:(NSNotification *)note;

@end


@implementation EjectulateWindowController

@synthesize tree;
@synthesize outline;
@synthesize volumes;
@dynamic tabViewIndex;

- (NSInteger)tabViewIndex
{
  return [self.volumes count] ? 1 : 0;
}

+ (NSSet *)keyPathsForValuesAffectingTabViewIndex
{
  return $set(@"volumes.@count");
}

#if 0
#pragma mark -
#pragma mark API
#endif

- (void)sizeWindowToFit
{
  NSRect frame = [self.window frame];
  NSRect contentRect = [self.window contentRectForFrameRect:frame];
  CGFloat oldHeight = contentRect.size.height;
  NSUInteger count = MAX(1, [[self.tree arrangedObjects] count]);
  contentRect.size.height = ([self.outline rowHeight] + 1.0) * count - 1.0;
  CGFloat heightChange = contentRect.size.height - oldHeight;
  frame = [self.window frameRectForContentRect:contentRect];
  frame.origin.y -= heightChange;
  [self.window setFrame:frame display:YES];
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
    [kvoVolumes removeObject:sharesWholeDisk];
    [kvoVolumes addObject:newWhole];
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
      for (EJVolume *child in [[volume.children copy] autorelease])
      {
        if ([child.path isEqual:path])
        {
          [[volume mutableArrayValueForKey:@"children"] removeObject:child];
          if ([volume.children count] == 1)
            wholeWithSingleChild = volume;
        }
      }
    }
  }
  if (wholeWithSingleChild)
  {
    EJVolume *newlyWhole = [wholeWithSingleChild.children lastObject];
    NSMutableArray *kvoVolumes = [self mutableArrayValueForKey:@"volumes"];
    [kvoVolumes removeObject:wholeWithSingleChild];
    [kvoVolumes addObject:newlyWhole];
  }
}

- (void)buildVolumesList
{
  // Build list of volumes using getmntinfo(). Each volume that's mounted under 
  // /Volumes gets passed along.
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
    if ([wholeDiskCount countForObject:BSDName] > 1)
    {
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
  }
  self.volumes = wholeDisks;
}

- (void)applicationWillTerminate:(NSNotification *)note
{
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#if 0
#pragma mark -
#pragma mark NSWindowController
#endif

- (void)windowWillLoad
{
  [self buildVolumesList];
  NSDictionary *notes = $dict(
    NSWorkspaceDidMountNotification, @"diskDidMount:", 
    NSWorkspaceDidUnmountNotification, @"diskDidUnmount:");
  NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
  NSNotificationCenter *noteCenter = [workspace notificationCenter];
  for (NSString *noteName in notes)
  {
    [noteCenter addObserver:self
                   selector:NSSelectorFromString([notes objectForKey:noteName])
                       name:noteName
                     object:nil];
  }
  noteCenter = [NSNotificationCenter defaultCenter];
  [noteCenter addObserver:self
                 selector:@selector(applicationWillTerminate:)
                     name:NSApplicationWillTerminateNotification
                   object:nil];
}

- (void)windowDidLoad
{
  [self.outline expandItem:nil expandChildren:YES];
}

#if 0
#pragma mark -
#pragma mark EJOutlineViewDelegate
#endif

- (void)ej_outlineViewDidPressReturnOrEnter:(EJOutlineView *)anOutlineView
{
  [[[self.tree selectedObjects] lastObject] eject];
}

#if 0
#pragma mark -
#pragma mark NSOutlineViewDelegate
#endif

- (void)outlineView:(NSOutlineView*)anOutlineView
    willDisplayCell:(ImageAndTextCell*)cell
     forTableColumn:(NSTableColumn*)tableColumn
               item:(id)item
{
  [cell setImage:[[item representedObject] valueForKey:@"icon"]];
}

@end
