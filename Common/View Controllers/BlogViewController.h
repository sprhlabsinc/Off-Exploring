//
//  BlogViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 13/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffexConnex.h"
#import "DateViewController.h"
#import "LocationViewController.h"
#import "BodyTextViewController.h"
#import "RegionImagePickerViewController.h"
#import "Blogs.h"
#import "MBProgressHUD.h"
#import "JREngage.h"

@class BlogViewController;

#pragma mark -
#pragma mark BlogViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive notifications of changes to a Blog object.
 
	This protocol allows delegates to be given signals in relation to changes a user has made to a Blog, either on Off Exploring or
	in draft format.
 */
@protocol BlogViewControllerDelegate <NSObject>

#pragma mark Required Delegate Methods
@required

/**
	Delegate method signalled when editing on a Blog object is completed.
	@param bvc The BlogViewController object used to edit the Blog
	@param blog The Blog that was edited
 */
- (void)blogViewController:(BlogViewController *)bvc didFinishEditingBlog:(Blog *)blog;
/**
	Delegate method signalled when editing was cancelled for a Blog object
	@param bvc The BlogViewController object that was cancelled
 */
- (void)blogViewControllerDidDiscardChanges:(BlogViewController *)bvc;
/**
	Delegate method signalled when a Blog object is deleted, either from Off Exploring or in draft mode
	@param bvc The BlogViewController object that deleted the Blog
 */
- (void)blogViewControllerDidDeleteBlog:(BlogViewController *)bvc;

@end

#pragma mark -
#pragma mark BlogViewController Declaration
/**
	@brief Provides functionality to view and edit all aspects of a Blog post.
 
	This class provides functionality to display and edit an Off Exploring Blog post. It provides facilities to instantly 
	save an edit in progress (via NSUserDefaults and auto-save), more permanantly save Blog posts (via save as draft feature)
	and to publish a Blog post straight to Off Exploring. Users can set blog text, image, location, and various other key
	aspects of a blog all from this super controller. This class integrates a multitude of delegates in order to provide and 
	gain access to a variety of editing functionality. The class uses a UITableView to display Blog information and so sets
	itself as Delegate and Data Source appropriately.  The class downloads and uploads information to Off Exploring, and so
	implements an OffexploringConnection Delegate, and an MBProgressHUD delegate to display a loader during this time.
	The class implements the DateViewController Delegate methods so that the date the Blog post is in regards to can be edited.
	The class gains a variety of mapping and geolocation functionality from the LocationViewController Delegate methods so 
	the blog can have its latitude, longitude, location name and country name set.  The class implements the BodyTextViewController
	Delegate to edit the core body of the Blog text. It also may optionally set itself as its own delegate if switching between
	viewing and editing modes of a Blog.  It adopts a variety of UIKits own Delegates to handle alert and information messages,
	as well as making sure display alignement and format is correct. Finally it implements a RegionImagePickerView Delegate and
	an UIImagePickerViewController Delegate for the selection of an associate Blog image.
 */
