//
//  Hostels.h
//  Off Exploring
//
//  Created by Off Exploring on 20/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Hostels.h"
#import "DB.h"
#import "User.h"

#pragma mark -
#pragma mark Hostels Private Interface

/**
 @brief Private methods used in the implementation of parsing Hostel and Room data.
 
 This interface allows Hostels and Rooms to be parsed and provides an NSOperationQueue to 
 concurrently parse the returned information.
 */
@interface Hostels()

#pragma mark Private Parsing Method Declarations
/**
	Method used to concurrently parse Hostel Data into the DB
	@param hostelData The data to parse
 */
- (void)parseHostels:(NSDictionary *)hostelData;
/**
	Method used to return to the main thread and signal delegate of completion of hostel parsing
	@param successNum An NSNumber encapuslating a BOOL flag of successful parsing
 */
- (void)hostelsParsed:(NSNumber *)successNum;
/**
	Method used to parse Room Data into the DB
	@warning This is not a concurrent process, and will lock the main thread.
	@param results The data to parse
	@returns A success flag upon parsing completion
 */
+ (BOOL)parseRooms:(NSDictionary *)results;

@property (nonatomic, strong) NSOperationQueue *storeHostelQueue;

@end

#pragma mark -
#pragma mark Hostels Implementation

@implementation Hostels

@synthesize delegate;
@synthesize storeHostelQueue;

/**
	Over-ridden initialiser to setup an NSOperationQue to parse the returned data
	@returns The Hostels object
 */
