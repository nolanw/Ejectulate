//
//  EjectulateWindowController.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EjectulateWindowController.h"
#import "EJEjectableVolumesWatcher.h"
#import "EJOutlineView.h"
#import "CollectionUtils.h"
#import "ImageAndTextCell.h"


@implementation EjectulateWindowController

@synthesize tree;
@synthesize outline;
@synthesize volumesWatcher;
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
  [buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.window center];
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
