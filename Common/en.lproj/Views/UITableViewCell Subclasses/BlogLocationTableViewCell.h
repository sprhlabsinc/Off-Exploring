//
//  BlogLocationTableViewCell.h
//  Off Exploring
//
//  Created by Off Exploring on 01/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief UITableViewCell subclass to provide a custom cell view for blog details.
 
 Provides a cell created from Interface Builder.
 */
@interface BlogLocationTableViewCell : UITableViewCell {

	/**
		Blog location image
	 */
	UIImageView *coverImage;
	
	/**
		Blog location name
	 */
	UILabel *title;
	
	/**
		Number of blogs in this blog location
	 */
	UILabel *contentCount;

}

@property (nonatomic, strong) IBOutlet UIImageView *coverImage;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *contentCount;

@end
