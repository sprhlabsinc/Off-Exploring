//
//  SettingsViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 06/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "RootViewController.h"
#import "CurrencyPreferenceViewController.h"
#import "ImageLoader.h"
#import "MBProgressHUD.h"

#pragma mark -
#pragma mark SettingsViewController Interface

/**
	@brief A UIViewController Subclass that allows users to set key settings and perform maintainance for the app
 
	This class provides an interface to change settings on the app including the default currency, and to logout and 
	switch username. It also provides the ability to reset saved images that are cached in case of downloading 
	errors. Class sets itself as a CurrencyPreferenceViewController Delegate to handle changes to the default currency.
 */
@interface SettingsViewController : UIViewController <CurrencyPreferenceViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, ImageLoaderDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, UINavigationControllerDelegate>{

	/**
		A pointer to the RootViewController to return to when changes complete
	 */
    MBProgressHUD *HUD;
}

#pragma mark IBActions
/**
	Action signalling the users wish to dismiss the settings page
 */
- (IBAction)exitSettings;
/**
	Action signalling the users wish to log out from the current account
 */
- (IBAction)logout;
/**
	Action signalling the user wishes to view their site on the web via mobile Safari
 */
- (IBAction)viewWebsite;
/**
	Action signalling the users wish to clear temporary images
 */
- (IBAction)clearImages;
/**
	Action singalling the users wish to change the default currency
 */
- (IBAction)changeCurrency;
/**
 Action singalling the users wish to save and exit
 */
- (IBAction)saveButtonPressed:(id)sender;

@property (nonatomic, assign) RootViewController *root;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end
