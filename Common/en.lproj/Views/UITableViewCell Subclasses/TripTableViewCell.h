//
//  TripTableViewCell.h
//  Off Exploring
//
//  Created by Off Exploring on 30/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief UITableViewCell subclass to provide a custom cell view for trip details.
 
 Provides a cell created from Interface Builder.
 
 @todo Class out of date, not implemented as yet (22.09.2010)
 */
@interface TripTableViewCell : UITableViewCell {
	
	/**
		Trips cover image
	 */
	UIImageView *coverImage;
	/**
		Trips title
	 */
	UILabel *title;
	/**
		Trips description
	 */
	UILabel *description;
	/**
		Number of items belonging to this trip (Albums or Blogs)
	 */
	UILabel *contentCount;
	
}

@property (nonatomic, strong) IBOutlet UIImageView *coverImage;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *description;
@property (nonatomic, strong) IBOutlet UILabel *contentCount;

@end
