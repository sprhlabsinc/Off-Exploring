//
//  HostelView.h
//  Off Exploring
//
//  Created by Off Exploring on 19/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Hostel;

/**
 @brief Provides a view created from Hostel data.
 
 Draws a view that is layered onto a HostelTableViewCell populated with Hostel data
 */
@interface HostelView : UIView {

	/**
		The hostel providing information to the view
	 */
	Hostel *hostel;
	/**
		The hostel image 
	 */
	UIImage *image;
	/**
		A wrapper for the image for scaling / positioning
	 */
	UIImageView *imageWrapper;
	/**
		Views highlighted state
	 */
	BOOL highlighted;
	/**
		Views editing state
	 */
	BOOL editing;
	
}

@property (nonatomic, strong) Hostel *hostel;
@property (nonatomic, strong) UIImageView *imageWrapper;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isEditing) BOOL editing;

@end
