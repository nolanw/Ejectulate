//
//  main.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EjectulateAppDelegate.h"


int main(int argc, char *argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *app = [NSApplication sharedApplication];
  [app setDelegate:[[[EjectulateAppDelegate alloc] init] autorelease]];
  [app run];
  [pool release];
  return 0;
}
