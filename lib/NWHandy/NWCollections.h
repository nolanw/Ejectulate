//
//  NWCollections.h
//  NWHandy
//
//  Created by Nolan Waite on 10-12-31.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Foundation/Foundation.h>


// Generic empty function. Works for anything with a length or count method.
// Returns YES if collection is empty, NO otherwise.
static inline BOOL nw_isempty(id collection)
{
  if (collection == nil)
    return YES;
  else if ([collection respondsToSelector:@selector(length)])
    return ([collection length] == 0);
  else if ([collection respondsToSelector:@selector(count)])
    return ([collection count] == 0);
  else
    return NO;
}
