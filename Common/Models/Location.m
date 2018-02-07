//
//  Location.m
//  Off Exploring
//
//  Created by Off Exploring on 05/08/2010.
//  Copyright 2010 com.offexploring. All rights reserved.
//

#import "Location.h"


@implementation Location

@synthesize dbid;
@synthesize area;
@synthesize country;
@synthesize recorded;
@synthesize visited;


- (id) initWithID:(NSInteger *)databaseid 
			 area:(NSString *)databasearea 
		  country:(NSString *)databasecountry 
		 recorded:(NSDate *)databaserecorded 
		  visited:(NSDate *)databasevisited 
{
	if (self = [super init]) {
		
		dbid = (int)databaseid;
		area = databasearea;
		country = databasecountry;
		recorded = databaserecorded;
		visited = databasevisited;
		
	}
	return self;
}

@end
