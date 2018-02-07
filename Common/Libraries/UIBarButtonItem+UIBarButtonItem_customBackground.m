//
//  UIBarButtonItem+UIBarButtonItem_customBackground.m
//  Off Exploring
//
//  Created by Ian Outterside on 24/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItem+UIBarButtonItem_customBackground.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIBarButtonItem (UIBarButtonItem_customBackground)


+ (id) customButtonWithImageNamed:(NSString *)imageName selectedImageNamed:(NSString *)selectedImageName leftCapWidth:(CGFloat)leftCapWidth edgeInsets:(UIEdgeInsets)edgeInsets title:(NSString *)title target:(id)target selector:(SEL)selector {
    UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    customButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    customButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.25f];
    customButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    customButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    customButton.titleEdgeInsets = edgeInsets;
    UIImage* navButtonBackgroundImage = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:0.0f];
    UIImage* navButtonPressedBackgroundImage = [[UIImage imageNamed:selectedImageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:0.0f];
    [customButton setBackgroundImage:navButtonBackgroundImage forState:UIControlStateNormal];
    [customButton setTitle:title forState:UIControlStateNormal];
    [customButton setBackgroundImage:navButtonPressedBackgroundImage forState:UIControlStateHighlighted];
    [customButton setBackgroundImage:navButtonPressedBackgroundImage forState:UIControlStateSelected];
    
    CGSize size = CGSizeMake(30.0f, 30.0f);
    if (title != nil) {
        size = [[NSString stringWithString:title] sizeWithFont:customButton.titleLabel.font];
    }
    customButton.frame = CGRectMake(0.0f, 0.0f, size.width + 20.0f, 30.0f);
    customButton.layer.shouldRasterize = YES;
    customButton.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    return [[UIBarButtonItem alloc] initWithCustomView:customButton];
}

+ (id) customBarButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector {
    return [self customButtonWithImageNamed:@"navButtonBG.png" 
                         selectedImageNamed:@"navButtonPressedBG.png" 
                               leftCapWidth:6.0f 
                                 edgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f) 
                                      title:title 
                                     target:target 
                                   selector:selector];
}

+ (id) customBackButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector {    
    return [self customButtonWithImageNamed:@"backButtonBG.png" 
                         selectedImageNamed:@"backButtonPressedBG.png" 
                               leftCapWidth:12.0f 
                                 edgeInsets:UIEdgeInsetsMake(0.0f, 11.0f, 0.0f, 5.0f) 
                                      title:title 
                                     target:target 
                                   selector:selector];
}

@end
