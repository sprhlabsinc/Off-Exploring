//
//  User.m
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "User.h"
#import "DB.h"
#import "ItineraryItem.h"

#define kUsernameKey        @"username"
#define kFullNameKey        @"fullName"
#define kLanguageKey        @"language"
#define kHomeCountryKey     @"homeCountry"
#define kWebAddress         @"webAddress"
#define kIntroductionText   @"introductionText"
#define kSiteTitle          @"siteTitle"
#define kFrontImageUrl      @"frontImageUrl"
#define kEmailAddress       @"emailAddress"

@interface User()
- (NSString *)flattenHTML:(NSString *)html;
@end

@implementation User

static User *sharedGizmoManager = nil;

@synthesize username;
@synthesize fullName;
@synthesize language;
@synthesize homeCountry;
@synthesize webAddress;
@synthesize introductionText;
@synthesize siteTitle;
@synthesize dateOfBirth;
@synthesize siteCreated;
@synthesize lastUpdated;
@synthesize frontImageUrl;
@synthesize globalDraft;
@synthesize password;
@synthesize autoSavedBlog;
@synthesize editingBlog;
@synthesize itinerary;
@synthesize emailAddress;

#pragma mark User Setup And Object Retrieval
+ (User *)sharedUser {
    if (sharedGizmoManager == nil) {
        sharedGizmoManager = [[super allocWithZone:NULL] init];
    }
    return sharedGizmoManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedUser];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)setFromDictionary:(NSDictionary *)data {
	self.fullName = data[@"fullName"];
	self.language = data[@"language"];
	self.homeCountry = data[@"homeCountry"];
	self.webAddress = data[@"webAddress"];
	self.introductionText = [self flattenHTML:data[@"introductionText"]];
	self.siteTitle = data[@"siteTitle"];
    self.emailAddress = data[@"emailAddress"];
    self.frontImageUrl = data[@"frontImages"][@"frontImage"][0];
    // Load the background image
}

#pragma mark Itinerary Methods

- (void)loadItineraryFromDB {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	double lastItineraryLookup = [prefs doubleForKey:@"lastItineraryLookup"];
	
	NSTimeInterval todaysDiff = [[NSDate date] timeIntervalSince1970];
	NSTimeInterval dateDiff = todaysDiff - lastItineraryLookup;
	int days = dateDiff / 86400;
	
	if (days < 5) {
	
		DB *db = [DB sharedDB];
		sqlite3_stmt *select_statement = nil;
		
		NSMutableArray *itemList = [[NSMutableArray alloc] init];
		
		if (select_statement == nil) {
			
			const char *sql = "SELECT * FROM user_itinerary WHERE username = ? ORDER BY timestamp, id ASC";
			
			if (sqlite3_prepare_v2(db.database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
				select_statement = nil;
				//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
			}
			
			sqlite3_bind_text(select_statement, 1,[self.username UTF8String], -1, SQLITE_TRANSIENT);
			
			if (select_statement != nil) {
				while (sqlite3_step(select_statement) == SQLITE_ROW) {
					
					NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
					NSTimeInterval expiry = sqlite3_column_int(select_statement,8);
					
					// Check data still valid
					if (expiry < now) {
						return;
					}
					
					NSNumber *itemid = @(sqlite3_column_int(select_statement, 0));
					NSNumber *timestamp = @(sqlite3_column_int(select_statement, 2));
					NSString *state = @((char *) sqlite3_column_text(select_statement, 3));
					NSString *area = @((char *) sqlite3_column_text(select_statement, 4));
					NSNumber *latitude = @(sqlite3_column_double(select_statement, 5));
					NSNumber *longitude = @(sqlite3_column_double(select_statement, 6));
					
					/* will be neeeded in future, not at present */
					//NSNumber *trip = [NSNumber numberWithInt:sqlite3_column_int(select_statement, 7)];
					
					NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:itemid, @"id", timestamp, @"timestamp", 
										  state, @"state", area, @"area", latitude, @"latitude", longitude, @"longitude", nil];
					ItineraryItem *aItem = [[ItineraryItem alloc] initWithDictionary:dict];
					[itemList addObject:aItem];
					
				}
			}
		}
		
		sqlite3_reset(select_statement);
		if ([itemList count] > 0) {
            NSArray *itemListArray = [[NSArray alloc] initWithArray:itemList];
			self.itinerary = itemListArray;
		}

	}
}

- (ItineraryItem *)nextItineraryItemWithSetArea:(BOOL)area {
	if (!self.itinerary) {
		[self loadItineraryFromDB];
	}
	
	if (!self.itinerary) {
		return nil;
	}
	
	NSDate *now = [NSDate date];
	
	ItineraryItem *theItem = nil;
	
	for (ItineraryItem *item in self.itinerary) {
		
		if (area && !item.area) {
			continue;
		}
		
		if (theItem == nil) {
			theItem = item;
			continue;
		}
		
		int nowTime = [now timeIntervalSince1970];
		
		int margin1 = nowTime - item.timestamp;
		int margin2 = nowTime - theItem.timestamp;
		
		if (margin1 < 0 && margin2 > 0) {
			theItem = item;
			continue;
		}
		else if (margin2 < 0 && margin1 > 0) {
			continue;
		}
		
		if (margin1 > 0) {
			if (margin1 < margin2) {
				theItem = item;
				continue;
			}
		}
		else if (margin1 < 0) {
			if (margin1 > margin2) {
				theItem = item;
				continue;
			}
		}
	}

	return theItem;
}

- (NSString *)flattenHTML:(NSString *)html {
	
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
											   withString:@""];
		
    } // while //
    return html;	
}

#pragma mark Save and Load methods
- (void)saveUserInfo {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[kUsernameKey] = username;
    dictionary[kFullNameKey] = fullName;
    dictionary[kLanguageKey] = language;
    dictionary[kHomeCountryKey] = homeCountry;
    dictionary[kWebAddress] = webAddress;
    dictionary[kIntroductionText] = introductionText;
    dictionary[kSiteTitle] = siteTitle;
    dictionary[kFrontImageUrl] = frontImageUrl;
    dictionary[kEmailAddress] = emailAddress;
    
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", self.username]];
    [dictionary writeToFile:plistPath atomically:YES];
    
}

- (void)loadUserInfo {
    
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", self.username]];
   
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    self.fullName = [dictionary valueForKey:kFullNameKey];
	self.language = [dictionary valueForKey:kLanguageKey];
	self.homeCountry = [dictionary valueForKey:kHomeCountryKey];
	self.webAddress = [dictionary valueForKey:kWebAddress];
	self.introductionText = [dictionary valueForKey:kIntroductionText];
	self.siteTitle = [dictionary valueForKey:kSiteTitle];
    self.emailAddress = [dictionary valueForKey:kEmailAddress];
    self.frontImageUrl = [dictionary valueForKey:kFrontImageUrl];
    
}

@end
