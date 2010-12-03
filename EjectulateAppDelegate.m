//
//  EjectulateAppDelegate.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EjectulateAppDelegate.h"
#include <sys/mount.h>
#import <DiskArbitration/DiskArbitration.h>
#import "EJVolume.h"
#import "ImageAndTextCell.h"


@interface EjectulateAppDelegate ()

- (void)diskDidMount:(NSNotification *)note;
- (void)diskDidUnmount:(NSNotification *)note;

- (void)sizeWindowToFit;

@end

@implementation EjectulateAppDelegate

#if 0
#pragma mark -
#pragma mark Properties
#endif

@synthesize window;
@synthesize volumes;
@synthesize outlineView;

- (void)insertObject:(EJVolume *)volume inVolumesAtIndex:(NSUInteger)index
{
  [volumes insertObject:volume atIndex:index];
}

- (void)removeObjectFromVolumesAtIndex:(NSUInteger)index
{
  [volumes removeObjectAtIndex:index];
}

#if 0
#pragma mark -
#pragma mark API
#endif

- (void)diskDidMount:(NSNotification *)note
{
  NSString *path = [[note userInfo] objectForKey:@"NSDevicePath"];
  EJVolume *volume = [EJVolume volumeWithPath:path];
  NSMutableArray *root = [self mutableArrayValueForKey:@"volumes"];
  if (!volume.wholeDiskBSDName)
  {
    [root addObject:volume];
    goto done;
  } 
  for (EJVolume *rootVolume in root)
  {
    if ([rootVolume.BSDName isEqual:volume.wholeDiskBSDName])
    {
      [[rootVolume mutableArrayValueForKey:@"children"] addObject:volume];
      goto done;
    }
  }
  EJVolume *sharesWholeDisk = nil;
  for (EJVolume *rootVolume in root)
  {
    if ([rootVolume.wholeDiskBSDName isEqual:volume.wholeDiskBSDName])
    {
      sharesWholeDisk = rootVolume;
      break;
    }
  }
  if (sharesWholeDisk)
  {
    [root removeObject:sharesWholeDisk];
    EJVolume *newWhole = [EJVolume wholeDiskVolumeWithBSDName:
                                                       volume.wholeDiskBSDName];
    newWhole.children = [NSMutableArray arrayWithObjects:volume, 
                         sharesWholeDisk, nil];
    [root addObject:newWhole];
  }
  else
    [root addObject:volume];
 done:
  [self sizeWindowToFit];
}

- (void)diskDidUnmount:(NSNotification *)note
{
  NSString *path = [[note userInfo] objectForKey:@"NSDevicePath"];
  NSMutableArray *root = [self mutableArrayValueForKey:@"volumes"];
  for (EJVolume *volume in root)
  {
    if ([volume.path isEqual:path])
    {
      [root removeObject:volume];
      goto done;
    }
  }
  for (EJVolume *volume in volumes)
  {
    NSMutableArray *children = [volume mutableArrayValueForKey:@"children"];
    for (EJVolume *child in children)
    {
      if ([child.path isEqual:path])
      {
        [children removeObject:child];
        goto done;
      }
    }
  }
  
 done:
  [self sizeWindowToFit];
}

- (void)sizeWindowToFit
{
  NSRect contentRect = [self.window contentRectForFrameRect:[self.window frame]];
  CGFloat oldHeight = contentRect.size.height;
  NSUInteger count = MAX(1, [self.volumes count]);
  contentRect.size.height = ([self.outlineView rowHeight] + 1) * count;
  if (count == 1)
    contentRect.size.height -= 1.0;
  CGFloat heightChange = contentRect.size.height - oldHeight;
  NSRect frame = [self.window frameRectForContentRect:contentRect];
  frame.origin.y -= heightChange;
  [self.window setFrame:frame display:YES];
}

#if 0
#pragma mark -
#pragma mark NSNibAwakening
#endif

- (void)awakeFromNib
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

#if 0
#pragma mark -
#pragma mark NSApplicationDelegate
#endif

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
  return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)note
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
  [self sizeWindowToFit];
  [self.window makeKeyAndOrderFront:self];
}

- (void)applicationWillTerminate:(NSNotification *)note
{
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

#if 0
#pragma mark -
#pragma mark EJOutlineViewDelegate
#endif

- (void)ej_outlineViewDidPressReturnOrEnter:(EJOutlineView *)anOutlineView
{
  NSTreeNode *node = [anOutlineView itemAtRow:[anOutlineView selectedRow]];
  EJVolume *volume = [node representedObject];
  [volume eject];
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
