//
//  RegistrationViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 11/05/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "LocationTextViewController.h"
#import "DateViewController.h"
#import "BodyTextViewController.h"
#import "OffexConnex.h"
#import "RegionImagePickerViewController.h"
#import "MBProgressHUD.h"
#import "LoginViewControllerJRAuthDelegate.h"

@class RegistrationViewController;

#pragma mark -
#pragma mark RegistrationViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a notification that a new user registered to Off Exploring
 
	This protocol allows delegates to be messaged when the user of the app has completed a registration to Off Exploring, and returns
	to them the new username and password they registered with. It also notifys the delegate when the user wishes to cancel registration.
 */
@protocol RegistrationViewControllerDelegate <NSObject>
#pragma mark Required Delegate Methods
@required

/**
	Delegate method messaged when the user completes a registration to Off Exploring
	@param rvc The RegistrationViewController object they used to register with
	@param username The username they registered with
	@param password The password they registered with
 */
- (void)registrationViewController:(RegistrationViewController *)rvc didRegisterUserWithUsername:(NSString *)username andPassword:(NSString *)password;
/**
	Delegate method messaged when the user wishes to cancel registration
	@param rvc The RegistrationViewController object to dismiss
 */
- (void)registrationViewControllerDidCancel:(RegistrationViewController *)rvc;

- (void)showJanrainAuthenticationWithCallbackDelegate:(id <LoginViewControllerJRAuthDelegate>)jrAuthDelegate;

@end

#pragma mark -
#pragma mark RegistrationViewController Interface

/**
	@brief A UIViewController Subclass that allows users to enter various registration information and perform a registration to Off Exploring
 
	This class provides an interface to enter various registration information including a username, password, name, dob, email etc
	and perform a registration to Off Exploring. It handles various registration errors and notifies its delegate upon successful registration.
	It displays the various registration information in a UITableView and so sets itself as a delegate and data source appropriately. To handle
	some text input, it uses UITextField objects and so sets itself as a delegate for those. For other free text entry sections, it customises
	a LocationTextViewController and BodyTextViewController via the delegate methods. To set the date of birth, it uses a DateViewController and 
	sets itself as delegate. As part of registration, a default user image is needed, and display for this is provided by the RegionImagePickerViewController
	and its delegate.  Finally to make connections to Off Exploriong to actually perform the registration, it uses an OffexploringConnecton 
	delegate and displays an MBProgressHUD during this connection.
 */
@interface RegistrationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, 
														LocationTextViewControllerDelegate, DateViewControllerDelegate, BodyTextViewControllerDelegate, 
														OffexploringConnectionDelegate, RegionImagePickerViewControllerDelegate, MBProgressHUDDelegate, 
														LoginViewControllerJRAuthDelegate> 
{
	/**
		Delegate messaged on successful login
	 */
	id <RegistrationViewControllerDelegate> __weak delegate;
	/**
		Button used to confirm registration
	 */
	UIBarButtonItem *done;
	/**
		Button used to cancel registration
	 */
	UIBarButtonItem *cancel;
	/**
		UITableView displaying registration information
	 */
	UITableView *table;
@private
	/**
		Temporary store for the users name
	 */
	NSString *changeName;
	/**
		Temporary store fo the users site title
	 */
	NSString *changeTitle;
	/**
		Temporary store for the users date of birth
	 */
	NSDate *dateOfBirth;
	/**
		Temporary store for the users welcome message
	 */
	NSString *welcomeMessage;
	/**
		Temporary store for the users email address
	 */
	NSString *email;
	/**
		Temporary store for the users username
	 */
	NSString *username;
	/**
		Temporary store for the users password
	 */
	NSString *password;
	/**
		Temporary store for the users password for validation
	 */
	NSString *passwordRetype;
	/**
		Temporary store for the address of the users site image
	 */
	NSString *frontImage;
	/**
		Temporary store for the caption for the image that was selected
	 */
	NSString *imageCaption;
	/**
		Loader to display during remote requests
	 */
	MBProgressHUD *HUD;
	
	/**
		Used as a flag to say this is a social sign in request
	 */
	BOOL socialRegistration;
	
	/**
		The social provider being registered with (eg Facebook)
	*/
	NSString *socialProvider;
	
	/**
		The social identifier being registered with
	*/
	NSString *socialIdentifier;
}

#pragma mark IBActions
/**
	Action signalling the user wishes to register
 */
- (IBAction)donePressed;
/**
	Action signalling the user wishes to cancel registration
 */
- (IBAction)cancelPressed;

- (void)setSocialRegistrationDetailsWithUsername:(NSString *)dfUsername 
										   email:(NSString *)dfEmail 
									 dateOfBirth:(NSString *)dfDateOfBirth 
										fullName:(NSString *)dfFullName 
									 remoteImage:(NSString *)dfRemoteImageURL 
									  identifier:(NSString *)dfIndentifier 
										provider:(NSString *)dfProvider;

@property (nonatomic, weak) id <RegistrationViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *done;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
@property (nonatomic, strong) IBOutlet UITableView *table;

@end
