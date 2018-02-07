//
//  DB.m
//  Off Exploring
//
//  Created by Off Exploring on 29/07/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "DB.h"

#pragma mark -
#pragma mark DB Private Interface

/**
 @brief Private methods used in the implementation of DB access.
 
 This interface allows a quick way of retrieving the full local path to the database.
 */
@interface DB()

#pragma mark Private File Path Access Method Declaration
/**
	Returns the full local path to the database
	@returns The local path
 */
+ (NSString *) filePath;

@end

#pragma mark -
#pragma mark DB Implementation

@implementation DB

static DB *dbase = nil; 

@synthesize database;

#pragma mark Singleton Access

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedDB];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

+ (DB *)sharedDB {
    if (dbase == nil) {
        dbase = [[super allocWithZone:NULL] init];
    }
	
	if (dbase.database == nil) {
		
		sqlite3 *db;
		
		if (sqlite3_open([[self filePath] UTF8String], &db) != SQLITE_OK ) {
			sqlite3_close(db);
			NSLog(@"No DB connection");
			NSAssert(0, @"Database failed to open.");
		}
		
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS hostels (hostelid integer PRIMARY KEY,name varchar,street1 varchar,street2 varchar,street3 varchar,city varchar,state varchar,country varchar,zip varchar,shortdescription varchar,longdescription text,map varchar,importantinfo varchar,checkin varchar,checkout varchar,latitude double,longitude double,distance double,overall double,atmosphere double,staff double,location double,cleanliness double,facilities double,safety double,fun double,value double, sharedprice double, privateprice double)", NULL, NULL, NULL);
		
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS hostel_images (id integer PRIMARY KEY AUTOINCREMENT,hostelid integer,uri varchar,thumb boolean)", NULL, NULL, NULL);
		
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS hostel_features (id integer PRIMARY KEY AUTOINCREMENT,hostelid integer,feature varchar)", NULL, NULL, NULL);
		
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS hostel_rooms (roomid integer PRIMARY KEY, hostelid integer, startdate integer, days integer, beds integer, blockbeds integer, currency varchar, roomname varchar, pricefrom double, expiry integer)", NULL, NULL, NULL);
		
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS user_itinerary (id integer PRIMARY KEY, username varchar, timestamp integer, state varchar, area varchar, latitude double, longitude double, trip_id integer, expiry integer)", NULL, NULL, NULL);
		
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS system_messages (id integer PRIMARY KEY, title varchar, description text, link varchar, timestamp integer, imageUrl varchar, imageTitle varchar, imageLink varchar)", NULL, NULL, NULL);
		
		dbase.database = db;
		return dbase;
	}
	
    return dbase;
}

#pragma mark DB Reset Methods
- (BOOL)emptyHostelsDB {
	int success = 0;	
	
	if ((success += sqlite3_exec(self.database, "DELETE FROM hostels", NULL, NULL, NULL)) != SQLITE_OK) {
		//NSLog (@"PROBLEM - %s", sqlite3_errmsg(self.database));
	}
	if ((success += sqlite3_exec(self.database, "DELETE FROM hostel_features", NULL, NULL, NULL)) != SQLITE_OK) {
		//NSLog (@"PROBLEM - %s", sqlite3_errmsg(self.database));
	}
	if ((success += sqlite3_exec(self.database, "DELETE FROM hostel_images", NULL, NULL, NULL)) != SQLITE_OK) {
		//NSLog (@"PROBLEM - %s", sqlite3_errmsg(self.database));
	}
	
	if (success == SQLITE_OK) {
		return YES;
	}
	else {
		return NO;
	}
}

- (BOOL)emptyRoomsTable {
	int success = sqlite3_exec(self.database, "DELETE FROM hostel_rooms", NULL, NULL, NULL);
	if (success == 0) {
		return YES;
	}
	else {
		//NSLog (@"PROBLEM - %s", sqlite3_errmsg(self.database));
		return NO;
	}
}

- (BOOL)emptyItineraryDBForUsername:(NSString *)username {
	sqlite3_stmt *delete_statement = nil;
	const char *sql = "DELETE FROM user_itinerary WHERE username = ?";
	
	if (sqlite3_prepare_v2(self.database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
		delete_statement = nil;
		NSLog (@"PROBLEM - %s", sqlite3_errmsg(self.database));
	}
	
	sqlite3_bind_text(delete_statement, 1,[username UTF8String], -1, SQLITE_TRANSIENT);
	
	if (sqlite3_step(delete_statement) == SQLITE_DONE) {
		return YES;
	}
	else {
		//NSLog (@"PROBLEM - %s", sqlite3_errmsg(self.database));
		return NO;
	}
}

#pragma mark Private File Path Access Method
+ (NSString *)filePath {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = paths[0];
	return [documentsDir stringByAppendingPathComponent:@"database.sql"];
	
}

@end
