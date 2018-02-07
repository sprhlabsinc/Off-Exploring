//
//  BlogEntryTableViewCell.h
//  Off Exploring
//
//  Created by Off Exploring on 08/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief UITableViewCell subclass to provide a custom cell view for display a single blog.
 
 Provides a cell created from Interface Builder.
 */
@interface BlogEntryTableViewCell : UITableViewCell {
	/**
		Blogs image
	 */
	UIImageView *coverImage;
	/**
		Blogs date
	 */
	UILabel *date;
}

@property (nonatomic, strong) IBOutlet UIImageView *coverImage;
@property (nonatomic, strong) IBOutlet UILabel *date;

@end
