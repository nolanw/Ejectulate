//
//  EJOutlineView.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EJOutlineView.h"


@implementation EJOutlineView

#if 0
#pragma mark -
#pragma mark NSResponder
#endif

- (void)keyDown:(NSEvent *)event
{
  NSString *characters = [event charactersIgnoringModifiers];
  if ([characters length] == 1)
  {
    unichar character = [characters characterAtIndex:0];
    if (character == NSCarriageReturnCharacter || character == NSEnterCharacter)
    {
      SEL delegateSelector = @selector(ej_outlineViewDidPressReturnOrEnter:);
      if ([[self delegate] respondsToSelector:delegateSelector])
        [[self delegate] performSelector:delegateSelector withObject:self];
      return;
    }
  }
  [super keyDown:event];
}

@end
