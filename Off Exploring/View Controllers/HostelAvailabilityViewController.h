//
//  HostelAvailabilityViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 02/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hostel.h"
#import "Hostels.h"
#import "MBProgressHUD.h"

@class HostelAvailabilityViewController;

#pragma mark -
#pragma mark HostelAvailabilityViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a notification of when a user has finished using the HostelAvailabilityViewController
 
	This protocol allows delegates to be given a signal that the user of the app has cancelled selecting available dates for booking hostels using
	the HostelAvailabilityViewController. The delegate is then expected to dismiss the modal view
 */
@protocol HostelAvailabilityViewControllerDelegate <NSObject>
#pragma mark Required Methods
@required

/**
	Delegate method messaged when a user cancels selecting available dates for booking hostels
	@param hrvc The HostelAvailabilityViewController used to select dates
 */
- (void) hostelAvailabilityViewControllerDidFinish:(HostelAvailabilityViewController *)hrvc;

@end

#pragma mark -
#pragma mark HostelAvailabilityViewController Interface

/**
	@brief A UIViewController Subclass that allows users to select two dates to check the availability of Hostel Rooms with.
 
	This class provides an interface to select two dates that can be used to check the availability of Hostel Rooms with. It 
	connects to the Hostels API and so sets itself as a HostelsLoaderDelegate to download the information and parse it. It 
	displays this the selectors using 2 UITableViewCells, and so sets itself as a UItableView Delegate and Data Source appropriately.
	Finally it displays a loader when downloading remote Room information and so sets itself as a MBProgressHUDDelegate.
 */
@interface HostelAvailabilityViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, HostelsLoaderDelegate, MBProgressHUDDelegate>{

	/**
		Delegate to notify of dismissal of the HostelAvailabilityViewController
	 */
	id <HostelAvailabilityViewControllerDelegate> delegate;
	/**
		Datepicker used to select dates
	 */
	UIDatePicker *picker;
	/**
		Tableview used to display selected dates
	 */
	UITableView *tableView;
	/**
		A button pressed to dismiss the HostelAvailabilityViewController
	 */
	UIBarButtonItem *backButton;
	/**
		A button pressed to start the Room search
	 */
	UIBarButtonItem *searchButton;
	/**
		The start date for the stay at the hostel
	 */
	NSDate *startDate;
	/**
		The end date for teh stay at the hostel
	 */
	NSDate *endDate;
	/**
		the hostel being checked for availability
	 */
	Hostel *hostel;
@private
	/**
		A private store to choose which date to edit via its UITableViewCell
	 */
	NSIndexPath *editingPath;
	/**
		A private store of the color used to display text in a UITableViewCell
	 */
	UIColor *defaultColor;
	/**
		A loader to display when making remote requests
	 */
	MBProgressHUD *HUD;
	/**
		HostelLoader used to download room information
	 */
	Hostels *hostelLoad;
}

#pragma mark IBActions
/**
	Action signalling user wishes to cancel choosing dates and dismiss the view
 */
- (IBAction)cancel;
/**
	Action signalling user wishes to search for Rooms 
 */
- (IBAction)search;
/**
	Action signalling the date being chosen has changed
 */
- (IBAction)datepickerChoseDate;

@property (nonatomic, assign) id <HostelAvailabilityViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIDatePicker *picker;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *searchButton;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) Hostel *hostel;

@end
