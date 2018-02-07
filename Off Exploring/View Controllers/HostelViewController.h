//
//  HostelViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 25/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "RootViewController.h"
#import "Hostel.h"
#import "HostelSearchViewController.h"
#import "HostelPhotoViewController.h"
#import "ImageLoader.h"
#import "HostelRatingViewController.h"
#import "HostelInfoViewController.h"
#import "HostelAddressViewController.h"
#import "HostelAvailabilityViewController.h"
#import "HostelViewControllerDelegate.h"

@class RootViewController;

/**
	@brief A UIViewController Subclass that displays the main information about a Hostel
 
	This class displays all the key information about a Hostel. In provides the ability to view a Hostels photos,
	find out about its ratings, view more information such as check in and check out time, and make room reservations.
	It also displays the hostel on a map by itself so its easy to identify. Class sets itself as a UITableView delegate
	and data source display its detail information. It sets itself as a HostelSearchViewController delegate so it can
	perform fresh searches for hostels. It is an ImageLoader delegate to download the thumbnail image for a Hostel.
	It is an MKMapView delegate to display the Hostel on a map. Finally it is a HostelPhotoViewController, HostelRatingViewController
	and HostelAvailabilityViewController delegates to display hostel photos, ratings and provide booking facilities.
 */
@interface HostelViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, HostelSearchViewControllerDelegate, 
													ImageLoaderDelegate, MKMapViewDelegate, HostelPhotoViewControllerDelegate, 
													HostelRatingViewControllerDelegate, HostelAvailabilityViewControllerDelegate>
{

	/**
		Delegate that is message about room bookings and dismissal of view
	 */
	id <HostelViewControllerDelegate> delegate;
	/**
		A pointer to the navigation bar to change the page title
	 */
	UINavigationBar *navBar;
	/**
		A view wrapping up hostel information
	 */
	UIView *tableViewWrapper;
	/**
		A view wrapping up a map displaying the location of the hostel
	 */
	UIView *mapViewWrapper;
	/**
		A tableview displaying the hostel information
	 */
	UITableView *tableView;
	/**
		A toolbar providing a switch to choose between details and map view
	 */
	UIToolbar *toolBar;
	/**
		A button to press to dismiss the HostelViewController
	 */
	UIBarButtonItem *backButton;
	/**
		A pointer to the rootViewController to provide navigation jumping
	 */
	RootViewController *rootNav;
	/**
		The Hostel the HostelViewController is displaying
	 */
	Hostel *hostel;
	/**
		The thumbnail image of the hostel
	 */
	UIImage *hostelImage;
	/**
		A mapview displaying the hostel location
	 */
	MKMapView *mapView;
	/**
		An array storing DDAnnotations for the map
	 */
	NSMutableArray *annotations;
@private
	/**
		ImageLoader used to download the hostel image if it is not already downloaded
	 */
	ImageLoader *imageLoader;
}

#pragma mark IBActions
/**
	Action signalling the users wish go back to the rootViewController
 */
- (IBAction)home;
/**
	Action signalling the users wish to search for new Hostels
 */
- (IBAction)search;
/**
	Action signalling the users wish to switch between the detail view and the map view
	@param sender The segmented control making the switch
 */
- (IBAction)segmentSwitch:(id)sender;

#pragma mark Other Actions
/**
	Action signalling the users wish to book a Hostel
 */
- (void)bookHostel;
/**
	Action signalling the users wish to view all the photos for a Hostel
 */
- (void)showPhoto;

@property (nonatomic, assign) id <HostelViewControllerDelegate> delegate;
@property (nonatomic, assign) RootViewController *rootNav;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIView *tableViewWrapper;
@property (nonatomic, retain) IBOutlet UIView *mapViewWrapper;
@property (nonatomic, retain) Hostel *hostel;
@property (nonatomic, retain) UIImage *hostelImage;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *annotations;


@end
