//
//  NSIndexPath+NWHandy.m
//  NWHandy
//
//  Created by Nolan Waite on 11-02-10.
//  Copyright 2011 Nolan Waite. All rights reserved.
//

#import "NSIndexPath+NWHandy.h"


@implementation NSIndexPath (NWHandy)

- (NSUInteger)nw_lastIndex
{
  if ([self length] == 0)
    return NSNotFound;
  else
    return [self indexAtPosition:([self length] - 1)];
}

@end
