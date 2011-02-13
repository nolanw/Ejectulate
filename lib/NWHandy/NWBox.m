//
//  NWBox.m
//  NWHandy
//
//  Created by Nolan Waite on 10-12-27.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWBox.h"


id _nw_box(const void *value, const char *encoding)
{
  char e = encoding[0];
  if (e == 'r')
    e = encoding[1]; // Ignore const
  switch (e)
  {
    case 'c': return [NSNumber numberWithChar:*(char *)value];
    case 'C': return [NSNumber numberWithUnsignedChar:*(char *)value];
    case 's': return [NSNumber numberWithShort:*(short *)value];
    case 'S': {
      unsigned short *us_value = (unsigned short *)value;
      return [NSNumber numberWithUnsignedShort:*us_value];
    }
    case 'i': return [NSNumber numberWithInt:*(int *)value];
    case 'I': return [NSNumber numberWithUnsignedInt:*(unsigned int *)value];
    case 'l': return [NSNumber numberWithLong:*(long *)value];
    case 'L': return [NSNumber numberWithUnsignedLong:*(unsigned long *)value];
    case 'q': return [NSNumber numberWithLongLong:*(long long *)value];
    case 'Q': {
      unsigned long long *ull_value = (unsigned long long *)value;
      return [NSNumber numberWithUnsignedLongLong:*ull_value];
    }
    case 'f': return [NSNumber numberWithFloat:*(float *)value];
    case 'd': return [NSNumber numberWithDouble:*(double *)value];
    case '*': return [NSString stringWithUTF8String:*(char **)value];
    default: return [NSValue value:value withObjCType:encoding];
  }
}
