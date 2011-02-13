//
//  NSDictionary+NWHandy.m
//  NWHandy
//
//  Created by Nolan Waite on 10-12-12.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "NSDictionary+NWHandy.h"


@implementation NSDictionary (NWHandy)

+ (id)nw_dictionaryWithKeysAndObjects:(id*)keysAndObjects
                                count:(NSUInteger)count
{
  NSAssert((count % 2 == 0), @"unmatched keys and values");
  
  NSMutableArray *keys = [NSMutableArray array];
  NSMutableArray *objects = [NSMutableArray array];
  for (NSUInteger i = 0; i < count; i += 2)
  {
    [keys addObject:keysAndObjects[i]];
    [objects addObject:keysAndObjects[i + 1]];
  }
  return [self dictionaryWithObjects:objects forKeys:keys];
}

@end
