//
//  EJEjectableVolumesWatcher.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-03.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Creates and maintains a list of ejectable volumes (instances of EJVolume)
// Key-Value Observing compliant.
@interface EJEjectableVolumesWatcher : NSObject
{
  NSMutableArray *volumes;
}

// An up-to-date list of ejectable volumes. KVO-compliant.
@property (readonly, retain, nonatomic) NSMutableArray *volumes;

@end
