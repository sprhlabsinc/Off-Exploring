//
//  RootViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffexConnex.h"
#import "MBProgressHUD.h"
#import "LoginViewController.h"
#import "constants.h"
#import <CoreLocation/CoreLocation.h>

@class AppDelegate;


#pragma mark -
#pragma mark RootViewController Interface

/**
	@brief A UIViewController Subclass that displays the home screen for the app. Links to the various pages through the app
 
	This class is the home screen of the app that users see when they first load up the app, after registration / login. Once 
	they are logged in, it is there default view. It provides links to the various jump in points on the app (view blogs, view
	albums / photos, edit settings, view hostels etc). It also regonises and handles login operations if the user changes there login details.
	It downloads a users itinerary for use as part of hostel suggestions and so sets itself as an OffexploringConnection Delegate.
	It handles what to do if there is no internet when the user loads the app, setting the blog section into editing only mode
	and disallowing access to the photo section.
 */
@interface RootViewController : UIViewController <OffexploringConnectionDelegate, UIAlertViewDelegate, MBProgressHUDDelegate,LoginViewControllerDelegate>
{
}

#pragma mark IBActions
/**
	Action signalling the user wishes to view the settings section
 */
- (IBAction)viewSettingsOrSearch;
/**
	Action signalling the user wishes to view the about section
 */
- (IBAction)viewAboutPage;
/**
	Action signalling the user wishes to view their blogs
	@param selector The button that was pressed
 */
- (IBAction)viewBlogs:(id)selector;
/**
	Action signalling the user wishes to view their photo albums
	@param selector The button that was pressed
 */
- (IBAction)viewPhotos:(id)selector;
/**
	Action signalling the user wishes to view their site on the web via mobile Safari
 */
- (IBAction)viewWebsite;

/**
    Action signalling teh user wished to view their messages
 */
- (IBAction)messagesButtonPressed:(id)sender;

- (IBAction)videosButtonPressed:(id)sender;

- (IBAction)latestBlogsButtonPressed:(id)sender;

- (IBAction)nearMeBlogsButtonPressed:(id)sender;

- (IBAction)searchBlogsButtonPressed:(id)sender;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *aboutButton;
@property (nonatomic, strong) IBOutlet UIButton *viewBlogs;
@property (nonatomic, strong) IBOutlet UIButton *viewAlbums;
@property (nonatomic, strong) IBOutlet UIButton *website;
@property (nonatomic, assign) BOOL failGracefully;

@end
