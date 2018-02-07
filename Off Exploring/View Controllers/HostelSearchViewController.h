//
//  HostelSearchViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 24/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationViewController.h"
#import "Hostels.h"
#import "MBProgressHUD.h"

@class HostelSearchViewController;

@protocol HostelSearchViewControllerDelegate <NSObject>

#pragma mark Required Delegate Methods
@required

/**
	Delegate method signalled when an array of Hostel objects has been downloaded and stored after a search
	@param hsvc The HostelSearchViewController used to perform the search
	@param country The country being searched
	@param area The area being searched
 */
- (void)hostelSearchViewController:(HostelSearchViewController *)hsvc
		   didLoadHostelsForCountry:(NSString *)country
						   withArea:(NSString *)area;


/**
	Delegate method signalled when the user wishes to dismiss the modal view dialogue.
	@param hsvc The hostelSearchViewController to dismiss
 */
- (void)hostelSearchViewControllerDidCancel:(HostelSearchViewController *)hsvc;

#pragma mark Optional Delegate Methods
@optional

/**
	Presets the search city field with the returned city name from the delegate
	@param hsvc The HostelSearchViewController requesting a city name to pre-populate with
	@returns The city name to pre-populate with
 */
- (NSString *)cityForHostelSearchViewController:(HostelSearchViewController *)hsvc;
/**
	Presets the search country field with the returned country name from the delegate
	@param hsvc The HostelSearchViewController requesting a countru name to pre-populate with
	@returns The country name to pre-populate with
 */
- (NSString *)countryForHostelSearchViewController:(HostelSearchViewController *)hsvc;

@end

/**
	@brief A LocationViewController Subclass that extends Location selection to add search preferences
	
	This class extends the LocationViewController class, to allow for selection of search preferences
	in order to provide an interface to search for hostels in a perticular area. The class downloads
	Hostel information from Off Exploring, and sets itself as a HostelsLoaderDelegate appropriately.
	During this download a loader is also displayed, and so the class is a MBProgressHUDDelegate
*/
@interface HostelSearchViewController : LocationViewController <HostelsLoaderDelegate, MBProgressHUDDelegate>{

	/**
		Delegate messages sent to this
	 */
	id <HostelSearchViewControllerDelegate> hostelDelegate;
	
@private
	/**
		The method to search for hostels (rating, price etc)
	 */
	int searchMode;
	/**
		A loader to display whilst making requests
	 */
	MBProgressHUD *HUD;
	/**
		A class to download Hostel objects and store them in the sqlite3 db
	 */
	Hostels *hostelLoad;
	/**
		A Bool flag to show the ratings submenu when setting search method 
	 */
	BOOL showRatings;
}

#pragma mark IBActions
/**
	Action signalling the users wish to cancel the search
 */
- (IBAction)cancel;
/**
	Action signalling the users wish to perform the search
 */
- (IBAction)search;

@property (nonatomic, assign) id <HostelSearchViewControllerDelegate> hostelDelegate;

@end
