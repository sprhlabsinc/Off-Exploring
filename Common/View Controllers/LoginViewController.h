//
//  LoginViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 06/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffexploringLogin.h"
#import "RegistrationViewController.h"
#import "UserInfoViewController.h"
#import "MBProgressHUD.h"
#import "JREngage.h"
#import "Constants.h"
#import "MergeViewController.h"
#import "LoginViewControllerJRAuthDelegate.h"

@class LoginViewController;

#pragma mark -
#pragma mark LoginViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a notification that a user has logged in.
 
	This protocol allows delegates to be messaged when the user of the app has completed a login to Off Exploring, and returns
	to them the new username and password they logged in with. 
 */
@protocol LoginViewControllerDelegate <NSObject>

@required

/**
	Deleagate method messaged when a user logs in to Off Exploring
	@param login The LoginViewController object used to log in with
	@param username The username that was logged in with
	@param password The password that was logged in with
 */
- (void)loginViewController:(LoginViewController *)login didLoginWithUsername:(NSString *)username andPassword:(NSString *)password;

- (void)loginViewControllerDidCancel:(LoginViewController *)login;

@end

#pragma mark -
#pragma mark LoginViewController Interface

/**
	@brief A UIViewController Subclass that allows users to enter login information and perform a login to Off Exploring
 
	This class provides an interface to enter login information - a username, password and perform a login to Off Exploring. 
	It handles various login errors and notifies its delegate upon successful login. It displays the login information 
	in a UITableView and so sets itself as a delegate and data source appropriately. To handle text input, it uses UITextField 
	objects and so sets itself as a delegate for those. To display errors it uses a UIAlertView, and to make connections to 
	Off Exploriong to actually perform the login, it uses an OffexploringConnecton delegate and displays an MBProgressHUD during this connection.
 */
@interface LoginViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, 
													UIAlertViewDelegate, RegistrationViewControllerDelegate, MBProgressHUDDelegate,
													OffexploringLoginDelegate, JREngageSigninDelegate, MergeViewControllerDelegate,
													LoginViewControllerJRAuthDelegate> 
{

	/**
		Delegate that is messaged on successful login
	 */
	id <LoginViewControllerDelegate> __weak delegate;
	
	/**
		Delegate that is messaged on successful social sign in
	 */
	id <LoginViewControllerJRAuthDelegate> __weak _jrauthdelegate;
	
	/**
		TableView displaying the login information
	 */
	UITableView *theTableView;
	/**
		A button to press to being a login attemp
	 */
	UIBarButtonItem *saveButton;
	/**
		A button to press to fill out a new registration form
	 */
	UIBarButtonItem *registerUser;
	/**
		An OffexploringLogin object used to handle various login manipulations and hashing
	 */
	OffexploringLogin *offex;
	/**
		A loader to display whilst making remote login requests
	 */
	MBProgressHUD *HUD;
	/**
		The username to login with
	 */
	NSString *usedUsername;
	/**
		The password to login with
	 */
	NSString *usedPassword;

	/**
	
	 */
	NSDictionary *authData;
}

#pragma mark IBActions
/**
	Action signalling the user wishes to register for Off Exploring
 */
- (IBAction)attemptRegister;
/**
	Action signalling the user wishes to login to Off Exploring using the entered details
 */
- (IBAction)attemptLogin;
- (IBAction)cancelButtonPressed:(id)sender;

@property (nonatomic, weak) id <LoginViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *theTableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) OffexploringLogin *offex;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *registerUser;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, weak) id <LoginViewControllerJRAuthDelegate> jrauthdelegate;

@end