@interface BlogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, OffexploringConnectionDelegate, MBProgressHUDDelegate,
													DateViewControllerDelegate, LocationViewControllerDelegate, BodyTextViewControllerDelegate, 
														UINavigationBarDelegate, UIAlertViewDelegate, BlogViewControllerDelegate, UIActionSheetDelegate,
															UIImagePickerControllerDelegate, UINavigationControllerDelegate, RegionImagePickerViewControllerDelegate,
																ImageLoaderDelegate, JREngageSharingDelegate>
{

	/**
		The delegate that receives messages in regards to updates to the Blog currently being viewed
	 */
	id <BlogViewControllerDelegate> __weak delegate;
	/**
		The array of all the blogs in the trip the Blog currently being viewed belongs to
	 */
	Blogs *allBlogs;
	/**
		The Blog currently being viewed
	 */
	Blog *blog;
	/**
		A flag to set the page display and operation into editing mode
	 */
	BOOL editing;
	/**
		A flag to set if on view controller viewDidLoad the Blog object is instantly posted
	 */
	BOOL autoPost;
	/**
		A button signalling the users intention to save or post a Blog
	 */
	UIBarButtonItem *save;
	/**
		A button signalling the users internet to cancel all changes made to the blog, and revert to any previously saved ones
	 */
	UIBarButtonItem *cancel;
	/**
		A button allowing the user to switch between view and edit modes on a blog
	 */
	UIBarButtonItem *edit;
	/**
		A button allowing the user to delete a blog, or if it is draft, auto publish it
	 */
	UIButton *deleteBlog;
	/**
		A pointer to the navigation bar so the title can be changed
	 */
	UINavigationBar *navBar;
	/**
		An indicatorView to display when downloading Blog body text
	 */
	UIActivityIndicatorView *activityIndicator;
	/**
		A view encapsulating the navigation bar and top elements
	 */
	UIView *topView;
	/**
		A view encapsulating the main view, tableview and sub elements
	 */
	UIView *mainView;
	/**
		The tablview Blog information is displayed in
	 */
	UITableView *tableView;
	/**
		A dictionary that contains data used in an auto-save triggered by home button press or phone call
	 */
	NSMutableDictionary *autoSavedBlog;
	/**
		A pointer to the current trip an autosaved blog belongs to
	 */
	NSDictionary *tempTrip;
	
@private
	/**
		A connection to Off Exploring to download Blog data, and upload new / edited Blogs
	 */
	OffexConnex *connex;
	/**
		An NSOperationQueue used to spawn concurrent threads to download blog images
	 */
	NSOperationQueue *saveImageQueue;
	/**
		A temporary container for a UIImage currently chosen to store as part of a Blog, that has not had its changes saved yet
	 */
	UIImage *tempThumb;
	/**
		A temporary container for the Blog body text on an unsaved Blog.
	 */
	NSString *tempBody;
	/**
		A temporary container for the URI of an image to used on an unsaved Blog.
	 */
	NSString *tempImageURI;
	/**
		A temporary container for the Blog state name on an unsaved Blog.
	 */
	NSDictionary *tempState;
	/**
		A temporary container for the Blog area name on an unsaved Blog.
	 */
	NSDictionary *tempArea;
	/**
		A temporary container for the Blog geolocation information on an unsaved Blog.
	 */
	NSDictionary *tempGeolocation;
	/**
		A temporary container for the Blog date reference
	 */
	int tempDate;
	/**
		A single pickerView used to pick images from an IOS device to use as part of a Blog post
	 */
	UIImagePickerController *pickerView;
	/**
		A loader to display when downloading or uploading information to Off Exploring
	 */
	MBProgressHUD *HUD;
	/**
		A flag to say wether an image saved on the phone should be saved to a users library
	 */
	BOOL saveToLibrary;
	/**
		A flag to say wether remote data has been downloaded from Off Exploring
	 */
	BOOL downloadedData;
	/**
		A flag to say wether an Image needs to be POSTed to Off Exploring, if not the photo is expect to already be present.
	 */
	BOOL postImage;
}

#pragma mark IBActions
/**
	Action singalling a users wish to start editing the currently viewed Blog
 */
- (IBAction)beginEditing;
/**
	Action signalling a users wish to cancel editing the currently viewed Blog
 */
- (IBAction)cancelButton;
/**
	Action signalling a users wish to save / commit changes to the currently viewed Blog
 */
- (IBAction)saveButton;
/**
	Action signalling a users wish to delete the current Blog
 */
- (IBAction)deleteBlogButton;
/**
    Action signalling a users wish to view the current Blog's comments
 */
- (IBAction)commentsButtonPressed:(id)sender;

#pragma mark Publishing Methods
/**
	Method to instantly publish a Blog
 */
- (void)autoPublish;
/**
	Method to being publishing a Blog, by either transmitting a Photo or instantly posting the content
 */
- (void)beginPosting;

#pragma mark Photo Viewing Methods
/**
	Method to show the currently attached Photo to a blog post
 */
- (void)showPhoto;

@property (nonatomic, weak) id <BlogViewControllerDelegate> delegate;
@property (nonatomic, strong) Blogs *allBlogs;
@property (nonatomic, strong) Blog *blog;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL autoPost;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *save;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *edit;
@property (nonatomic, strong) IBOutlet UIButton *deleteBlog;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *commentsButton;
@property (nonatomic, strong) NSMutableDictionary *autoSavedBlog;
@property (nonatomic, strong) NSDictionary *tempTrip;
@end