- (id)init {
	self = [super init];
	if (self) {
		storeHostelQueue = [[NSOperationQueue alloc] init];
		[storeHostelQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}


#pragma mark Hostel And Room Database Static Load Methods

+ (Hostel *)loadHostelFromDBorderdBy:(int)orderID {
	DB *db = [DB sharedDB];
	sqlite3_stmt *select_statement = nil;
	
	Hostel *aHostel = nil;
	
	if (select_statement == nil) {
		
		const char *sql;
		
		if (orderID == HOSTELS_ORDER_DEFAULT) {
			
			User *user = [User sharedUser];
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			NSDictionary *hostelPreferences = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelPreferences_%@",user.username]];
			if (hostelPreferences != nil) {
				orderID = [hostelPreferences[@"orderBy"] intValue];
			}
			else {
				orderID = HOSTELS_ORDER_OVERALL;
			}
		}
		
		switch (orderID) {
			case HOSTELS_ORDER_SHAREDPRICE:
				sql = "SELECT * FROM hostels ORDER BY sharedprice ASC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_PRIVATEPRICE:
				sql = "SELECT * FROM hostels ORDER BY privateprice ASC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_DISTANCE:
				sql = "SELECT * FROM hostels ORDER BY distance ASC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_OVERALL:
			default:
				sql = "SELECT * FROM hostels ORDER BY overall DESC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_ATMOSPHERE:	
				sql = "SELECT * FROM hostels ORDER BY atmosphere DESC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_STAFF:						
				sql = "SELECT * FROM hostels ORDER BY staff DESC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_LOCATION:					
				sql = "SELECT * FROM hostels ORDER BY location DESC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_CLEANLINESS:				
				sql = "SELECT * FROM hostels ORDER BY cleanliness DESC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_FACILITIES:				
				sql = "SELECT * FROM hostels ORDER BY facilities DESC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_SAFETY:					
				sql = "SELECT * FROM hostels ORDER BY safety DESC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_FUN:						
				sql = "SELECT * FROM hostels ORDER BY fun DESC LIMIT 1"; 
				break;
			case HOSTELS_ORDER_VALUE:						
				sql = "SELECT * FROM hostels ORDER BY value DESC LIMIT 1"; 
				break;		
		}
		
		if (sqlite3_prepare_v2(db.database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
			select_statement = nil;
			//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
		}
	}
	
	if (select_statement != nil) {
		
		
		if (sqlite3_step(select_statement) == SQLITE_ROW) {
			
			NSNumber *hostelid = @(sqlite3_column_int(select_statement, 0));
			
			NSString *name = @((char *) sqlite3_column_text(select_statement, 1));
			NSString *street1 = @((char *) sqlite3_column_text(select_statement, 2));
			NSString *street2 = @((char *) sqlite3_column_text(select_statement, 3));
			NSString *street3 = @((char *) sqlite3_column_text(select_statement, 4));
			NSString *city = @((char *) sqlite3_column_text(select_statement, 5));
			NSString *state = @((char *) sqlite3_column_text(select_statement, 6));
			NSString *country = @((char *) sqlite3_column_text(select_statement, 7));
			NSString *zip = @((char *) sqlite3_column_text(select_statement, 8));
			NSString *shortdescription = @((char *) sqlite3_column_text(select_statement, 9));
			NSString *longdescription = @((char *) sqlite3_column_text(select_statement, 10));
			NSString *map = @((char *) sqlite3_column_text(select_statement, 11));
			NSString *importantinfo = @((char *) sqlite3_column_text(select_statement, 12));
			NSString *checkin = @((char *) sqlite3_column_text(select_statement, 13));
			NSString *checkout = @((char *) sqlite3_column_text(select_statement, 14));
			
			NSNumber *latitude = @(sqlite3_column_double(select_statement, 15));
			NSNumber *longitude = @(sqlite3_column_double(select_statement, 16));
			NSNumber *distance = @(sqlite3_column_double(select_statement, 17));
			
			NSNumber *overall = @(sqlite3_column_double(select_statement, 18));
			NSNumber *atmosphere = @(sqlite3_column_double(select_statement, 19));
			NSNumber *staff = @(sqlite3_column_double(select_statement, 20));
			NSNumber *location = @(sqlite3_column_double(select_statement, 21));
			NSNumber *cleanliness = @(sqlite3_column_double(select_statement, 22));
			NSNumber *facilities = @(sqlite3_column_double(select_statement, 23));
			NSNumber *safety = @(sqlite3_column_double(select_statement, 24));
			NSNumber *fun = @(sqlite3_column_double(select_statement, 25));
			NSNumber *value = @(sqlite3_column_double(select_statement, 26));
			
			NSNumber *sharedprice = @(sqlite3_column_double(select_statement, 27));
			NSNumber *privateprice = @(sqlite3_column_double(select_statement, 28));
			
			NSDictionary *ratings = [[NSDictionary alloc] initWithObjectsAndKeys:
									 overall, @"overall",
									 atmosphere, @"atmosphere",
									 staff, @"staff",
									 location, @"location",
									 cleanliness, @"cleanliness",
									 facilities, @"facilities",
									 safety, @"safety",
									 fun, @"fun",
									 value, @"value",
									 nil];
			
			NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
								  hostelid, @"id",
								  name, @"name",
								  street1, @"street1",
								  street2, @"street2",
								  street3, @"street3",
								  city, @"city",
								  state, @"state",
								  country, @"country",
								  zip, @"zip",
								  shortdescription, @"shortdescription",
								  longdescription, @"longdescription",
								  map, @"map",
								  importantinfo, @"importantinfo",
								  checkin, @"checkin",
								  checkout, @"checkout",
								  latitude, @"latitude",
								  longitude, @"longitude",
								  distance, @"distance",
								  ratings, @"ratings",
								  sharedprice, @"sharedprice",
								  privateprice, @"privateprice",
								  nil];
			
			aHostel = [[Hostel alloc] initWithDictionary:dict];
		}
	}
	
	sqlite3_reset(select_statement);
	
	return aHostel;
}

+ (NSArray *)loadHostelsFromDBorderedBy:(int)orderID {
	
	DB *db = [DB sharedDB];
	sqlite3_stmt *select_statement = nil;
	
	NSMutableArray *hostelList = [[NSMutableArray alloc] init];
	
	if (select_statement == nil) {
		
		const char *sql;
		
		if (orderID == HOSTELS_ORDER_DEFAULT) {
			
			User *user = [User sharedUser];
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			NSDictionary *hostelPreferences = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelPreferences_%@",user.username]];
			if (hostelPreferences != nil) {
				orderID = [hostelPreferences[@"orderBy"] intValue];
			}
			else {
				orderID = HOSTELS_ORDER_OVERALL;
			}
		}
		
		switch (orderID) {
			case HOSTELS_ORDER_SHAREDPRICE:
				sql = "SELECT * FROM hostels ORDER BY sharedprice ASC"; 
				break;
			case HOSTELS_ORDER_PRIVATEPRICE:
				sql = "SELECT * FROM hostels ORDER BY privateprice ASC"; 
				break;
			case HOSTELS_ORDER_DISTANCE:
				sql = "SELECT * FROM hostels ORDER BY distance ASC"; 
				break;
			case HOSTELS_ORDER_OVERALL:
			default:
				sql = "SELECT * FROM hostels ORDER BY overall DESC"; 
				break;
			case HOSTELS_ORDER_ATMOSPHERE:	
				sql = "SELECT * FROM hostels ORDER BY atmosphere DESC"; 
				break;
			case HOSTELS_ORDER_STAFF:						
				sql = "SELECT * FROM hostels ORDER BY staff DESC"; 
				break;
			case HOSTELS_ORDER_LOCATION:					
				sql = "SELECT * FROM hostels ORDER BY location DESC"; 
				break;
			case HOSTELS_ORDER_CLEANLINESS:				
				sql = "SELECT * FROM hostels ORDER BY cleanliness DESC"; 
				break;
			case HOSTELS_ORDER_FACILITIES:				
				sql = "SELECT * FROM hostels ORDER BY facilities DESC"; 
				break;
			case HOSTELS_ORDER_SAFETY:					
				sql = "SELECT * FROM hostels ORDER BY safety DESC"; 
				break;
			case HOSTELS_ORDER_FUN:						
				sql = "SELECT * FROM hostels ORDER BY fun DESC"; 
				break;
			case HOSTELS_ORDER_VALUE:						
				sql = "SELECT * FROM hostels ORDER BY value DESC"; 
				break;	
		}
		
		if (sqlite3_prepare_v2(db.database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
			select_statement = nil;
			//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
		}
	}
	
	if (select_statement != nil) {
		
		
		while (sqlite3_step(select_statement) == SQLITE_ROW) {
			
			NSNumber *hostelid = @(sqlite3_column_int(select_statement, 0));
			
			NSString *name = @((char *) sqlite3_column_text(select_statement, 1));
			NSString *street1 = @((char *) sqlite3_column_text(select_statement, 2));
			NSString *street2 = @((char *) sqlite3_column_text(select_statement, 3));
			NSString *street3 = @((char *) sqlite3_column_text(select_statement, 4));
			NSString *city = @((char *) sqlite3_column_text(select_statement, 5));
			NSString *state = @((char *) sqlite3_column_text(select_statement, 6));
			NSString *country = @((char *) sqlite3_column_text(select_statement, 7));
			NSString *zip = @((char *) sqlite3_column_text(select_statement, 8));
			NSString *shortdescription = @((char *) sqlite3_column_text(select_statement, 9));
			NSString *longdescription = @((char *) sqlite3_column_text(select_statement, 10));
			NSString *map = @((char *) sqlite3_column_text(select_statement, 11));
			NSString *importantinfo = @((char *) sqlite3_column_text(select_statement, 12));
			NSString *checkin = @((char *) sqlite3_column_text(select_statement, 13));
			NSString *checkout = @((char *) sqlite3_column_text(select_statement, 14));
			
			NSNumber *latitude = @(sqlite3_column_double(select_statement, 15));
			NSNumber *longitude = @(sqlite3_column_double(select_statement, 16));
			NSNumber *distance = @(sqlite3_column_double(select_statement, 17));
			
			NSNumber *overall = @(sqlite3_column_double(select_statement, 18));
			NSNumber *atmosphere = @(sqlite3_column_double(select_statement, 19));
			NSNumber *staff = @(sqlite3_column_double(select_statement, 20));
			NSNumber *location = @(sqlite3_column_double(select_statement, 21));
			NSNumber *cleanliness = @(sqlite3_column_double(select_statement, 22));
			NSNumber *facilities = @(sqlite3_column_double(select_statement, 23));
			NSNumber *safety = @(sqlite3_column_double(select_statement, 24));
			NSNumber *fun = @(sqlite3_column_double(select_statement, 25));
			NSNumber *value = @(sqlite3_column_double(select_statement, 26));
			
			NSNumber *sharedprice = @(sqlite3_column_double(select_statement, 27));
			NSNumber *privateprice = @(sqlite3_column_double(select_statement, 28));
			
			NSDictionary *ratings = [[NSDictionary alloc] initWithObjectsAndKeys:
									 overall, @"overall",
									 atmosphere, @"atmosphere",
									 staff, @"staff",
									 location, @"location",
									 cleanliness, @"cleanliness",
									 facilities, @"facilities",
									 safety, @"safety",
									 fun, @"fun",
									 value, @"value",
									 nil];
			
			NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
								  hostelid, @"id",
								  name, @"name",
								  street1, @"street1",
								  street2, @"street2",
								  street3, @"street3",
								  city, @"city",
								  state, @"state",
								  country, @"country",
								  zip, @"zip",
								  shortdescription, @"shortdescription",
								  longdescription, @"longdescription",
								  map, @"map",
								  importantinfo, @"importantinfo",
								  checkin, @"checkin",
								  checkout, @"checkout",
								  latitude, @"latitude",
								  longitude, @"longitude",
								  distance, @"distance",
								  ratings, @"ratings",
								  sharedprice, @"sharedprice",
								  privateprice, @"privateprice",
								  nil];
			
			Hostel *aHostel = [[Hostel alloc] initWithDictionary:dict];
			[hostelList addObject:aHostel];
		}
	}
	
	sqlite3_reset(select_statement);
	
	NSArray *hostels = [[NSArray alloc] initWithArray:hostelList];
	
	return hostels;
	
}

+ (NSArray *)loadRoomsFromDBForHostelid:(int)hostelid {
	
	DB *db = [DB sharedDB];
	sqlite3_stmt *select_statement = nil;
	
	NSMutableArray *roomList = [[NSMutableArray alloc] init];
	
	if (select_statement == nil) {
		
		const char *sql = "SELECT * FROM hostel_rooms WHERE hostelid = ? ORDER BY pricefrom ASC";
		
		if (sqlite3_prepare_v2(db.database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
			select_statement = nil;
			//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
		}
		
		sqlite3_bind_int(select_statement, 1, hostelid);
		
		if (select_statement != nil) {
			while (sqlite3_step(select_statement) == SQLITE_ROW) {
				
				NSNumber *roomid = @(sqlite3_column_int(select_statement, 0));
				NSNumber *hostelid = @(sqlite3_column_int(select_statement, 1));
				NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_int(select_statement, 2)];
				int timestop = sqlite3_column_int(select_statement, 3);
				NSNumber *beds = @(sqlite3_column_int(select_statement, 4));
				NSNumber *blockbeds = @(sqlite3_column_int(select_statement, 5));
				NSString *currency = @((char *) sqlite3_column_text(select_statement, 6));
				NSString *roomName = @((char *) sqlite3_column_text(select_statement, 7));
				NSNumber *pricefrom = @(sqlite3_column_double(select_statement, 8));
				NSDate *expiry = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_int(select_statement, 9)];
				
				timestop = timestop * 86400;
				
				NSDate *endDate = [startDate dateByAddingTimeInterval:timestop];
				
				NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:roomid, @"roomid", hostelid, @"hostelid", 
									  beds, @"beds", blockbeds, @"blockbeds", pricefrom, @"pricefrom", currency, @"currency",
									  roomName, @"roomName", startDate, @"startDate", endDate, @"endDate", expiry, @"expiry", nil];
				Room *aRoom = [[Room alloc] initWithDictionary:dict];
				[roomList addObject:aRoom];
				
			}
		}
	}
	
	sqlite3_reset(select_statement);
	
	NSArray *rooms = [[NSArray alloc] initWithArray:roomList];
	
	return rooms;
	
}

