//
//  NSSortDescriptor+NWHandy.h
//  NWHandy
//
//  Created by Nolan Waite on 11-02-09.
//  Copyright 2011 Nolan Waite. All rights reserved.
//

#import <Foundation/Foundation.h>

#define nw_sort(KEY) \
  [[[NSSortDescriptor alloc] initWithKey:[KEY substringFromIndex:1] \
                               ascending:([[KEY substringToIndex:1] \
                                           isEqual:@"+"])] autorelease]
