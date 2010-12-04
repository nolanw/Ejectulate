//
//  EJEjectableVolumesWatcher.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-03.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Creates and maintains a list of ejectable volumes.
@interface EJEjectableVolumesWatcher : NSObject
{
  NSMutableArray *volumes;
}

// The volumes property is fully KVO-compliant.
@property (readonly, retain) NSMutableArray *volumes;

@end
