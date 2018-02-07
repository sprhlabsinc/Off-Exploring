//
//  HostelListViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 13/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLoader.h"
#import "Hostels.h"
#import "HostelViewController.h"
#import "HostelTabBarViewController.h"
#import "HostelViewControllerDelegate.h"

@class HostelTabBarViewController;

#pragma mark -
#pragma mark HostelListViewController Interface

/**
	@brief A UIViewController Subclass that displays a selectable list of recommended Hostels

	This class provides functionality to display the list of downloaded recommened hostels from Off Exploring,
	displaying them in a tableview. The class sets itself as a UITableViewDelegate and data source as appropriate.
	More hostels can be loaded by hitting a "Load more hostels button", and so the class sets itself as a HostelsLoader Delegate.
	In order to load images for hostels, the class also sets itself as an ImageLoader Delegate and a UIScrollView Delegate.
	Finally, in order to display Hostel information, the class sets itself as a HostelViewController Delegate.
*/
@interface HostelListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImageLoaderDelegate, 
														HostelsLoaderDelegate, UIScrollViewDelegate, HostelViewControllerDelegate>
{
	/**
		TableView displaying the list of Hostel objects
	 */
	UITableView *tableView;
	/**
		TabBarViewController wrapping up this view
	 */
	HostelTabBarViewController *parentTabController;
	/**
		The array of hostels to display in the list
	 */
	NSArray *hostels;
@private 
	/**
		An array of currently active image downloads
	 */
	NSMutableDictionary *activeDownloads;
	/**
		An array of downloaded images
	 */
	NSMutableDictionary *hostelImages;
	/**
		A HostelLoader used to download Hostel objects
	 */
	Hostels *hostelLoad;
	/**
		A flag to state wether hostels are currently being downlaoded
	 */
	BOOL downloadingHostels;
}

#pragma mark TableView Reload
/**
	Reloads the tableView with the latest list of downloaded Hostels
 */
- (void)reloadView;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) HostelTabBarViewController *parentTabController;
@property (nonatomic, retain) NSArray *hostels;
@end
