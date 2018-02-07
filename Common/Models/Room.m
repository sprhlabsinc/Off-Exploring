//
//  Room.m
//  Off Exploring
//
//  Created by Off Exploring on 06/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Room.h"

@implementation Room

@synthesize roomid;
@synthesize hostelid;
@synthesize beds;
@synthesize blockbeds;
@synthesize pricefrom;
@synthesize currency;
@synthesize roomName;
@synthesize startDate;
@synthesize endDate;
@synthesize expiry;


- (id)initWithDictionary:(NSDictionary *)dict {

	if (self = [super init]) {
	
		roomid = [dict[@"roomid"] intValue];
		hostelid = [dict[@"hostelid"] intValue];
		beds = [dict[@"beds"] intValue];
		blockbeds = [dict[@"blockbeds"] intValue];
		pricefrom = [dict[@"pricefrom"] doubleValue];
		currency = dict[@"currency"];
		roomName = dict[@"roomName"];
		startDate = dict[@"startDate"];
		endDate = dict[@"endDate"];
		expiry = dict[@"expiry"];
		
	}
	return self;
}

@end
