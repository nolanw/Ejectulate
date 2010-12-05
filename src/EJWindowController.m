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

// Calculate the height of the title bar of the window.
- (CGFloat)titleBarHeight;

// Put the action menu in the window frame and remove the zoom + miniturize 
// buttons.
- (void)setUpWindow;

// Identical to sending -sizeWindowToFit: with an argument of 0. See discussion 
// below.
- (void)sizeWindowToFit;

// Resize the window to hold as many rows as possible of the outline view, plus 
// additional, but no more than 80% of the screen.
- (void)sizeWindowToFit:(NSUInteger)additional;

@end


@implementation EJWindowController

#if 0
#pragma mark -
#pragma mark Properties
#endif

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

- (void)showWindow
{
  [self.window makeKeyAndOrderFront:self];
}

- (void)closeWindow
{
  [self.window performClose:self];
  [[NSApplication sharedApplication] hide:self];
}

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
  // Winner, selector with most arguments.
  NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown
                                      location:origin
                                 modifierFlags:NSLeftMouseDownMask
                                     timestamp:0
                                  windowNumber:[[button window] windowNumber]
                                       context:[[button window] graphicsContext]
                                   eventNumber:0
                                    clickCount:1
                                      pressure:1];
  // NSMenu will help us if the menu would appear off the screen.
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

- (void)setUpWindow
{
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
  
  NSFont *menuFont = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
  [self.windowTitleAccessoryMenu setFont:menuFont];
}

- (void)sizeWindowToFit
{
  [self sizeWindowToFit:0];
}

- (void)sizeWindowToFit:(NSUInteger)additional
{
  NSUInteger count = MAX([self.outline numberOfRows], 1) + additional;
  CGFloat height = [self.outline rowHeight] * count;
  height += count * [self.outline intercellSpacing].height;
  height = MIN(height, self.window.screen.frame.size.height * 0.8);
  NSRect frame = [self.window frame];
  NSRect content = [self.window contentRectForFrameRect:frame];
  CGFloat oldHeight = content.size.height;
  content.size.height = height;
  frame = [self.window frameRectForContentRect:content];
  frame.origin.y += (oldHeight - height);
  [self.window setFrame:frame display:YES animate:YES];
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
      [self.window center];
      [self sizeWindowToFit];
    }];
  [self setUpWindow];
}

#if 0
#pragma mark -
#pragma mark EJOutlineViewDelegate
#endif

- (void)ej_outlineViewDidPressReturnOrEnter:(EJOutlineView *)anOutlineView
{
  [[[self.tree selectedObjects] lastObject] performSelector:@selector(eject:)
                                                 withObject:self];
}

#if 0
#pragma mark -
#pragma mark NSOutlineViewDelegate
#endif

- (void)outlineView:(NSOutlineView*)anOutlineView
    willDisplayCell:(NSCell*)cell
     forTableColumn:(NSTableColumn*)tableColumn
               item:(id)item
{
  if ([[tableColumn identifier] isEqual:@"ejectButtons"])
  {
    NSButtonCell *button = (NSButtonCell *)cell;
    [button setTarget:[item representedObject]];
    [button setAction:@selector(eject:)];
    [button setShowsBorderOnlyWhileMouseInside:YES];
  }
  else
    [cell setImage:[[item representedObject] valueForKey:@"icon"]];
}

- (void)outlineViewItemWillExpand:(NSNotification *)note
{
  NSTreeNode *item = [[note userInfo] objectForKey:@"NSObject"];
  [self sizeWindowToFit:[item.childNodes count]];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)note
{
  [self sizeWindowToFit];
}

@end
