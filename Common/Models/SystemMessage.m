//
//  SystemMessage.m
//  Off Exploring
//
//  Created by Off Exploring on 30/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "SystemMessage.h"


@implementation SystemMessage

@synthesize dbid;
@synthesize title;
@synthesize description;
@synthesize link;
@synthesize timestamp;


- (id)init {

	if (self = [super init]) {
	
		dbid = -1;
		title = @"Default Message";
		description = @"This is a default system message";
		link = @"http://www.offexploring.com";
		timestamp = [NSDate	date];
		
	}
	return self;
}

- (id)initWithDBID:(int)newID title:(NSString *)newTitle description:(NSString *)newDescription link:(NSString *)newLink timestamp:(NSDate *)newTimestamp {

	if (self = [super init]) {
		
		dbid = newID;
		title = newTitle;
		description = newDescription;
		link = newLink;
		timestamp = newTimestamp;
		
	}
	return self;
	
}

@end
