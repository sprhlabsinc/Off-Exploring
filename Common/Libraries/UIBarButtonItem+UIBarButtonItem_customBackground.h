//
//  UIBarButtonItem+UIBarButtonItem_customBackground.h
//  Off Exploring
//
//  Created by Ian Outterside on 24/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (UIBarButtonItem_customBackground)

+ (id) customBarButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
+ (id) customBackButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;

@end
