//
//  LoginViewControllerJRAuthDelegate.h
//  Off Exploring
//
//  Created by Off Exploring on 16/08/2011.
//  Copyright 2011 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LoginViewController;

#pragma mark -
#pragma mark LoginViewControllerJRAuthDelegate Declaration
/**
 @brief Details a protocol that must be adheared to, in order to handle when Janrain makes a successful authorization with Off Exploring.
 
 This protocol allows delegates to be messaged when the user of the app has completed a login to a social provider via Janrain, with the aim
 of authorizing Off Exploring
 */
@protocol LoginViewControllerJRAuthDelegate <NSObject>

@required

/**
 Delegate method messaged when a user logs in to Social Sign in
 */
- (void)loginViewController:(LoginViewController *)login 
jrAuthenticationDidReachTokenUrl:(NSString*)tokenUrl
			   withResponse:(NSURLResponse*)response
				 andPayload:(NSData*)tokenUrlPayload
				forProvider:(NSString*)provider
				   authInfo:(NSDictionary *)authInfo;

@end