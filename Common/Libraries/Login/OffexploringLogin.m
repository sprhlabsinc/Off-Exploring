//
//  OffexploringLogin.m
//  Off Exploring
//
//  Created by Off Exploring on 19/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "OffexploringLogin.h"
// Sha1 Hash function is in this library
#import <CommonCrypto/CommonHMAC.h>

#pragma mark -
#pragma mark OffexploringLogin Private Interface
/**
	@brief Private method used in the implementation of remote login.
 
	This interface allows login information to be stored into NSUserDefaults for quick retrieval when
	making remote API requests to Off Exploring.
 */
@interface OffexploringLogin()

#pragma mark Private Method Declarations
/**
	Saves a given username and password to NSUserDefaults for retrieval later
	@param theUsername The username to store
	@param thePassword The password to store
 */
- (void)saveOffexploringUsername:(NSString *)theUsername andPassword:(NSString *)thePassword;

@end

#pragma mark -
#pragma mark OffexploringLogin Implementation

@implementation OffexploringLogin

@synthesize username;
@synthesize password;
@synthesize delegate;


#pragma mark Login Handling Methods

// Hash the entered password into SHA1 to match Offexploring, connect to offexploring and attempt authorisation
- (void)attemptOffexploringAuthorisationWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword {
	
	NSString *hashkey = thePassword;
	// PHP uses ASCII encoding, not UTF
	const char *s = [hashkey cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
	/// This is the destination
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	// This one function does an unkeyed SHA1 hash of your hash data
	CC_SHA1(keyData.bytes, keyData.length, digest);
	// Now convert to NSData structure to make it usable again
	NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
	// description converts to hex but puts <> around it and spaces every 4 bytes
	NSString *hash = [out description];
	hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
	
	self.username = [theUsername lowercaseString];
	self.password = hash;
	
	OffexConnex *connex = [[OffexConnex alloc] init];
	[connex setDelegate:self];
	NSString *urlString = [connex buildAuthenticatedOffexRequestStringWithURI:@"user/authenticate" andUsername:theUsername andPassword:hash];
	[connex beginLoadingOffexploringDataFromURL:urlString];
}

// Loads stored login details and returns them
- (NSDictionary *)offexploringLoginDetails {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *dictionary = [prefs dictionaryForKey:@"login"];
	return dictionary;
}

-  (void)logOut {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs removeObjectForKey:@"login"];
	[prefs synchronize];
}

#pragma mark Private Method

// Saves a valid username and password into NSUserDefaults
- (void)saveOffexploringUsername:(NSString *)theUsername andPassword:(NSString *)thePassword {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:theUsername, @"username", thePassword, @"password", nil];
	[prefs setObject:dictionary forKey:@"login"];
	[prefs synchronize];
}

#pragma mark OffexploingConnectionDelegate Methods

- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	if ([results[@"response"][@"status"] isEqualToString:@"success"]) {
		[self saveOffexploringUsername:self.username andPassword:self.password];
		//Login success
		[delegate offexploringLogin:self didLoginWithUsername:self.username andPassword:self.password];
	}
	else {
		self.username = nil;
		self.password = nil;
		//Login failed
		[delegate offexploringLoginFailed:self];
	}
	
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	self.username = nil;
	self.password = nil;
	
	if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"Incorrect Partner Request"]) {
		[delegate offexploringLoginFailed:self withMessage:[NSString stringWithFormat:@"Sorry, this is not an %@ account.", [NSString partnerDisplayName]]];
	}
	else {
		//Login failed
		[delegate offexploringLoginFailed:self withMessage:[NSString stringWithFormat:@"Unable to connect to %@. Please retry.", [NSString partnerDisplayName]]];
	}
}

@end
