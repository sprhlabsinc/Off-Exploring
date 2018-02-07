//
//  AlbumsTableViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "OffexConnex.h"
#import "ImageLoader.h"
#import "AlbumTableViewController.h"

#pragma mark -
#pragma mark AlbumsTableViewController Declaration
/**
 @brief A UIViewController subclass to display a list of users albums to a user
 
 This class handles all drawing and display of a users albums. It goes and fetches the list of albums
 from Off Exploring, and then once downloaded it displays those albums. Then, as the user scrolls the
 list of albums, the class uses an ImageLoader to download each cover image belonging to an album in view,
 and stores and displays that image. The class allows the selection of an album, to progress through the 
 UINavigationController heirarchy in order to select a photo form inside an album. The class also provides
 the functionality to add an album to Off Exploring from the iPhone app. The class uses a UITableView,
 setting itself as the delegate and data source to display album information. It sets itself as an
 ImageLoader delegate to receive downloaded images, a UIScrollView delegate to manage when to download remote
 images, and an OffexploringConnection delegate to receive data from Off Exploring API. Finally it sets 
 itself as an AlbumTableViewController delegate to dismiss the Album editor.
 */
@interface AlbumsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, OffexploringConnectionDelegate, ImageLoaderDelegate, UIScrollViewDelegate, AlbumTableViewControllerDelegate> {
	/**
		The tableView displaying the list of albums
	 */
	UITableView *tableView;
	/**
		The trip the albums belong to
	 */
	Trip *activeTrip;
	/**
		A button pressed to add a new album
	 */
	UIBarButtonItem	*addButton;

@private
	/**
		A connection to Off Exploring to get the list of albums
	 */
	OffexConnex *connex;
	/**
		A status flag to see if data has been downloaded and parsed or not
	 */
	BOOL downloadedData;
	/**
		A repositry of active image downloads to stop double image requests
	 */
	NSMutableDictionary *activeDownloads;
}

#pragma mark IBActions

/**
	Button press to add an Album. Opens the album editor view
 */
- (IBAction)addAlbum;

@property (nonatomic, strong) IBOutlet UIBarButtonItem	*addButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Trip *activeTrip;

@end
