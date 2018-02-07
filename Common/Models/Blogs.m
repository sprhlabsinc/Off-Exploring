//
//  Blogs.m
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Blogs.h"
#import "User.h"
#import "Trip.h"

@implementation Blogs

@synthesize states;
@synthesize parentTrip;
@synthesize theTrip;


#pragma mark Blogs Collection Management
- (void)setFromArray:(NSArray *)data {
	self.states = [NSMutableArray array];
	
	NSDictionary *aState;
	
	for (aState in data) {
		NSDictionary *anArea;
		NSMutableArray *areas = [[NSMutableArray alloc] init];
		NSDictionary *stateDetails = [[NSDictionary alloc] initWithObjectsAndKeys:aState[@"name"], @"name", aState[@"slug"], @"urlSlug", nil];   
		
		for (anArea in aState[@"areas"][@"area"]) {
			NSDictionary *aDate;
			NSMutableArray *blogs = [[NSMutableArray alloc] init];
			NSMutableDictionary *areaDetails = [[NSMutableDictionary alloc] initWithObjectsAndKeys:anArea[@"name"], @"name", anArea[@"slug"], @"urlSlug", @NO, @"drafts", nil];
			
			for (aDate in anArea[@"dates"]) {
				Blog *blog = [[Blog alloc] initFromDictionary:aDate];
				blog.state = stateDetails;
				blog.area = areaDetails;
				blog.trip = parentTrip;
				[blogs addObject:blog];
				
				User *user = [User sharedUser];
				NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
				NSDictionary *lastBlog = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestBlog_%@",user.username]];
				
				if (lastBlog == nil || [lastBlog[@"timestamp"] intValue] < blog.timestamp) {
					NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
												(blog.area)[@"name"], @"area", 
												(blog.state)[@"name"], @"country", 
												@(blog.timestamp), @"timestamp", nil];
					[prefs setObject:dictionary forKey:[NSString stringWithFormat:@"latestBlog_%@",user.username]];
					[prefs synchronize];
				}
			}
			
			NSDictionary *area = [[NSDictionary alloc] initWithObjectsAndKeys:areaDetails,@"area", blogs, @"blogs", nil];
			[areas addObject:area];
		}
		
		
		NSDictionary *state = [[NSDictionary alloc] initWithObjectsAndKeys:
							   aState[@"name"], @"name", 
							   aState[@"slug"], @"urlSlug",
							   areas, @"areas",
							   nil];
		
		[self.states addObject:state];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"blogsDataDidLoad" object:nil];
}

- (void)addBlog:(Blog *)blog {
	if (self.states == nil) {
		self.states = [NSMutableArray array];
	}
	
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *lastBlog = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestBlog_%@",user.username]];
	
	if (lastBlog == nil || [lastBlog[@"timestamp"] intValue] < blog.timestamp) {
		NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
									(blog.area)[@"name"], @"area", 
									(blog.state)[@"name"], @"country", 
									@(blog.timestamp), @"timestamp", nil];
		[prefs setObject:dictionary forKey:[NSString stringWithFormat:@"latestBlog_%@",user.username]];
		[prefs synchronize];
	}
		
	for (NSDictionary *aState in self.states) {
		if ([aState[@"urlSlug"] isEqualToString:(blog.state)[@"urlSlug"]] || [aState[@"name"] isEqualToString:(blog.state)[@"name"]]) {
			for (NSDictionary *aArea in aState[@"areas"]) {
				if ([aArea[@"area"][@"urlSlug"] localizedCaseInsensitiveCompare:(blog.area)[@"urlSlug"]] == NSOrderedSame || [aArea[@"area"][@"name"] localizedCaseInsensitiveCompare: (blog.area)[@"name"]] == NSOrderedSame) {
					int count = 0;
					for (Blog *aBlog in aArea[@"blogs"]) {
						if (aBlog.original_timestamp == blog.original_timestamp) {
							aArea[@"blogs"][count] = blog;
							return;
						}
						count++;
					}
					[aArea[@"blogs"] insertObject:blog atIndex:0];
					theTrip.blogCount++;
					return;
				}
			}
			
			NSMutableDictionary *areaDetails = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(blog.area)[@"name"], @"name", (blog.area)[@"name"], @"urlSlug", @YES, @"drafts", nil];
			NSMutableArray *blogs = [[NSMutableArray alloc] init];
			[blogs addObject:blog];
			theTrip.blogCount++;
			NSDictionary *area = [[NSDictionary alloc] initWithObjectsAndKeys:areaDetails,@"area", blogs, @"blogs", nil];
			
			[aState[@"areas"] addObject:area];
			return;
		}
	}
	
	NSMutableDictionary *areaDetails = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(blog.area)[@"name"], @"name", (blog.area)[@"name"], @"urlSlug", @YES, @"drafts", nil];
	NSMutableArray *blogs = [[NSMutableArray alloc] init];
	[blogs addObject:blog];
	theTrip.blogCount++;
	NSDictionary *area = [[NSDictionary alloc] initWithObjectsAndKeys:areaDetails,@"area", blogs, @"blogs", nil];
	
	NSMutableArray *areas = [[NSMutableArray alloc] init];
	[areas addObject:area];
	NSDictionary *state = [[NSDictionary alloc] initWithObjectsAndKeys:
						   (blog.state)[@"name"], @"name", 
						   (blog.state)[@"name"], @"urlSlug",
						   areas, @"areas",
						   nil];

	int count = 0;
	for (NSDictionary *aState in self.states) {
		if ([aState[@"name"] caseInsensitiveCompare:state[@"name"]] == NSOrderedDescending) {
			[self.states insertObject:state atIndex:count];
			return;
		}
		count++;
	}
	[self.states insertObject:state atIndex:count];
}

