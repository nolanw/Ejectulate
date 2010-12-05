//
//  EJVolume.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//


// HUGE thanks to Kevin Wojniak (I think he's at http://www.kainjow.com/) for 
// guiding much of this code via his app Semulov 
// (http://code.google.com/p/semulov/). It would've taken me forever to figure 
// out how to unmount network drives otherwise.


#import <Foundation/Foundation.h>
#include <sys/mount.h>


// A single mounted volume that can be ejected, or a single whole disk that has 
// multiple mounted child volumes that can eject all of them. Note that there 
// are two designated initializers.
@interface EJVolume : NSObject
{
  NSString *name;
  NSImage *icon;
  NSMutableArray *children;
  NSString *BSDName;
  NSString *wholeDiskBSDName;
  NSString *path;
  BOOL local;
}

// The display name of this volume.
@property (readonly, copy, nonatomic) NSString *name;

// The icon that represents this volume in Finder and/or Disk Utility.
@property (readonly, retain, nonatomic) NSImage *icon;

// If this volume is a parent, these are its children. KVO-compliant.
@property (retain, nonatomic) NSMutableArray *children;

// The BSD name for this mounted volume (e.g. "disk1s2").
@property (readonly, copy, nonatomic) NSString *BSDName;

// If this disk has a whole disk, this is its BSD name (e.g. "disk1"). Used to 
// determine whether a parent volume should be made and which is the parent.
@property (readonly, copy, nonatomic) NSString *wholeDiskBSDName;

// The mounted path in the filesystem for this volume.
@property (readonly, copy, nonatomic) NSString *path;

// YES if this volume is considered local, or NO if it's over the network.
@property (readonly, getter=isLocal, assign, nonatomic) BOOL local;

// Designated initializer and a convenience method for it. Returns nil if 
// the volume indicated by stat is not mounted under /Volumes, or if some 
// essential information gathering fails.
- (id)initWithStatfs:(struct statfs *)stat;
+ (id)volumeWithStatfs:(struct statfs *)stat;

// Designated initializer for whole disks that don't appear in Finder, but will 
// get you yelled at if you eject one of its children. Also a convenience for 
// said initializer.
- (id)initWholeDiskWithBSDName:(NSString *)aBSDName;
+ (id)wholeDiskVolumeWithBSDName:(NSString *)BSDName;

// Get some statfs for the volume at path, then pass along to designated 
// initializer, and a convenience method for it.
- (id)initWithPath:(NSString *)aPath;
+ (id)volumeWithPath:(NSString *)path;

// Remove first child whose path is childPath, sending KVO notifications.
- (void)removeChildVolumeWithPath:(NSString *)childPath;

// Attempt to eject this volume and all child volumes. Listen to NSWorkspace 
// notifications to learn of your success.
- (void)eject:(id)sender;

@end
