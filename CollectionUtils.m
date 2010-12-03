//
//  CollectionUtils.m
//  MYUtilities
//
//  Created by Jens Alfke on 1/5/08.
//  Copyright 2008 Jens Alfke. All rights reserved.
//

#import "CollectionUtils.h"


NSDictionary* _dictof(const struct _dictpair* pairs, 
                      size_t count, 
                      BOOL mutable)
{
  id objects[count], keys[count];
  size_t n = 0;
  for(size_t i = 0; i < count; i++, pairs++)
  {
    if (!pairs->value)
      continue;
    objects[n] = pairs->value;
    keys[n] = pairs->key;
    n++;
  }
  if (mutable)
    return [NSMutableDictionary dictionaryWithObjects:objects
                                              forKeys:keys
                                                count:n];
  else
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys count:n];
}


NSArray* $apply(NSArray *src, SEL selector, id defaultValue)
{
  NSMutableArray *dst = [NSMutableArray arrayWithCapacity:[src count]];
  for(id obj in src)
  {
    id result = [obj performSelector:selector] ?: defaultValue;
    [dst addObject:result];
  }
  return dst;
}

NSArray* $applyKeyPath(NSArray *src, NSString *keyPath, id defaultValue)
{
  NSMutableArray *dst = [NSMutableArray arrayWithCapacity:[src count]];
  for(id obj in src)
  {
    id result = [obj valueForKeyPath:keyPath] ?: defaultValue;
    [dst addObject:result];
  }
  return dst;
}


// Like -isEqual: but works even if either/both are nil
BOOL $equal(id obj1, id obj2)
{
  if (obj1)
    return obj2 && [obj1 isEqual:obj2];
  else
    return obj2 == nil;
}


NSValue* _box(const void *value, const char *encoding)
{
  // file:///Developer/Documentation/DocSets/
  // com.apple.ADC_Reference_Library.DeveloperTools.docset/Contents/
  // Resources/Documents/documentation/DeveloperTools/gcc-4.0.1/gcc/
  // Type-encoding.html
  char e = encoding[0];
  if(e == 'r') // ignore 'const' modifier
    e = encoding[1];
  switch (e)
  {
    case 'c': return [NSNumber numberWithChar:*(char*)value];
    case 'C': return [NSNumber numberWithUnsignedChar:*(char*)value];
    case 's': return [NSNumber numberWithShort:*(short*)value];
    case 'S': 
      return [NSNumber numberWithUnsignedShort:*(unsigned short*)value];
    case 'i': return [NSNumber numberWithInt:*(int*)value];
    case 'I': return [NSNumber numberWithUnsignedInt:*(unsigned int*)value];
    case 'l': return [NSNumber numberWithLong:*(long*)value];
    case 'L': 
      return [NSNumber numberWithUnsignedLong:*(unsigned long*)value];
    case 'q': return [NSNumber numberWithLongLong:*(long long*)value];
    case 'Q': {
      unsigned long long *longlong_value = (unsigned long long*)value;
      return [NSNumber numberWithUnsignedLongLong:*longlong_value];
    }
    case 'f': return [NSNumber numberWithFloat:*(float*)value];
    case 'd': return [NSNumber numberWithDouble:*(double*)value];
    case '*': return [NSString stringWithUTF8String:*(char**)value];
    case '@': return *(id*)value;
    default:  return [NSValue value:value withObjCType:encoding];
  }
}


id _cast(Class requiredClass, id object)
{
  if(object && ![object isKindOfClass:requiredClass])
    [NSException raise:NSInvalidArgumentException
                format:@"%@ required, but got %@ %p",
                requiredClass, [object class], object];
  return object;
}

id _castNotNil(Class requiredClass, id object)
{
  if(![object isKindOfClass:requiredClass])
    [NSException raise:NSInvalidArgumentException
                format:@"%@ required, but got %@ %p",
                requiredClass, [object class], object];
  return object;
}

id _castIf(Class requiredClass, id object)
{
  if(object && ![object isKindOfClass:requiredClass])
    object = nil;
  return object;
}

NSArray* _castArrayOf(Class itemClass, NSArray *a)
{
  id item;
  for (item in $cast(NSArray,a))
    _cast(itemClass,item);
  return a;
}


void setObj(id *var, id value)
{
  if(value == *var)
    return;
  [*var release];
  *var = [value retain];
}

BOOL ifSetObj(id *var, id value)
{
  if(value != *var && ![value isEqual:*var])
  {
    [*var release];
    *var = [value retain];
    return YES;
  } 
  else 
  {
    return NO;
  }
}

void setObjCopy(id *var, id valueToCopy)
{
  if(valueToCopy == *var)
    return;
  [*var release];
  *var = [valueToCopy copy];
}

BOOL ifSetObjCopy(id *var, id value)
{
  if(value != *var && ![value isEqual:*var])
  {
    [*var release];
    *var = [value copy];
    return YES;
  } 
  else 
  {
    return NO;
  }
}


NSString* $string(const char *utf8Str)
{
  if(utf8Str)
    return [NSString stringWithCString:utf8Str encoding:NSUTF8StringEncoding];
  else
    return nil;
}


BOOL kvSetSet(id owner, NSString *property, NSMutableSet *set, NSSet *newSet)
{
  if (!newSet)
      newSet = [NSSet set];
  if (![set isEqualToSet:newSet])
  {
    [owner willChangeValueForKey:property
                 withSetMutation:NSKeyValueSetSetMutation 
                    usingObjects:newSet]; 
    [set setSet: newSet];
    [owner didChangeValueForKey:property 
                withSetMutation:NSKeyValueSetSetMutation 
                   usingObjects:newSet]; 
    return YES;
  } 
  else
  {
    return NO;
  }
}


BOOL kvAddToSet(id owner, NSString *property, NSMutableSet *set, id objToAdd) 
{
  if (![set containsObject:objToAdd])
  {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&objToAdd count:1];
    [owner willChangeValueForKey:property
                 withSetMutation:NSKeyValueUnionSetMutation 
                    usingObjects:changedObjects]; 
    [set addObject:objToAdd];
    [owner didChangeValueForKey:property 
                withSetMutation:NSKeyValueUnionSetMutation 
                   usingObjects:changedObjects]; 
    [changedObjects release];
    return YES;
  } 
  else
  {
    return NO;
  }
}


BOOL kvRemoveFromSet(id owner, 
                     NSString *property, 
                     NSMutableSet *set, 
                     id objToRemove)
{
  if ([set containsObject:objToRemove])
  {
    NSSet *changed = [[NSSet alloc] initWithObjects:&objToRemove count:1];
    [owner willChangeValueForKey: property
                 withSetMutation: NSKeyValueMinusSetMutation 
                    usingObjects: changed]; 
    [set removeObject: objToRemove];
    [owner didChangeValueForKey: property 
                withSetMutation: NSKeyValueMinusSetMutation 
                   usingObjects: changed]; 
    [changed release];
    return YES;
  } 
  else
  {
    return NO;
  }
}


/*
 Copyright (c) 2008, Jens Alfke <jens@mooseyard.com>. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRI-
 BUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
 THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
