//
//  BlogLocationHeaderForTableViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 06/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief UIView subclass to provide a custom section header displaying the country of a collection of blog posts.
 
 Provides a view created from Interface Builder.
 */
@interface BlogLocationHeaderForTableViewController : UIView {
	/**
		The country name
	 */
	UILabel *headerLabel;
}

@property (nonatomic, strong) IBOutlet UILabel *headerLabel;

@end