#pragma mark Hostel And Room Remote Dynamic Load Methods

- (void)loadHostelsForArea:(NSString *)area country:(NSString *)country within:(NSNumber *)miles page:(NSNumber *)page orderedBy:(NSNumber *)order {
	if ([order intValue] == HOSTELS_ORDER_DEFAULT) {
		
		User *user = [User sharedUser];
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		NSDictionary *hostelPreferences = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelPreferences_%@",user.username]];
		if (hostelPreferences != nil) {
			order = hostelPreferences[@"orderBy"];
		}
		else {
			order = @HOSTELS_ORDER_OVERALL;
		}
	}
	
	OffexConnex *connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"][@"code"];
	
	NSString *url = [connex buildHBRequestStringWithURI:[NSString stringWithFormat:@"hostels/country/%@/city/%@/%d",[connex urlEncodeValue:country], [connex urlEncodeValue:area],[page intValue]]];
	url = [url stringByAppendingFormat:@"?max_distance=%f&order=%d&currency=", [miles doubleValue], [order intValue]];
	url = [url stringByAppendingString:currencyCode];
	//NSLog (@"%@", url);
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)loadHostelsForArea:(NSString *)area country:(NSString *)country latitide:(NSNumber *)latitude longitude:(NSNumber *)longitude within:(NSNumber *)miles page:(NSNumber *)page orderedBy:(NSNumber *)order {
	if ([order intValue] == HOSTELS_ORDER_DEFAULT) {
		
		User *user = [User sharedUser];
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		NSDictionary *hostelPreferences = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelPreferences_%@",user.username]];
		if (hostelPreferences != nil) {
			order = hostelPreferences[@"orderBy"];
		}
		else {
			order = @HOSTELS_ORDER_OVERALL;
		}
	}
	
	OffexConnex *connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"][@"code"];
	
	NSString *url = [connex buildHBRequestStringWithURI:[NSString stringWithFormat:@"hostels/country/%@/city/%@/%d",[connex urlEncodeValue:country], [connex urlEncodeValue:area],[page intValue]]];
	url = [url stringByAppendingFormat:@"?max_distance=%f&order=%d&currency=", [miles doubleValue], [order intValue]];
	url = [url stringByAppendingString:currencyCode];
	url = [url stringByAppendingFormat:@"&latitude=%f&longitude=%f", [latitude doubleValue], [longitude doubleValue]];
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)loadRoomsForHostel:(Hostel *)hostel forDate:(NSDate *)date forDays:(NSUInteger)days{
	NSTimeInterval timestamp = [date timeIntervalSince1970];
	OffexConnex *connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	NSString *url = [[connex buildHBRequestStringWithURI:[NSString stringWithFormat:@"hostel/%d/availability/%.0f",hostel.hostelid, timestamp]] stringByAppendingFormat:@"?days=%d&currency=", days];
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"][@"code"];
	url = [url stringByAppendingString:currencyCode];
	[connex beginLoadingOffexploringDataFromURL:url];
}

