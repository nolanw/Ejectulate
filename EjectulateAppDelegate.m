//
//  EjectulateAppDelegate.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EjectulateAppDelegate.h"
#import "EjectulateWindowController.h"


// Observed when pressing eject key. Unsure of portabiility.
#define kEJEjectKeyCode 14
// This magic layout of data1 thanks to Rogue Amoeba.
// http://www.rogueamoeba.com/utm/archives/MediaKeys.m
#define EJIsMediaKeyEvent(e) ([e type] == NSSystemDefined && [e subtype] == 8)
#define EJMediaKeyCodeWithNSEvent(e) (([e data1] & 0xFFFF0000) >> 16)
#define EJMediaKeyStateWithNSEvent(e) \
        (((([e data1] & 0x0000FFFF) & 0xFF00) >> 8) == 0xA)


@interface EjectulateAppDelegate ()

@property (nonatomic, retain) EjectulateWindowController *windowController;

- (void)listenForEject;
- (void)ejectWasPressed;

@end


@implementation EjectulateAppDelegate

@synthesize windowController;

#if 0
#pragma mark -
#pragma mark API
#endif

// Thanks to Kevin Gessner's post on CocoaDev for the code in the following 
// function and its following method.
// http://www.cocoabuilder.com/archive/cocoa/222356-play-pause-rew-ff-keys.html
CGEventRef KeyDownCallback(CGEventTapProxy proxy, 
                           CGEventType type,
                           CGEventRef event,
                           void *refcon)
{
  if (type != NX_SYSDEFINED)
    return event;
  NSEvent *e = [NSEvent eventWithCGEvent:event];
  // NSSystemDefined subtype 8 is a media key.
  if (EJIsMediaKeyEvent(e))
  {
		if (EJMediaKeyCodeWithNSEvent(e) == kEJEjectKeyCode)
		{
		  if (!EJMediaKeyStateWithNSEvent(e))
        [(EjectulateAppDelegate *)refcon ejectWasPressed];
      return NULL;
    }
  }
  return event;
}

- (void)listenForEject
{
  CFMachPortRef eventTap = CGEventTapCreate(kCGSessionEventTap, 
                                            kCGHeadInsertEventTap,
                                            0,
                                            CGEventMaskBit(NX_SYSDEFINED),
                                            KeyDownCallback,
                                            self);
  if (!eventTap)
  {
    NSLog(@"%@ no tap; universal access?", NSStringFromSelector(_cmd));
    return;
  }
  CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(
                                              kCFAllocatorDefault, eventTap, 0);
  CFRunLoopAddSource(CFRunLoopGetCurrent(),
                     runLoopSource,
                     kCFRunLoopCommonModes);
  CGEventTapEnable(eventTap, true);
}

- (void)ejectWasPressed
{
  if ([self.windowController.window isKeyWindow])
    [self.windowController.window performClose:self];
  else
  {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self.windowController showWindow:self];
  }
}

#if 0
#pragma mark -
#pragma mark NSApplicationDelegate
#endif

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
  Class ejwc = [EjectulateWindowController class];
  self.windowController = [[ejwc alloc] initWithWindowNibName:@"MainWindow"];
  [self.windowController autorelease];
  [self listenForEject];
}

@end
