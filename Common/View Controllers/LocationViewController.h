//
//  LocationViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 28/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "StateSelectionViewController.h"
#import "LocationTextViewController.h"

@class LocationViewController;

#pragma mark -
#pragma mark HostelViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive information about a selected location
 
	This protocol allows delegates to be messaged when the user has finished selecting a location on a map, or manually
	inputting free text regarding a location. The class wraps up a MapViewController, and two text viewcontrollers
	to edit location to provide an easy interface to handle location.
 */
@protocol LocationViewControllerDelegate <NSObject>

#pragma mark Required Delegate Method
@required

/**
	Delegate method signalled when a user finished choosing location information
	@param dvc The LocationViewController object used to choose a location
	@param state The state that was selected
	@param area The area that was entered
	@param geolocation The geolocation (lat, long) information
 */
- (void)locationViewController:(LocationViewController *)dvc
			 didFinishWithState:(NSDictionary *)state
					   withArea:(NSDictionary *)area
				withGeolocation:(NSDictionary *)geolocation;

@optional

/**
	An optional delegate method setting wether a location may be dismissed with just state / area
	@param lvc The LocationViewController object used to choose a location
	@returns Wether the full entry is required - default no.
 */
- (BOOL)locationViewControllerMustHaveCompleteLocationDetails:(LocationViewController *)lvc;

@end

#pragma mark -
#pragma mark LocationViewController Interface

/**
	@brief A UIViewController Subclass that allows users to select a location on earth, either through free text of via a map
 
	This class provides an interface to select a location somewhere on the earth. It does this by providing a MapViewController
	to select a point on an MKMapView, or by allowing free text entry into an area field and selecting a country this area is 
	in. The class displays this information in a UITableView, and so sets itself as the Delegate and Data Source apporpriately.
	To provide the MapView, it sets itself as a MapViewController Delegate.  Finally, to support the free text location, it sets
	itself as a StateSelectionViewController Delegate, and a LocationTextViewController Delegate.
 */
@interface LocationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MapViewControllerDelegate, StateSelectionViewControllerDelegate, LocationTextViewControllerDelegate> {

	/**
		The Delegate to message with location information
	 */
	id <LocationViewControllerDelegate> __weak delegate;
	/**
		The UITableView to display location information on
	 */
	UITableView *tableView;
	/**
		The state name and slug
	 */
	NSDictionary *state;
	/**
		The area name and slug
	 */
	NSDictionary *area;
	/**
		The geolocation (latitude, longitude)
	 */
	NSDictionary *geolocation;
	/**
		A list of valid country iso codes to locations for Off Exploring
	 */
	NSDictionary *offexValid;
	/**
		The name of the country the state is in
	 */
	NSString *realCountryName;
	/**
		Wether the value of a state is in fact a state or a country
	 */
	BOOL validState;
}

#pragma mark IBActions
/**
	Action signalling the user is done selecting location information
 */
- (IBAction)done;

@property (nonatomic, weak) id <LocationViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView; 
@property (nonatomic, strong) NSDictionary *state;
@property (nonatomic, strong) NSDictionary *area;
@property (nonatomic, strong) NSDictionary *geolocation;
@property (nonatomic, strong) NSDictionary *offexValid;
@property (nonatomic, strong) NSString *realCountryName;
@property (nonatomic, assign) BOOL validState; 

@end
