//
//  main.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EJAppDelegate.h"


int main(int argc, char *argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *app = [NSApplication sharedApplication];
  [app setDelegate:[[[EJAppDelegate alloc] init] autorelease]];
  [app run];
  [pool drain];
  return 0;
}
