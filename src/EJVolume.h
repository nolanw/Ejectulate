//
//  EJVolume.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/mount.h>


@interface EJVolume : NSObject
{
  NSString *name;
  NSImage *icon;
  NSMutableArray *children;
  NSString *BSDName;
  NSString *wholeDiskBSDName;
  NSString *path;
}

@property (readonly, copy) NSString *name;
@property (readonly, retain) NSImage *icon;
@property (retain) NSMutableArray *children;
@property (readonly, copy) NSString *BSDName;
@property (readonly, copy) NSString *wholeDiskBSDName;
@property (readonly, copy) NSString *path;

// Designated initializer.
- (id)initWithStatfs:(struct statfs *)stat;
+ (id)volumeWithStatfs:(struct statfs *)stat;

// Get some statfs for the volume at path, then pass along to designated 
// initializer.
- (id)initWithPath:(NSString *)aPath;
+ (id)volumeWithPath:(NSString *)path;

// Initialize whole disks that don't appear themselves in Finder.
- (id)initWholeDiskWithBSDName:(NSString *)aBSDName;
+ (id)wholeDiskVolumeWithBSDName:(NSString *)BSDName;

// Remove first child whose path is childPath, sending KVO notifications.
- (void)removeChildVolumeWithPath:(NSString *)childPath;

// Eject this volume and all child volumes.
- (void)eject;

@end
