//
//  BlogDetailTableViewCell.h
//  Off Exploring
//
//  Created by Off Exploring on 16/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief UITableViewCell subclass to provide a custom cell view for displaying elements about a blog.
 
 Provides a cell created from Interface Builder.
 */
@interface BlogDetailTableViewCell : UITableViewCell {

	/**
		The value of the element
	 */
	UILabel *detail;
	/**
		The label of the element
	 */
	UILabel *label;
	
}

@property (nonatomic, strong) IBOutlet UILabel *detail;
@property (nonatomic, strong) IBOutlet UILabel *label;

@end
