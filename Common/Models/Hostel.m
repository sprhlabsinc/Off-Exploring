//
//  Hostel.m
//  Off Exploring
//
//  Created by Off Exploring on 06/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Hostel.h"
#import "DB.h"


@implementation Hostel

@synthesize hostelid;
@synthesize name;
@synthesize street1;
@synthesize street2;
@synthesize street3;
@synthesize city;
@synthesize state;
@synthesize country;
@synthesize zip;
@synthesize shortdescription;
@synthesize longdescription;
@synthesize map;
@synthesize importantinfo;
@synthesize checkin;
@synthesize checkout;
@synthesize latitude;
@synthesize longitude;
@synthesize distance;
@synthesize overall;
@synthesize atmosphere;
@synthesize staff;
@synthesize location;
@synthesize cleanliness;
@synthesize facilities;
@synthesize safety;
@synthesize fun;
@synthesize value;
@synthesize images;
@synthesize thumbs;
@synthesize features;
@synthesize sharedprice;
@synthesize privateprice;


#pragma mark Initalisation 

- (id)initWithDictionary:(NSDictionary *)aHostel {
	if (self = [super init]) {
		
		hostelid = [aHostel[@"id"] intValue];
		name = aHostel[@"name"];
		street1 = aHostel[@"street1"];
		street2 = aHostel[@"street2"];
		street3 = aHostel[@"street3"];
		city = aHostel[@"city"];
		state = aHostel[@"state"];
		country = aHostel[@"country"];
		zip = aHostel[@"zip"];
		shortdescription = aHostel[@"shortdescription"];
		longdescription = aHostel[@"longdescription"];
		map = aHostel[@"map"];
		importantinfo = aHostel[@"importantinfo"];
		checkin = aHostel[@"checkin"];
		checkout = aHostel[@"checkout"];
		latitude = [aHostel[@"latitude"] doubleValue];
		longitude = [aHostel[@"longitude"] doubleValue];
		distance = [aHostel[@"distance"] doubleValue];
		overall = [aHostel[@"ratings"][@"overall"] doubleValue];
		atmosphere = [aHostel[@"ratings"][@"atmosphere"] doubleValue];
		staff = [aHostel[@"ratings"][@"staff"] doubleValue];
		location = [aHostel[@"ratings"][@"location"] doubleValue];
		cleanliness = [aHostel[@"ratings"][@"cleanliness"] doubleValue];
		facilities = [aHostel[@"ratings"][@"facilities"] doubleValue];
		safety = [aHostel[@"ratings"][@"safety"] doubleValue];
		fun = [aHostel[@"ratings"][@"fun"] doubleValue];
		value = [aHostel[@"ratings"][@"value"] doubleValue];
		sharedprice = [aHostel[@"sharedprice"] doubleValue];
		privateprice = [aHostel[@"privateprice"] doubleValue];
		thumbs = aHostel[@"thumbs"][@"thumb"];
		
	}
	return self;
}

#pragma mark Accessors

- (NSArray *)loadImages:(BOOL)thumbURI {
	DB *db = [DB sharedDB];
	sqlite3_stmt *select_statement = nil;
	
	NSArray *returnArray = nil;
	
	if (select_statement == nil) {
		const char *sql = "SELECT uri FROM hostel_images WHERE hostelid = ? AND thumb = ?";
		if (sqlite3_prepare_v2(db.database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
			select_statement = nil;
			//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
		}
	}
	
	if (select_statement != nil) {
		sqlite3_bind_int(select_statement, 1, self.hostelid);
		sqlite3_bind_int(select_statement, 2, thumbURI);
		
		NSMutableArray *uris = [[NSMutableArray alloc] init];
		
		while (sqlite3_step(select_statement) == SQLITE_ROW) {
			char *data = (char *) sqlite3_column_text(select_statement, 0);
			NSString *string = @(data);
			[uris addObject:string];
			data = nil;
		}
		
		returnArray = [[NSArray alloc] initWithArray:uris];
	}
	
	return returnArray;
}

- (NSArray *)loadFeatures {
	DB *db = [DB sharedDB];
	sqlite3_stmt *select_statement = nil;
	
	NSArray *returnArray = nil;
	
	if (select_statement == nil) {
		const char *sql = "SELECT feature FROM hostel_features WHERE hostelid = ?";
		if (sqlite3_prepare_v2(db.database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
			select_statement = nil;
			//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
		}
	}
	
	if (select_statement != nil) {
		sqlite3_bind_int(select_statement, 1, self.hostelid);
		
		NSMutableArray *uris = [[NSMutableArray alloc] init];
		
		while (sqlite3_step(select_statement) == SQLITE_ROW) {
			[uris addObject:@((char *) sqlite3_column_text(select_statement, 0))];
		}
		
		returnArray = [[NSArray alloc] initWithArray:uris];
	}
	
	return returnArray;
}

- (NSDictionary *)lowestPrice {
	if (self.sharedprice == 0 && self.privateprice == 0) {
		return nil;
	}
	
	if ((self.privateprice < self.sharedprice && self.privateprice > 0) || self.sharedprice == 0) {
		return @{@"price": @(self.privateprice), @"type": @"privateprice"};
	}
	else {
		return @{@"price": @(self.sharedprice), @"type": @"sharedprice"};
	}
}

@end
