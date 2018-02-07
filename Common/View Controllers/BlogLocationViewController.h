//
//  BlogLocationViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 12/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "OffexConnex.h"
#import "ImageLoader.h"
#import "BlogViewController.h"

#pragma mark -
#pragma mark BlogLocationViewController Declaration
/**
	@brief Provides a View Controller displaying a list of Blog posts from a trip
 
	This class provides functionality to select from a list of all the blog posts a user has made from a perticular trip, in order
	to see the list of Blog objects from a perticular state and area. It displays this information in a tableview and so set itself 
    as a UITableView data source and delegate. It alsodownloads the thumbnails for these blog posts and so sets itself as an 
	ImageLoader delegate. 
 */
@interface BlogLocationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
															OffexploringConnectionDelegate, ImageLoaderDelegate,
															UIScrollViewDelegate, BlogViewControllerDelegate> 
{
	/**
		The tableview displaying the list of Blog posts
	 */
	UITableView *tableView;
	/**
		The Trip object the Blog objects belong to
	 */
	Trip *activeTrip;
	/**
		A button to press to add a Blog to Off Exploring
	 */
	UIBarButtonItem *addBlog;

@private	
	/**
		A flag to mark remote Blog data has been downloaded
	 */
	BOOL downloadedData;
	/**
		A connection to Off Exploring to download blog data
	 */
	OffexConnex *connex;
	/**
		An array of the currently active Blog thumbnail downloads
	 */
	NSMutableDictionary *activeDownloads;
	/**
		An array of section index titles to subdivide tableview
	 */
	NSArray *sectionIndexTitles;
}

#pragma mark IBActions

/**
	Action signalling the users intent to add a Blog to the Blogs array in this trip
	@param sender The button being pressed
 */
- (IBAction)addBlogPressed:(id)sender;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *addBlog;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Trip *activeTrip;

@end
