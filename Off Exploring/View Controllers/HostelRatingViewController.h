//
//  HostelRatingViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 01/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hostel.h"

@class HostelRatingViewController;

#pragma mark -
#pragma mark HostelRatingViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a message informing the delegate to dismiss the HostelRatingViewController
 
	This protocol allows delegates to be messaged when a user would like to dismiss the HostelRatingViewController and its view, and return
	back to the previous screen. It is up to the delegate to dismiss the viewcontroller.
 */
@protocol HostelRatingViewControllerDelegate <NSObject>
#pragma mark Required Method
@required

/**
	Delegate method signalled when the user wishes to dismiss the viewcontroller.
	@param hrvc The HostelRatingViewController to be dismissed
 */
- (void) hostelRatingViewControllerDidFinish:(HostelRatingViewController *)hrvc;

@end

/**
	@brief A UIViewController Subclass that displays an array of Hostel ratings
 
	This class provides the functionality to display an array of ratings about a hostel (for example, its cleanliness or safety)
	inside a tableview. The class sets itself as a UITableView delegate and data source appropriately.
 */
@interface HostelRatingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

	/**
		The delegate informed of viewing completion
	 */
	id <HostelRatingViewControllerDelegate> delegate;
	/**
		A pointer to the navigationItem to change the title of the page
	 */
	UINavigationItem *navItem;
	/**
		The tableview displaying the information
	 */
	UITableView *tableView;
	/**
		The hostel the ratings belong to
	 */
	Hostel *hostel;
}

#pragma mark IBAction
/**
	Action signalling the users wish to dismiss the view
 */
- (IBAction)backPressed;

@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id <HostelRatingViewControllerDelegate> delegate;
@property (nonatomic, retain) Hostel *hostel;

@end
