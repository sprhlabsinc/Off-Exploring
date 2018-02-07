//
//  Location.h
//  Off Exploring
//
//  Created by Off Exploring on 05/08/2010.
//  Copyright 2010 com.offexploring. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Location : NSObject {

	int dbid;
	NSString *area;
	NSString *country;
	NSDate *recorded;
	NSDate *visited;
	
}

@property (nonatomic, assign, readonly) int dbid;
@property (nonatomic, strong, readonly) NSString *area;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSDate *recorded;
@property (nonatomic, strong, readonly) NSDate *visited;

- (id) initWithID:(NSInteger *)databaseid 
			 area:(NSString *)databasearea 
		  country:(NSString *)databasecountry 
		 recorded:(NSDate *)databaserecorded 
		  visited:(NSDate *)databasevisited;

@end
