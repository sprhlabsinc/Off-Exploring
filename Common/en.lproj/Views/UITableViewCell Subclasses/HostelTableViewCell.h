//
//  HostelTableViewCell.h
//  Off Exploring
//
//  Created by Off Exploring on 19/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Hostel;
@class HostelView;

/**
 @brief UITableViewCell subclass to provide a custom cell view for displaying elements about a hostel.
 
 Provides a cell created from a HostelView populated by Hostel data.
 */
@interface HostelTableViewCell : UITableViewCell {
	/**
		The HostelView to display on the cell
	 */
	HostelView *hostelView;
}

#pragma mark Setting Elements Of Cell
/**
	Overriden setHostel method in order to call redisplay of cell via pass through
	@param newHostel The Hostel used to set cell content
 */
- (void)setHostel:(Hostel *)newHostel;
/**
	Overriden setHostelImage method in order to call redisplay of cell via pass through
	@param newHostelImage The Hostel Image to set on the cell
 */
- (void)setHostelImage:(UIImage *)newHostelImage;

#pragma mark Redisplay of cell
/**
	Redraws the cell via setNeedsDisplay
 */
- (void)redisplay;

@property (nonatomic, strong) HostelView *hostelView;

@end
