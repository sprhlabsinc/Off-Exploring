//
//  Trips.m
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Trips.h"

@implementation Trips

@synthesize tripsArray;


- (void)setFromArray:(NSArray *)data {

	tripsArray = [[NSMutableArray alloc] init];
	
	NSDictionary *aTrip;
	
	for (aTrip in data) {
		Trip *trip = [[Trip alloc] initFromDictionary:aTrip];
		[tripsArray addObject:trip];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TripsDataDidLoad" object:self];
}

- (void)insertTrip:(Trip *)trip {
	
	int count = 0;
	for (Trip *aTrip in tripsArray) {
		if ([trip.urlSlug isEqualToString:aTrip.urlSlug]) {
			tripsArray[count] = trip;
			return;
		}
		count++;
	}
	
	[tripsArray addObject:trip];
}

- (void)deleteTrip:(Trip *)trip {
	int count = 0;
	for (Trip *aTrip in tripsArray) {
		if (aTrip == trip) {
			[tripsArray removeObjectAtIndex:count];
			return;
		}
		count++;
	}
}

@end
