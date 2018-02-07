//
//  TripViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trips.h"
#import "OffexConnex.h"
#import "MBProgressHUD.h"

#pragma mark -
#pragma mark RootViewController Interface

/**
	@brief A UIViewController Subclass that displays the list of Trips a user has
	
	This class displays the list of Trips a user has created. Trips wrap around Blogs, Photos, Albums
	and Videos so a User can use the site multiple times for different holidays without creating new
	accounts to symbolise new journeys. Trips is not active as of 04/10/10, however the wrappers here
	are created for convienience for the future.
*/
@interface TripViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, OffexploringConnectionDelegate, MBProgressHUDDelegate> {

	/**
		The tableview the trips are listed in
	 */
	UITableView *table;
	/**
		A flag used to set what coverimage type to used in a trip (album, photo or video)
	 */
	int requestType;
	/**
		The array of Trip objects to display
	 */
	Trips *trips;
	/**
		Button to press to a dd a new Trip
	 */
	UIBarButtonItem *addButton;
	
@private 
	/**
		Stores an array of drafts not yet bound to trips
	 */
	NSMutableArray *noTripDrafts;
	/**
		A flag to state wether the user is selecting where to store trips to
	 */
	BOOL selectingTrip;
	/**
		Index of the blog entry having its trip stored
	 */
	NSUInteger selectingIndex;
	/**
		Loader to display during editing
	 */
	MBProgressHUD *HUD;
	/**
		Trip being deleted
	 */
	Trip *deleteingTrip;
}

#pragma mark IBActions
- (IBAction) addTrip;

- (void)checkDraftBlogs;
- (void)displayNoTripDraftsSelectorForIndex:(NSUInteger)index;

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, assign) int requestType; 
@property (nonatomic, strong) Trips *trips;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;

@end
