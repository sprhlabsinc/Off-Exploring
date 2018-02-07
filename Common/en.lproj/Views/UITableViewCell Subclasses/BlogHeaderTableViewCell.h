//
//  BlogHeaderTableViewCell.h
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief UITableViewCell subclass to provide a custom header view for blog details.
 
 Provides functionality inside a tableviewcell to click the button on a cell created from
 Interface Builder.
 */
@interface BlogHeaderTableViewCell : UITableViewCell {

	/**
		The cell main text
	 */
	UILabel *textLabel;
	
	/**
		The button (with settable image)
	 */
	UIButton *blogThumbButton;
}

@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UIButton *blogThumbButton;

@end
