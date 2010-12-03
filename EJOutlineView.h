//
//  EJOutlineView.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Foundation/Foundation.h>

// Conforming delegates can be told when the Return or Enter key is pressed.
@protocol EJOutlineViewDelegate <NSOutlineViewDelegate>
@optional
- (void)ej_outlineViewDidPressReturnOrEnter:(NSOutlineView *)outlineView;
@end

// Outline view that sends to its delegate when the Return or Enter key is 
// pressed.
@interface EJOutlineView : NSOutlineView
{}

@end
