//
//  EJWindowController.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EJWindowController.h"
#import "EJEjectableVolumesWatcher.h"
#import "EJOutlineView.h"
#import "CollectionUtils.h"
#import "ImageAndTextCell.h"


@interface EJWindowController ()

- (CGFloat)titleBarHeight;

@end


@implementation EJWindowController

@synthesize tree;
@synthesize outline;
@synthesize volumesWatcher;
@synthesize windowTitleAccessoryView;
@synthesize windowTitleAccessoryMenu;
@dynamic tabViewIndex;

- (NSInteger)tabViewIndex
{
  return [self.volumesWatcher.volumes count] ? 1 : 0;
}

+ (NSSet *)keyPathsForValuesAffectingTabViewIndex
{
  return $set(@"volumesWatcher.volumes.@count");
}

#if 0
#pragma mark -
#pragma mark API
#endif

- (IBAction)showActionMenu:(id)sender
{
  // Thanks to Praveen Matanam (well probably not but he has no source)
  // http://praveenmatanam.wordpress.com/2008/09/05/how-to-popup-context-menu-
  // when-clicked-on-button
  // Idea is to ask NSMenu to present a menu using an event that specifies 
  // where.
  NSButton *button = sender;
  NSRect frame = [button frame];
  NSPoint originFromButton = NSMakePoint(frame.origin.x + frame.size.width + 1, 
                                         frame.origin.y + frame.size.height);
  NSPoint origin = [[button superview] convertPoint:originFromButton
                                             toView:nil];
  NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown
                                      location:origin
                                 modifierFlags:NSLeftMouseDownMask
                                     timestamp:0
                                  windowNumber:[[button window] windowNumber]
                                       context:[[button window] graphicsContext]
                                   eventNumber:0
                                    clickCount:1
                                      pressure:1];
  [NSMenu popUpContextMenu:self.windowTitleAccessoryMenu
                 withEvent:event
                   forView:button];
}

- (CGFloat)titleBarHeight
{
  NSRect frame = [self.window frame];
  NSRect content = [self.window contentRectForFrameRect:frame];
  return frame.size.height - content.size.height;
}

#if 0
#pragma mark -
#pragma mark NSWindowController
#endif

- (void)windowDidLoad
{
  [self.tree addObserverForKeyPath:@"arrangedObjects"
                           options:NSKeyValueObservingOptionInitial
                              task:^(id obj, NSDictionary *change)
    {
      [self.outline expandItem:nil expandChildren:YES];
    }];
  NSArray *buttons = $array(
    [self.window standardWindowButton:NSWindowMiniaturizeButton],
    [self.window standardWindowButton:NSWindowZoomButton]);
  NSView *titleBar = [[buttons lastObject] superview];
  [buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.window center];
  
  // Thanks to Matt Patenaude
  // http://iloveco.de/adding-a-titlebar-accessory-view-to-a-window
  NSRect titleBarFrame = titleBar.frame;
  NSRect accessoryViewFrame = self.windowTitleAccessoryView.frame;
  accessoryViewFrame.size.height = [self titleBarHeight] - 2.0;
  self.windowTitleAccessoryView.frame = NSMakeRect(
    titleBarFrame.size.width - accessoryViewFrame.size.width,
    titleBarFrame.size.height - accessoryViewFrame.size.height - 1.0,
    accessoryViewFrame.size.width,
    accessoryViewFrame.size.height);
  [titleBar addSubview:self.windowTitleAccessoryView];
  
  [self.windowTitleAccessoryMenu setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
}

#if 0
#pragma mark -
#pragma mark EJOutlineViewDelegate
#endif

- (void)ej_outlineViewDidPressReturnOrEnter:(EJOutlineView *)anOutlineView
{
  [[[self.tree selectedObjects] lastObject] performSelector:@selector(eject)];
}

#if 0
#pragma mark -
#pragma mark NSOutlineViewDelegate
#endif

- (void)outlineView:(NSOutlineView*)anOutlineView
    willDisplayCell:(ImageAndTextCell*)cell
     forTableColumn:(NSTableColumn*)tableColumn
               item:(id)item
{
  [cell setImage:[[item representedObject] valueForKey:@"icon"]];
}

@end
