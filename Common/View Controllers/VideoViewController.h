//
//  VideoViewController.h
//  Off Exploring
//
//  Created by Ian Outterside on 06/02/2012.
//  Copyright (c) 2012 Off Exploring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"
#import "LocationViewController.h"
#import "LocationTextViewController.h"
#import "BodyTextViewController.h"
#import "OffexConnex.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@class VideoViewController;

#pragma mark -
#pragma mark VideoViewControllerDelegate Declaration
/**
 @brief Details a protocol that must be adheared to, to handle creation, editing and deletion of Videos.
 
 This protocol allows delegates to be given signals in relation to key requests made to the VideoViewController
 with reference to creation, editing and deletion of videos. The delegate is notified of the changes, however the 
 processing of the changes takes place in the VideoViewController. Also provides optional overrides for the delegate
 in order to specifiy if this View Controller is editing or creating an video.
 */

@protocol VideoViewControllerDelegate <NSObject>

#pragma mark Required Delegate Methods
@required

/**
 Delegate method called when a successful edit of an Video takes place, returning the Video to the delegate
 @param vvc The VideoViewController used to perform the edits
 @param video The edited Video
 */
- (void)videoViewController:(VideoViewController *)vvc didEditVideo:(Video *)video;
/**
 Delegate method called when a sucessful delete of an Video takes place, returning the Video to the delegate
 @param vvc The VideoViewController used to delete the Video
 @param video The deleted Video
 */
- (void)videoViewController:(VideoViewController *)vvc didDeleteVideo:(Video *)video;
/**
 Delegate method called when a user presses the cancel button on the View
 @param vvc The VideoViewController firing the event
 */
- (void)videoViewControllerDidCancel:(VideoViewController *)vvc;

#pragma mark Optional Delegate Methods
@optional

/**
 Delegate method providing delegates the option to change the page title of the ViewController - 
 used if creating instead of editing an video
 @param vvc The VideoViewController firing the event
 @param video The Video being edited
 @returns The string title to set upon the VideoViewController;
 */
- (NSString *)titleForVideoViewController:(VideoViewController *)vvc editingVideo:(Video *)video;

/**
 Delegate method providing delegates the option to not display the delete button on the ViewController - 
 used if creating instead of editing an video
 @param vvc The VideoViewController firing the event
 @param video The Video being edited
 @returns The boolean display status of the delete button on the VideoViewController
 */
- (BOOL)deleteButtonShouldDisplayForVideoViewController:(VideoViewController *)vvc editingVideo:(Video *)video;

@end

@interface VideoViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, LocationViewControllerDelegate, 
LocationTextViewControllerDelegate, OffexploringConnectionDelegate, UIActionSheetDelegate,
MBProgressHUDDelegate, BodyTextViewControllerDelegate> 
{
	/**
     VideoViewController delegate to recieve notifcations of changes to an video, and to query for display information
	 */
	id <VideoViewControllerDelegate> __weak delegate;
	/**
     A button pressed to signal changes complete
	 */
	UIBarButtonItem *done;
	/**
     A button pressed to signal cancel changes
	 */
	UIBarButtonItem *cancel;
	/**
     A UITableView to display Video information
	 */
	UITableView *tableView;
	/**
     A button pressed to signal video deletion
	 */
	UIButton *deleteVideo;
	/**
     The video having its changes made
	 */
	Video *activeVideo;
	/**
     A pointer to the navigation bar, so its title can be changed
	 */
	UINavigationBar *navBar;
	
@private
	/**
     A temporary store to hold a new Video title
	 */
	NSString *changeTitle;
    /**
     A temporary store to hold a new Video description
	 */
	NSString *changeDescription;
	/**
     A temporary store to hold a new Video state
	 */
	NSString *changeState;
	/**
     A temporary store to hold a new Video area
	 */
	NSString *changeArea;
	/**
     A temporary store to hold a new Video geolocation
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
 Button pressed to mark completeion of changes to an Video
 */
- (IBAction)donePressed;
/**
 Button pressed to mark cancellation of changes to an Video
 */
- (IBAction)cancelPressed;
/**
 Button pressed to mark deletion of an Video
 */
- (IBAction)deleteVideoPressed;

@property (nonatomic, weak) id <VideoViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *done;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *deleteVideo;
@property (nonatomic, strong) Video *activeVideo;



@end
