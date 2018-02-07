//
//  BlogEntriesViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 08/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLoader.h"
#import "BlogViewController.h"
#import "Blogs.h"
#import "OffexConnex.h"
#import "MBProgressHUD.h"

#pragma mark -
#pragma mark BlogEntriesViewController Declaration
/**
	@brief Provides a View Controller displaying a list of Blog posts from a perticular state and area
 
	This class provides functionality to select from a list of all the blog posts a user has made from a perticular state and area, in order
	to see the blog content. It displays this information in a tableview and so set itself as a UITableView data source and delegate. It also
	downloads the thumbnails for these blog posts and so sets itself as an ImageLoader delegate. Finally, it allows for the deletion of a 
	Blog post using the swipe to delete feature on UITableView, and to perform this action on Off Exploring implements the OffexploringConnection
	Delegate protocol.
 */
@interface BlogEntriesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImageLoaderDelegate, UIScrollViewDelegate, BlogViewControllerDelegate,
														UIActionSheetDelegate, MBProgressHUDDelegate, OffexploringConnectionDelegate> 
{
	/**
		The tableview displaying the list of Blog posts
	 */
	UITableView *tableView;
	/**
		An array of Blog posts belonging to this state / area
	 */
	NSMutableArray *activeBlogs;
	/**
		A button providing the ability to add a blog post to this state/area
	 */
	UIBarButtonItem *addButton;
	/**
		A dictionary containing the name and slug of the state this View Controller is displaying
	 */
	NSDictionary *state;
	/**
		A dictionary containing the name and slug of the area this View Controller is displaying
	 */
	NSDictionary *area;
	/**
		A dictionary containing information about the Trip this View Controllers Blog objects belong to
	 */
	NSDictionary *parentTrip;
	/**
		The wrapper Blogs object to interface with when adding and removing Blogs
	 */
	Blogs *allBlogs;
@private
	/**
		An array of the currently active Blog thumbnail downloads
	 */
	NSMutableDictionary *activeDownloads;
	/**
		An NSIndexPath temporarily storing a selected row ID for an item being requested to be deleted
	 */
	NSIndexPath *deleteID;
	/**
		A loader to display whilst making remote requests
	 */
	MBProgressHUD *HUD;
	/**
		The tag id of a button used in the tableview for providing functionaility to draft blogs (jump to edit, jump to post etc)
	 */
	int tappedTag;
	/**
		A connection to Off Exploring to use for deleting a Blog post
	 */
	OffexConnex *connex;
}

#pragma mark IBActions
/**
	Action signalling the users intent to add a Blog to the Blogs array in this state / area / trip
	@param sender The button being pressed
 */
- (IBAction)addBlogPressed:(id)sender;
/**
	Action signalling the users wish to perform an action with a draft blog
	@param sender The button being pressed
 */
- (void)draftMenu:(id)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *activeBlogs;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) NSDictionary *state;
@property (nonatomic, strong) NSDictionary *area;
@property (nonatomic, strong) NSDictionary *parentTrip;
@property (nonatomic, strong) Blogs *allBlogs;

@end
