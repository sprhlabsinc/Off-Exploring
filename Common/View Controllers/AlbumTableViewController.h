//
//  AlbumTableViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 05/05/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "LocationViewController.h"
#import "LocationTextViewController.h"
#import "OffexConnex.h"
#import "MBProgressHUD.h"

@class AlbumTableViewController;

#pragma mark -
#pragma mark AlbumTableViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, to handle creation, editing and deletion of Albums.
 
	This protocol allows delegates to be given signals in relation to key requests made to the AlbumTableViewController
	with reference to creation, editing and deletion of albums. The delegate is notified of the changes, however the 
	processing of the changes takes place in the AlbumTableViewController. Also provides optional overrides for the delegate
	in order to specifiy if this View Controller is editing or creating an album.
 */
@protocol AlbumTableViewControllerDelegate <NSObject>

#pragma mark Required Delegate Methods
@required

/**
	Delegate method called when a successful edit of an Album takes place, returning the Album to the delegate
	@param atvc The AlbumTableViewController used to perform the edits
	@param album The edited Album
 */
- (void)albumTableViewController:(AlbumTableViewController *)atvc didEditAlbum:(Album *)album;
/**
	Delegate method called when a sucessful delete of an Album takes place, returning the Album to the delegate
	@param atvc The AlbumTableViewController used to delete the Album
	@param album The deleted Album
 */
- (void)albumTableViewController:(AlbumTableViewController *)atvc didDeleteAlbum:(Album *)album;
/**
	Delegate method called when a user presses the cancel button on the View
	@param atvc The AlbumTableViewController firing the event
 */
- (void)albumTableViewControllerDidCancel:(AlbumTableViewController *)atvc;

#pragma mark Optional Delegate Methods
@optional

/**
	Delegate method providing delegates the option to change the page title of the ViewController - 
	used if creating instead of editing an album
	@param atvc The AlbumTableViewController firing the event
	@param album The Album being edited
	@returns The string title to set upon the AlbumTableViewController;
 */
- (NSString *)titleForAlbumTableViewController:(AlbumTableViewController *)atvc editingAlbum:(Album *)album;
/**
	Delegate method providing delegates the option to not display the delete button on the ViewController - 
	used if creating instead of editing an album
	@param atvc The AlbumTableViewController firing the event
	@param album The Album being edited
	@returns The boolean display status of the delete button on the AlbumTableViewController
 */
- (BOOL)deleteButtonShouldDisplayForAlbumTalbeViewController:(AlbumTableViewController *)atvc editingAlbum:(Album *)album;

@end

#pragma mark -
#pragma mark AlbumTableViewController Declaration

/**
	@brief Displays a view able to edit information about an album. Handles editing and deletion of an album
 
	This class allows for the creation, editing and deletion of an Album, by providing editable sections for key aspects of an
	Album. The class reflects these changes upon the user pressing the "Done" button and firing the IBAction donePressed - and 
	then notifies its delegate of the changes. If the IBAction cancelPressed fires, the delegate is informed is informed. The 
	class uses a UITableView, setting itself as the delegate and data source to display album information. It sets itself as
	a LocationViewController delegate so that users can set a location for the album. It sets itself as a OffexploringConnection
	delegate so it can reflect changes made to albums on the Off Exploring API. Finally, it sets itself as an ActionSheet delegate
	to prompt users of important actions and handle selections as appropriate, and sets itself as an MBProgressHUDDelegate to 
	display a loader during Off Exploring API requests.
 */
@interface AlbumTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LocationViewControllerDelegate, 
														LocationTextViewControllerDelegate, OffexploringConnectionDelegate, UIActionSheetDelegate,
														MBProgressHUDDelegate> 
{
	/**
		AlbumTableViewController delegate to recieve notifcations of changes to an album, and to query for display information
	 */
	id <AlbumTableViewControllerDelegate> __weak delegate;
	/**
		A button pressed to signal changes complete
	 */
	UIBarButtonItem *done;
	/**
		A button pressed to signal cancel changes
	 */
	UIBarButtonItem *cancel;
	/**
		A UITableView to display Album information
	 */
	UITableView *tableView;
	/**
		A button pressed to signal album deletion
	 */
	UIButton *deleteAlbum;
	/**
		The album having its changes made
	 */
	Album *activeAlbum;
	/**
		A pointer to the navigation bar, so its title can be changed
	 */
	UINavigationBar *navBar;
	
@private
	/**
		A temporary store to hold a new Album name
	 */
	NSString *changeName;
	/**
		A temporary store to hold a new Album state
	 */
	NSString *changeState;
	/**
		A temporary store to hold a new Album area
	 */
	NSString *changeArea;
	/**
		A temporary store to hold a new Album geolocation
	 */
	NSDictionary *changeGeolocation;
	/**
		A connection to Off Exploring to update it with changes
	 */
	OffexConnex *connex;
	/**
		A utility loading view to display whilst making remote requests
	 */
	MBProgressHUD *HUD;
}

#pragma mark IBActions
/**
	Button pressed to mark completeion of changes to an Album
 */
- (IBAction)donePressed;
/**
	Button pressed to mark cancellation of changes to an Album
 */
- (IBAction)cancelPressed;
/**
	Button pressed to mark deletion of an Album
 */
- (IBAction)deleteAlbumPressed;

@property (nonatomic, weak) id <AlbumTableViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *done;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *deleteAlbum;
@property (nonatomic, strong) Album *activeAlbum;

@end