#pragma mark Private Parsing Methods

- (void)parseHostels:(NSDictionary *)hostelData {
	
	DB *db = [DB sharedDB];
	sqlite3_stmt *select_statement = nil;
	sqlite3_stmt *init_statement = nil;
	sqlite3_stmt *image_statement = nil;
	sqlite3_stmt *feature_statement = nil;
	const char *sql = "SELECT name FROM hostels WHERE hostelid = ? LIMIT 1";
	
	NSMutableDictionary *aHostel;
	
	if (hostelData[@"response"][@"hostels"] != [NSNull null]) {
		
		for (aHostel in hostelData[@"response"][@"hostels"][@"hostel"]) {
			
			if (select_statement == nil) {
				if (sqlite3_prepare_v2(db.database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
					select_statement = nil;
					//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
				}
			}
			if (select_statement != nil) {
				sqlite3_bind_int(select_statement, 1, [aHostel[@"id"] intValue]);
				if (sqlite3_step(select_statement) != SQLITE_ROW) {
					if (init_statement == nil) {
						const char *sql = "INSERT INTO hostels (hostelid, name, street1, street2, street3, city, state, country, zip, shortdescription,longdescription, map, importantinfo, checkin, checkout, latitude, longitude, distance, overall, atmosphere, staff, location, cleanliness, facilities, safety, fun, value, sharedprice, privateprice) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
						
						if (sqlite3_prepare_v2(db.database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
							//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
						}
					}
					
					if (aHostel[@"name"] == [NSNull null]) {
						aHostel[@"name"] = @"NULL";
					}
					if (aHostel[@"street1"] == [NSNull null]) {
						aHostel[@"street1"] = @"NULL";
					}
					if (aHostel[@"street2"] == [NSNull null]) {
						aHostel[@"street2"] = @"NULL";
					}
					if (aHostel[@"street3"] == [NSNull null]) {
						aHostel[@"street3"] = @"NULL";
					}
					if (aHostel[@"city"] == [NSNull null]) {
						aHostel[@"city"] = @"NULL";
					}
					if (aHostel[@"state"] == [NSNull null]) {
						aHostel[@"state"] = @"NULL";
					}
					if (aHostel[@"country"] == [NSNull null]) {
						aHostel[@"country"] = @"NULL";
					}
					if (aHostel[@"zip"] == [NSNull null]) {
						aHostel[@"zip"] = @"NULL";
					}
					if (aHostel[@"shortdescription"] == [NSNull null]) {
						aHostel[@"shortdescription"] = @"NULL";
					}
					if (aHostel[@"longdescription"] == [NSNull null]) {
						aHostel[@"longdescription"] = @"NULL";
					}
					if (aHostel[@"map"] == [NSNull null]) {
						aHostel[@"map"] = @"NULL";
					}
					if (aHostel[@"importantinfo"] == [NSNull null]) {
						aHostel[@"importantinfo"] = @"NULL";
					}
					if (aHostel[@"checkin"] == [NSNull null]) {
						aHostel[@"checkin"] = @"NULL";
					}
					if (aHostel[@"checkout"] == [NSNull null]) {
						aHostel[@"checkout"] = @"NULL";
					}
					
					
					sqlite3_bind_int(init_statement, 1, [aHostel[@"id"] intValue]);
					sqlite3_bind_text(init_statement, 2,[aHostel[@"name"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 3,[aHostel[@"street1"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 4,[aHostel[@"street2"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 5,[aHostel[@"street3"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 6,[aHostel[@"city"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 7,[aHostel[@"state"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 8,[aHostel[@"country"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 9,[aHostel[@"zip"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 10,[aHostel[@"shortdescription"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 11,[aHostel[@"longdescription"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 12,[aHostel[@"map"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 13,[aHostel[@"importantinfo"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 14,[aHostel[@"checkin"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_text(init_statement, 15,[aHostel[@"checkout"] UTF8String], -1, SQLITE_TRANSIENT);
					sqlite3_bind_double(init_statement, 16, [aHostel[@"latitude"] doubleValue]);
					sqlite3_bind_double(init_statement, 17, [aHostel[@"longitude"] doubleValue]);
					sqlite3_bind_double(init_statement, 18, [aHostel[@"distance"] doubleValue]);
					sqlite3_bind_double(init_statement, 19, [aHostel[@"ratings"][@"overall"] doubleValue]);
					sqlite3_bind_double(init_statement, 20, [aHostel[@"ratings"][@"atmosphere"] doubleValue]);
					sqlite3_bind_double(init_statement, 21, [aHostel[@"ratings"][@"staff"] doubleValue]);
					sqlite3_bind_double(init_statement, 22, [aHostel[@"ratings"][@"location"] doubleValue]);
					sqlite3_bind_double(init_statement, 23, [aHostel[@"ratings"][@"cleanliness"] doubleValue]);
					sqlite3_bind_double(init_statement, 24, [aHostel[@"ratings"][@"facilities"] doubleValue]);
					sqlite3_bind_double(init_statement, 25, [aHostel[@"ratings"][@"safety"] doubleValue]);
					sqlite3_bind_double(init_statement, 26, [aHostel[@"ratings"][@"fun"] doubleValue]);
					sqlite3_bind_double(init_statement, 27, [aHostel[@"ratings"][@"value"] doubleValue]);
					sqlite3_bind_double(init_statement, 28, [aHostel[@"sharedprice"] doubleValue]);
					sqlite3_bind_double(init_statement, 29, [aHostel[@"privateprice"] doubleValue]);
					
					
					if (sqlite3_step(init_statement) != SQLITE_DONE) {
						//NSLog(@"Unable to insert hostel %@ - %s", [aHostel objectForKey:@"name"], sqlite3_errmsg(db.database));
					}
					
					sqlite3_reset(init_statement);
					
					if (image_statement == nil) {
						const char *sql = "INSERT INTO hostel_images (hostelid, uri, thumb) VALUES (?,?,?)";
						
						if (sqlite3_prepare_v2(db.database, sql, -1, &image_statement, NULL) != SQLITE_OK) {
							//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
						}
					}
					
					if (aHostel[@"thumbs"][@"thumb"] != [NSNull null]) {
					
						for (NSString *imageURI in aHostel[@"thumbs"][@"thumb"]) {
							sqlite3_bind_int(image_statement, 1, [aHostel[@"id"] intValue]);
							sqlite3_bind_text(image_statement, 2,[imageURI UTF8String], -1, SQLITE_TRANSIENT);
							sqlite3_bind_int(image_statement, 3, 1);
							
							if (sqlite3_step(image_statement) != SQLITE_DONE) {
								//NSLog(@"Unable to insert hostel image %@ for hostel %@ - %s",imageURI, [aHostel objectForKey:@"name"], sqlite3_errmsg(db.database));
							}
							
							sqlite3_reset(image_statement);
						}
						
					}
					
					if (aHostel[@"images"][@"image"] != [NSNull null]) {
						
						for (NSString *imageURI in aHostel[@"images"][@"image"]) {
							sqlite3_bind_int(image_statement, 1, [aHostel[@"id"] intValue]);
							sqlite3_bind_text(image_statement, 2,[imageURI UTF8String], -1, SQLITE_TRANSIENT);
							sqlite3_bind_int(image_statement, 3, 0);
							
							if (sqlite3_step(image_statement) != SQLITE_DONE) {
								//NSLog(@"SQLite logging update failure");
							}
							
							sqlite3_reset(image_statement);
						}
					
					}
					
					if (feature_statement == nil) {
						const char *sql = "INSERT INTO hostel_features (hostelid, feature) VALUES (?,?)";
						
						if (sqlite3_prepare_v2(db.database, sql, -1, &feature_statement, NULL) != SQLITE_OK) {
							//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
						}
					}
					
					if (aHostel[@"features"][@"feature"] != [NSNull null]) {
					
						for (NSString *featureString in aHostel[@"features"][@"feature"]) {
							sqlite3_bind_int(feature_statement, 1, [aHostel[@"id"] intValue]);
							sqlite3_bind_text(feature_statement, 2,[featureString UTF8String], -1, SQLITE_TRANSIENT);
							
							if (sqlite3_step(feature_statement) != SQLITE_DONE) {
								//NSLog(@"Unable to insert hostel feature %@ for hostel %@ - %s",featureString, [aHostel objectForKey:@"name"], sqlite3_errmsg(db.database));
							}
							sqlite3_reset(feature_statement);
						}
					}
				}
				sqlite3_reset(select_statement);
			}
		}
		[self performSelectorOnMainThread:@selector(hostelsParsed:) withObject:@YES waitUntilDone:NO];
	}
	else {
		[self performSelectorOnMainThread:@selector(hostelsParsed:) withObject:@NO waitUntilDone:NO];
	}
	
}

- (void)hostelsParsed:(NSNumber *)successNum {
	BOOL success = [successNum boolValue];
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *dict = [prefs objectForKey:[NSString stringWithFormat:@"latestHostelLookup_%@", user.username]];
	
	if (success) {
		if ([delegate respondsToSelector:@selector(hostelLoader:didLoadHostelsforCity:country:latitude:longitude:range:page:)]) {
			[delegate hostelLoader:self didLoadHostelsforCity:dict[@"area"] country:dict[@"country"] latitude:[dict[@"determinedDestination"][@"latitude"] doubleValue] longitude:[dict[@"determinedDestination"][@"longitude"] doubleValue]  range:[dict[@"range"] doubleValue] page:[dict[@"page"] intValue]];
		}
	}
	else {
		if ([delegate respondsToSelector:@selector(hostelLoader:failedToLoadHostelsforCity:country:latitude:longitude:range:page:)]) {
			[delegate hostelLoader:self failedToLoadHostelsforCity:dict[@"area"] country:dict[@"country"] latitude:[dict[@"determinedDestination"][@"latitude"] doubleValue] longitude:[dict[@"determinedDestination"][@"longitude"] doubleValue] range:[dict[@"range"] doubleValue] page:[dict[@"page"] intValue]];
		}
	}
}

+ (BOOL)parseRooms:(NSDictionary *)results {
	
	DB *db = [DB sharedDB];
	sqlite3_stmt *init_statement = nil;
	[db emptyRoomsTable];
	
	NSUInteger hostelid = [results[@"request"][@"params"][@"param"][0] intValue];
	NSUInteger startDate = [results[@"request"][@"params"][@"param"][1] intValue]; 
	NSUInteger days = [results[@"request"][@"getVars"][@"days"] intValue];
	NSUInteger expiry =  [[NSDate dateWithTimeIntervalSinceNow:3600] timeIntervalSince1970];
	
	BOOL added = NO;
	const char *sql = "INSERT INTO hostel_rooms (roomid, hostelid, startdate, days, beds, blockbeds, currency, roomname, pricefrom, expiry) VALUES (?,?,?,?,?,?,?,?,?,?)";
	
	if (sqlite3_prepare_v2(db.database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
		//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
	}
	
	for (NSDictionary *roomInfo in results[@"response"][@"rooms"][@"room"]) {
		
		sqlite3_bind_int(init_statement, 1, [roomInfo[@"roomid"] intValue]);
		sqlite3_bind_int(init_statement, 2, hostelid);
		sqlite3_bind_int(init_statement, 3, startDate);
		sqlite3_bind_int(init_statement, 4, days);
		sqlite3_bind_int(init_statement, 5, [roomInfo[@"beds"] intValue]);
		sqlite3_bind_int(init_statement, 6, [roomInfo[@"blockbeds"] intValue]);
		sqlite3_bind_text(init_statement, 7,[roomInfo[@"currency"] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(init_statement, 8,[roomInfo[@"name"] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(init_statement, 9, [roomInfo[@"pricefrom"] doubleValue]);
		sqlite3_bind_int(init_statement, 10, expiry);
		
		
		if (sqlite3_step(init_statement) != SQLITE_DONE) {
			//NSLog(@"Unable to insert room for %d - %s", hostelid, sqlite3_errmsg(db.database));
		}
		else {
			added = YES;
		}
		
		sqlite3_reset(init_statement);
	}
	
	return added;
	
}

#pragma mark OffexploringConnectionDelegate Methods

/**
	Retrieves returned information from Off Exploring and appropriately handles
	@param offex The OffexConnex object used to make the request
	@param results The returned results from the call
 */
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	if (results[@"response"][@"hostels"]) {
		
		User *user = [User sharedUser];
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		NSString *theArea = results[@"request"][@"params"][@"param"][1];
		NSString *theCountry = results[@"request"][@"params"][@"param"][0];
		NSNumber *theDistance = @([results[@"request"][@"getVars"][@"max_distance"] doubleValue]);
		NSNumber *thePage = @([results[@"request"][@"params"][@"param"][2]intValue]);
		NSNumber *resultCount = nil;
		NSDictionary *currency = [prefs objectForKey:@"currency"];
		NSNumber *theResultTime = @([[NSDate date] timeIntervalSince1970]);
		
		
		if (results[@"response"][@"hostels"] != [NSNull null]) {
			resultCount = [NSNumber numberWithInt:[results[@"response"][@"hostels"][@"hostel"] count]];
		}
		else {
			resultCount = @0;
		}
        
        NSMutableDictionary *determinedDestination = [results[@"response"][@"destination"] mutableCopy];
        
        if ([determinedDestination[@"name"] isEqual:[NSNull null]]) {
            determinedDestination[@"name"] = @"";
        }
		
		NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:theArea,@"area", theCountry,@"country",theDistance, @"range", thePage, @"page", resultCount, @"resultCount", determinedDestination, @"determinedDestination", currency, @"currency", theResultTime, @"resultTime", nil];
        
		[prefs setObject:dictionary forKey:[NSString stringWithFormat:@"latestHostelLookup_%@", user.username]];
		[prefs synchronize];
		
		NSInvocationOperation *parseHostels = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseHostels:) object:results];
		[self.storeHostelQueue cancelAllOperations];
		[self.storeHostelQueue addOperation:parseHostels];
	}
	else if (results[@"response"][@"rooms"]) {
		NSUInteger hostelid = [results[@"request"][@"params"][@"param"][0] intValue];
		NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[results[@"request"][@"params"][@"param"][1] intValue]]; 
		NSUInteger days = [results[@"request"][@"getVars"][@"days"] intValue];
		
		if (results[@"response"][@"rooms"][@"room"] == [NSNull null]) {
			if ([delegate respondsToSelector:@selector(hostelLoader:failedToLoadRoomsforHostelid:date:days:)]) {
				[delegate hostelLoader:self failedToLoadRoomsforHostelid:hostelid date:startDate days:days];
			}
		}
		else {
			if ([Hostels parseRooms:results]) {
				if ([delegate respondsToSelector:@selector(hostelLoader:didLoadRoomsforHostelid:date:days:)]) {
					[delegate hostelLoader:self didLoadRoomsforHostelid:hostelid date:startDate days:days];
				}
			}
			else {
				if ([delegate respondsToSelector:@selector(hostelLoader:failedToLoadRoomsforHostelid:date:days:)]) {
					[delegate hostelLoader:self failedToLoadRoomsforHostelid:hostelid date:startDate days:days];
				}
			}
		}
	}
}

/**
	Called if the connection fails. Informs the HostelsLoaderDelegate
	@param offex The OffexConnex object used to make the request
	@param error The returned error
 */
- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *)error {
	[delegate noConnectionforHostelLoader:self];
}

@end
