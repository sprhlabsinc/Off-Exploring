//
//  UserInfoViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 21/05/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserInfoViewController;

#pragma mark -
#pragma mark UserInfoViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a notification that a user wishes to dismiss the UserInfoViewController
 
	This protocol allows delegates to be messaged when the user of the app wishes to dismiss the UserInfoViewController. Delegates are
	expected to dismiss the UserInfoViewController.
 */
@protocol UserInfoViewControllerDelegate <NSObject>

@required

/**
	Delegate method called when the user wishes to dismiss the UserInfoViewController view
	@param userInfo The UserInfoViewController to dismiss
 */
- (void)userInfoViewControllerDidDismiss:(UserInfoViewController *)userInfo;

@end

#pragma mark -
#pragma mark UserInfoViewController Interface

/**
	@brief A UIViewController Subclass that displays to the user key features of the app
 
	This class displays a simple image detailing all of the features of the app to a user that is using it for the first time. It is
	only ever displayed again if the user is not logged in when the app is closed.
 */
@interface UserInfoViewController : UIViewController {
	
	/**
		Delegate told to dismiss the view
	 */
	id <UserInfoViewControllerDelegate> __weak delegate;
	
}

#pragma mark IBActions
/**
	Action signalling the user wishes to dismiss the view
 */
- (IBAction)dismiss;

@property (nonatomic, weak) id <UserInfoViewControllerDelegate> delegate;

@end
