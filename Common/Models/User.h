//
//  User.h
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItineraryItem.h"

/**
 @brief A Singleton Object to represent an Off Exploring User.
 
 Stores a range of information regarding an Off Exploring User, including username 
 and password for API calls. Can load information about a users itineray. Must be setFromDictionary
 to function correctly.
 */
@interface User : NSObject {

	/**
		Users username
	 */
	NSString *username;
	/**
		Users password, SHA1 encoded.
	 */
	NSString *password;
	/**
		Users name
	 */
	NSString *fullName;
	/**
		Users default language - API hardcoded to English as of 22.09.2010
	 */
	NSString *language;
	/**
		Users home country
	 */
	NSString *homeCountry;
	/**
		Users Off Exploring web address - eg http://www.offexploring.com/1phone
	 */
	NSString *webAddress;
	/**
		Users blog introduction text
	 */
	NSString *introductionText;
	/**
		Users site title
	 */
	NSString *siteTitle;
	/**
		Users date of birth
	 */
	NSDate *dateOfBirth;
	/**
		When users site was created
	 */
	NSDate *siteCreated;
	/**
		When users site was last updated
	 */
	NSDate *lastUpdated;
	/**
		The link to the image a user chose for their site profile photo
	 */
	NSString *frontImageUrl;
	/**
		A global flag to set draft mode enabled. If so, blogs will be written
		in draft mode. Requests to Albums are disabled. Stored hostels are still visible
	 */
	BOOL globalDraft;
	/**
		A global flag to say a user is currently editing a blog.
	 */
	BOOL editingBlog;
	/**
		A dictonary storing key blog information for autosave should a user close the app 
		or the phone ring etc. Retrieved when blogs section is next visited by user
	 */
	NSMutableDictionary *autoSavedBlog;
	/**
		Array of ItineraryItem objects storing a users planned journey
	 */
	NSArray *itinerary;
}

#pragma mark User Setup And Object Retrieval
/**
	Singleton object loader
	@returns The Singleton User object
 */
+ (User *)sharedUser;

/**
	Set various paramets of a user from a dictionary
 
	@param data Dictionary containting keys named fullName language homeCountry 
	webAddress introductionText siteTitle with values to set on the User
 */
- (void)setFromDictionary:(NSDictionary *)data;

#pragma mark Itinerary Methods

/**
	Loads a Users Itinerary and stores it into itinerary array
 */
- (void)loadItineraryFromDB;

/**
	Returns the next chronological ItineraryItem from [NSDate date] (now), optionally
	requiring the area property of the item be set.
	@param area Whether the area property must be set on the returned ItineraryItem
	@returns The next chronological ItineraryItem
 */
- (ItineraryItem *)nextItineraryItemWithSetArea:(BOOL)area;

#pragma mark Save and Load user info
- (void)saveUserInfo;
- (void)loadUserInfo;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *homeCountry;
@property (nonatomic, strong) NSString *webAddress;
@property (nonatomic, strong) NSString *introductionText;
@property (nonatomic, strong) NSString *siteTitle;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) NSDate *siteCreated;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSString *frontImageUrl;
@property (nonatomic, assign) BOOL globalDraft;
@property (nonatomic, assign) BOOL editingBlog;
@property (nonatomic, strong) NSMutableDictionary *autoSavedBlog;
@property (nonatomic, strong) NSArray *itinerary;
@property (nonatomic, strong) NSString *emailAddress;

@end

