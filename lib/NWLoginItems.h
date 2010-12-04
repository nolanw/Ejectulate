//
//  NWLoginItems.h
//
//  Created by Nolan Waite on 09-12-04.
//  Copyright 2009 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// A Cocoa interface to Launch Services's Shared File List API for setting 
// login items.
@interface NWLoginItems : NSObject {}

// Adds |bundle| to the session login items (this user's login items).
// If |bundle| is nil, mainBundle is used.
// If |bundle| is already in the session login items, no changes are made.
+ (void)addBundleToSessionLoginItems:(NSBundle *)bundle;

// Removes |bundle| from the session login items.
// If |bundle| is nil, mainBundle is used.
// If |bundle| is not in the session login items, no changes are made.
+ (void)removeBundleFromSessionLoginItems:(NSBundle *)bundle;

// Returns YES if |bundle| is in the session login items; NO otherwise.
// If |bundle| is nil, mainBundle is used.
+ (BOOL)isBundleInSessionLoginItems:(NSBundle *)bundle;

@end
