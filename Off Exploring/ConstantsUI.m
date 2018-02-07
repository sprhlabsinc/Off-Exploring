//
//  ConstantsUI.m
//  Off Exploring
//
//  Created by Ian Outterside on 26/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConstantsUI.h"
#import "Constants.h"

@implementation ConstantsUI

+ (void)customiseUI {
    
    // If greater than or equal to iOS 5 UIAppearance proxy available
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        // UIAppearance proxy not available.
        return;
    }
    
    
    // Custom navigation bar
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor navBarTextColor]}];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

@end
