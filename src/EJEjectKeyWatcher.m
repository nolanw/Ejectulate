//
//  EJEjectKeyWatcher.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-04.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EJEjectKeyWatcher.h"
#import <IOKit/hidsystem/ev_keymap.h>


// Huge thanks to Rogue Amoeba for:
//   - subtype 8
//   - The layout of data1 for media key events.
//   - Pointing to the ev_keymap.h header for key constants.
// http://www.rogueamoeba.com/utm/archives/MediaKeys.m
#define EJIsMediaKeyEvent(e) ([e type] == NSSystemDefined && [e subtype] == 8)
#define EJMediaKeyCodeWithNSEvent(e) (([e data1] & 0xFFFF0000) >> 16)
#define EJMediaKeyFlagsWithNSEvent(e) ([e data1] & 0x0000FFFF)
#define EJMediaKeyStateWithNSEvent(e) \
        (((([e data1] & 0x0000FFFF) & 0xFF00) >> 8) == 0xA)


@interface EJEjectKeyWatcher ()

// Enable the event tap, installing it first if needed.
- (void)listenForEject;

// The eject key was pressed with no modifiers.
- (void)ejectWasPressed;

@end


@implementation EJEjectKeyWatcher

#if 0
#pragma mark -
#pragma mark Properties
#endif

@synthesize delegate;

#if 0
#pragma mark -
#pragma mark Init
#endif

- (id)init
{
  if ((self = [super init]))
  {
    [self listenForEject];
  }
  return self;
}

+ (id)watcher
{
  return [[[self alloc] init] autorelease];
}

#if 0
#pragma mark -
#pragma mark Event tap
#endif

// Thanks to Kevin Gessner's post on CocoaDev for the code in the following 
// function and its following method.
// http://www.cocoabuilder.com/archive/cocoa/222356-play-pause-rew-ff-keys.html
static CGEventRef KeyDownCallback(CGEventTapProxy proxy, 
                                  CGEventType type,
                                  CGEventRef event,
                                  void *refcon)
{
  // For whatever reason the system seems to disable the event tap after a few 
  // minutes without being used (or maybe after being enabled, not sure). If 
  // that happens, just reenable it and all's well.
  if (type == kCGEventTapDisabledByTimeout)
  {
    [(EJEjectKeyWatcher *)refcon listenForEject];
    return NULL;
  }
  if (type != NX_SYSDEFINED)
    return event;
  NSEvent *e = [NSEvent eventWithCGEvent:event];
  if (EJIsMediaKeyEvent(e))
  {
		if (EJMediaKeyCodeWithNSEvent(e) == NX_KEYTYPE_EJECT)
		{
      if ([e modifierFlags] & (NSShiftKeyMask | NSControlKeyMask | 
                               NSAlternateKeyMask | NSCommandKeyMask))
        return event;
		  if (!EJMediaKeyStateWithNSEvent(e))
        [(EJEjectKeyWatcher *)refcon ejectWasPressed];
      return NULL;
    }
  }
  return event;
}

#if 0
#pragma mark -
#pragma mark API
#endif

- (void)listenForEject
{
  if (!eventTap)
  {
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0,
                          CGEventMaskBit(NX_SYSDEFINED), KeyDownCallback, self);
    if (!eventTap)
    {
      NSLog(@"%@ no tap; universal access?", NSStringFromSelector(_cmd));
      return;
    }
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(NULL,
                                                                   eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, 
                                                         kCFRunLoopCommonModes);
    CFRelease(runLoopSource);
  }
  CGEventTapEnable(eventTap, true);
}

- (void)ejectWasPressed
{
  if ([self.delegate respondsToSelector:_cmd])
    [self.delegate performSelector:_cmd];
}

@end
