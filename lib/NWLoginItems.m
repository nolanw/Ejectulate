//
//  NWLoginItems.m
//  UWWeather
//
//  Created by Nolan Waite on 09-12-04.
//  Copyright 2009 Nolan Waite. All rights reserved.
//

#import "NWLoginItems.h"


@interface NWLoginItems ()

// Obtain and return a reference to the session login items file list.
// Must CFRelease it when done.
+ (LSSharedFileListRef)_sessionLoginItems;

// Obtain and return a reference to the session login item corresponding to 
// |bundle|, or NULL if no such item exists. If return value is not NULL, 
// must CFRelease when done.
+ (LSSharedFileListItemRef)_sessionLoginItemForBundle:(NSBundle *)bundle;

@end

@implementation NWLoginItems

+ (LSSharedFileListRef)_sessionLoginItems
{
  LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  NSAssert(loginItems != NULL, @"Could not create session login items file list.");
  return loginItems;
}

+ (LSSharedFileListItemRef)_sessionLoginItemForBundle:(NSBundle *)bundle
{
  LSSharedFileListRef loginItems = [self _sessionLoginItems];
  UInt32 seed;
  CFArrayRef snapshot = LSSharedFileListCopySnapshot(loginItems, &seed);
  CFIndex snapshotIndex = CFArrayGetCount(snapshot);
  LSSharedFileListItemRef item;
  LSSharedFileListItemRef ret = NULL;
  CFURLRef itemURL;
  while (snapshotIndex-- && ret == NULL)
  {
    item = (LSSharedFileListItemRef)CFArrayGetValueAtIndex(snapshot, snapshotIndex);
    LSSharedFileListItemResolve(item, 0, &itemURL, NULL);
    if ([(NSURL *)itemURL isEqual:[bundle bundleURL]])
      ret = (LSSharedFileListItemRef)CFRetain(item);
    CFRelease(itemURL);
  }
  CFRelease(snapshot);
  CFRelease(loginItems);
  return ret;
}

void EnsureBundle(NSBundle **bundle)
{
  if (*bundle == nil)
    *bundle = [NSBundle mainBundle];
}

+ (void)addBundleToSessionLoginItems:(NSBundle *)bundle
{
  EnsureBundle(&bundle);
  LSSharedFileListRef loginItems = [self _sessionLoginItems];
  LSSharedFileListItemRef item = [self _sessionLoginItemForBundle:bundle];
  if (item == NULL)
    item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, (CFURLRef)[bundle bundleURL], NULL, NULL);
  CFRelease(item);
  CFRelease(loginItems);
}

+ (void)removeBundleFromSessionLoginItems:(NSBundle *)bundle
{
  EnsureBundle(&bundle);
  LSSharedFileListRef loginItems = [self _sessionLoginItems];
  LSSharedFileListItemRef item = [self _sessionLoginItemForBundle:bundle];
  if (item != NULL)
  {
    LSSharedFileListItemRemove(loginItems, item);
    CFRelease(item);
  }
  CFRelease(loginItems);
}

+ (BOOL)isBundleInSessionLoginItems:(NSBundle *)bundle
{
  EnsureBundle(&bundle);
  LSSharedFileListItemRef item = [self _sessionLoginItemForBundle:bundle];
  if (item == NULL)
    return NO;
  CFRelease(item);
  return YES;
}

@end
