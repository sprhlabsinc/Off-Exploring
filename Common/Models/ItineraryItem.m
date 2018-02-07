//
//  ItineraryItem.m
//  Off Exploring
//
//  Created by Off Exploring on 14/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "ItineraryItem.h"


@implementation ItineraryItem

@synthesize itemid;
@synthesize timestamp;
@synthesize state;
@synthesize area;
@synthesize latitude;
@synthesize longitude;


- (id)initWithDictionary:(NSDictionary *)dict {
	
	if (self = [super init]) {
		itemid = [dict[@"id"] intValue];
		timestamp = [dict[@"timestamp"] doubleValue];
		state = dict[@"state"];
		area = dict[@"area"];
		latitude = [dict[@"latitude"] doubleValue];
		longitude = [dict[@"longitude"] doubleValue];
	}
	return self;
}


@end
