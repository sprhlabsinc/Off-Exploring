//
//  OffexploringLogin.h
//  Off Exploring
//
//  Created by Off Exploring on 19/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OffexConnex.h"

@class OffexploringLogin;

#pragma mark -
#pragma mark OffexploringLoginDelegate Declaration

/**
 @brief Details a protocol that must be adheared to, in order to receive information about login events to Off Exploring
 
 This protocol allows delegates to be informed if a user was successfully logged in to Off Exploring, or if that login 
 attempt failed. 
 */
@protocol OffexploringLoginDelegate <NSObject>

@required

#pragma mark Required Delegate Methods
/**
	Delegate method is called upon successful login to Off Exploring, returning the login details used
	@param login The OffexploringLogin object used to login with
	@param username The username used to login with
	@param password The password used to login with
 */
- (void)offexploringLogin:(OffexploringLogin *)login didLoginWithUsername:(NSString *)username andPassword:(NSString *)password;
/**
	Delegate method is called upon failed login attempt to login to Off Exploring.
	@param login The OffexploringLogin object used to attempt the login.
 */
- (void)offexploringLoginFailed:(OffexploringLogin *)login;

/**
	Delegate method is called upon failed login attempt to login to Off Exploring.
	@param login The OffexploringLogin object used to attempt the login.
	@param string The error message
 */
- (void)offexploringLoginFailed:(OffexploringLogin *)login withMessage:(NSString *)string;

@end

#pragma mark -
#pragma mark OffexploringLogin Declaration

/**
 @brief Provides functionality to authorise a user with the Off Exploring API, by providing a username and password
 
 This class handles initial login to Off Exploring. It takes a username and password string, and appropriate encodes
 the password into a SHA1 hash key, for transmittion over the internet. An API login request is then made to Off Exploring,
 and a status is returned. This return state is then passed back to the delegate of the class for appropriate handling.
 Sets itself as an OffexploringConnectionDelegate to make remote login requests to the server
 */
@interface OffexploringLogin : NSObject <OffexploringConnectionDelegate>{
	/**
		A OffexploringLoginDelegate object to be passed return statuses of remote login requests 
	 */
	id <OffexploringLoginDelegate> __weak delegate;
	/**
		The username to be used in the login request
	 */
	NSString *username;
	/**
		The password to be used in the login request
	 */
	NSString *password;
}

#pragma mark Login Handling Methods
/**
	Starts a login request to Off Exploring using a given username and password
	@param theUsername The username to login with
	@param thePassword The password to login with
 */
- (void)attemptOffexploringAuthorisationWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword;
/**
 Returns a dictionary containing the username and password used to log in to Off Exploring
 @returns The login details dictionary
 */
- (NSDictionary *)offexploringLoginDetails;
/**
	Logs the user out of the app by removing their NSUserDefaults login details
 */
- (void) logOut;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, weak) id <OffexploringLoginDelegate> delegate;


@end