- (void)deleteBlog:(Blog *)blog {
	if (self.states == nil) {
		return;
	}
	int stateCount = 0;
	for (NSDictionary *aState in self.states) {
		if ([aState[@"urlSlug"] isEqualToString:(blog.state)[@"urlSlug"]] || [aState[@"name"] isEqualToString:(blog.state)[@"name"]]) {
			int areaCount = 0;
			for (NSDictionary *aArea in aState[@"areas"]) {
				if ([aArea[@"area"][@"urlSlug"] localizedCaseInsensitiveCompare: (blog.area)[@"urlSlug"]] == NSOrderedSame || [aArea[@"area"][@"name"] localizedCaseInsensitiveCompare: (blog.area)[@"name"]] == NSOrderedSame) {
					int count = 0;
					BOOL deleted = NO;
					for (Blog *aBlog in aArea[@"blogs"]) {
						if (aBlog.original_timestamp == blog.original_timestamp) {
							[aBlog deleteBlog];
							[aArea[@"blogs"] removeObjectAtIndex:count];
							theTrip.blogCount--;
							deleted = YES;
							break;
						}
						count++;
					}
					
					if ([aArea[@"blogs"] count] == 0) {
						[aState[@"areas"] removeObjectAtIndex:areaCount];
						
						if ([aState[@"areas"] count] == 0) {
							[self.states removeObjectAtIndex:stateCount];
						}
						
						return;
					}
					
					for (Blog *aBlog in aArea[@"blogs"]) {
						if (aBlog.draft == YES && deleted == YES) {
							return;
						}
					}
					
					if (deleted == YES) {
						aArea[@"area"][@"drafts"] = @NO;
						return;
					}
				}
				areaCount++;
			}
		}
		stateCount++;
	}
}



- (void)reloadTemp {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	User *user = [User sharedUser];
	NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/Offexploring/Blog_Draft/%@", user.username]; 
	folder = [folder stringByExpandingTildeInPath];
	
	NSArray *paths = [fileManager contentsOfDirectoryAtPath:folder error:nil];
	
	for (NSString *path in paths) {
		Blog *newBlog = [NSKeyedUnarchiver unarchiveObjectWithFile:[folder stringByAppendingPathComponent:path]];
		
        // Note - this was caused by a bug in iOS 6
        if (!newBlog.state)  {
            [newBlog deleteBlog];
        }
        else {
            if ([(newBlog.trip)[@"urlSlug"] isEqualToString:(self.parentTrip)[@"urlSlug"]]){
                [self addBlog:newBlog];
            }
        }
	}
}

#pragma mark Custom Accessors 
- (Blog *)getBlogUsingTimestamp:(int)original_time andState:(NSDictionary *)theState andArea:(NSDictionary *)theArea {
	for (NSDictionary *aState in self.states) {
		if ([aState[@"urlSlug"] isEqualToString:theState[@"urlSlug"]] || [aState[@"name"] isEqualToString:theState[@"name"]]) {
			for (NSDictionary *aArea in aState[@"areas"]) {
				if ([aArea[@"area"][@"urlSlug"] localizedCaseInsensitiveCompare:theArea[@"urlSlug"]] == NSOrderedSame || [aArea[@"area"][@"name"] localizedCaseInsensitiveCompare: theArea[@"name"]] == NSOrderedSame) {
					int count = 0;
					for (Blog *aBlog in aArea[@"blogs"]) {
						if (aBlog.original_timestamp == original_time) {
							return aBlog;
						}
						count++;
					}
					return nil;
				}
			}
		}
	}
	return nil;
}

@end
