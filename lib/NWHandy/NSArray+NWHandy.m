//
//  NSArray+NWHandy.m
//  NWHandy
//
//  Created by Nolan Waite on 10-12-12.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "NSArray+NWHandy.h"


@implementation NSArray (NWHandy)

- (id)nw_firstObject
{
  return ([self count] > 0 ? [self objectAtIndex:0] : nil);
}

@end
