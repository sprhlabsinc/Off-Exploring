//
//  HostelBookingWebView.m
//  Off Exploring
//
//  Created by Off Exploring on 06/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelBookingWebView.h"
#import "AppDelegate.h"
#import "HostelViewController.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark HostelBookingWebView Private Interface
/**
	@brief Private methods used in constructing remote requests to the Hostelbookers booking page
 
	This interface provides various private methods used to construct requests to Hostelbookers for booking a room.
	First, a dictionary of key value pairs about hostel information and room information is URL encoded and and
	wrapped up into an NSURLRequest. The request is then made to Hostelbookers.
 */
@interface HostelBookingWebView() 
#pragma mark Private Method Declarations
/**
	Method formulates the request to Hostelbookers with the appropriate Hostel and Room information
 */
- (void)processHBRequest;
/**
	Constructs an NSData Object from a dictionary but encoding values using urlEncodeValue:
	@param dict The dictionary to encode
	@returns The constructed data object
 */
- (NSData *)paramaterBodyForDictionary:(NSDictionary *)dict;
/**
	Constructs a NSMutableURLRequest populated with data from a data string
	@param dataString The data string used to construct the request
	@returns The request object
 */
- (NSMutableURLRequest *)postHostelBookersData:(NSData *)dataString;
/**
	Method used to URL encode a string correctly
	@param str The string to encode
	@returns The encoded string
 */
- (NSString *)urlEncodeValue:(NSString *)str;

@end

#pragma mark -
#pragma mark HostelBookingWebView Implementation
@implementation HostelBookingWebView

@synthesize webView;
@synthesize hostel;
@synthesize room;
@synthesize people;
@synthesize activityIndicator;
@synthesize resetButton;
@synthesize doneButton;
@synthesize toolBar;

#pragma mark UIViewController Methods
- (void)dealloc {
	[toolBar release];
	[doneButton release];
	[resetButton release];
	[activityIndicator release];
	[room release];
	[hostel release];
	[webView release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self processHBRequest];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.webView = nil;
	self.activityIndicator = nil;
	self.resetButton = nil;
	self.doneButton = nil;
}

#pragma mark IBActions
- (IBAction)resetPage {
	[self processHBRequest];
}

- (IBAction)doneBooking {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/room/book/complete/" withError:nil];
	[[GANTracker sharedTracker] trackPageview:@"/home/" withError:nil];
	HostelAvailabilityViewController *havc = [self.navigationController.viewControllers objectAtIndex:0];
	HostelViewController *hvc = (HostelViewController *)havc.delegate;
	if ([hvc.delegate respondsToSelector:@selector(hostel:withRoom:wasBookedFor:dismissingHostelViewController:)]) {
		[hvc.delegate hostel:self.hostel withRoom:self.room wasBookedFor:[NSNumber numberWithInt:people] dismissingHostelViewController:hvc];
	}
}

#pragma mark Private Methods
- (void)processHBRequest {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	[dateFormatter setDateFormat:@"dd"];
	NSString *day = [dateFormatter stringFromDate:room.startDate];
	
	[dateFormatter setDateFormat:@"MM"];
	NSString *month = [dateFormatter stringFromDate:room.startDate];
	
	[dateFormatter setDateFormat:@"YYYY"];
	NSString *year = [dateFormatter stringFromDate:room.startDate];
	
	int timeInterval = [room.endDate timeIntervalSinceDate:room.startDate];
	
	NSString *days = [NSString stringWithFormat:@"%d", (timeInterval / 86400)];
	
	NSString *hostelid = [NSString stringWithFormat:@"%d", hostel.hostelid];
	
	NSString *roomString = [NSString stringWithFormat:@"beds_r_%d", room.roomid];
	
	NSString *peopleString = [NSString stringWithFormat:@"%d", people];
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  @"bkgform", @"fuseaction",
						  hostelid, @"hostel",
						  @"13283", @"affiliateid",
						  @"1", @"plpid",
						  room.currency, @"currency",
						  peopleString,roomString,
						  day, @"day",
						  month, @"month",
						  year, @"year",
						  days, @"nights",
						  @"1", @"cfID",
						  @"1", @"cfToken",
						  nil
						  ];
	
	NSURLRequest *request = [self postHostelBookersData:[self paramaterBodyForDictionary:dict]];
    [self.webView loadRequest:request];
    [dict release];
}

- (NSData *)paramaterBodyForDictionary:(NSDictionary *)dict {
	
	NSMutableString *returnString = [[NSMutableString alloc] init];
	NSArray *dictKeys = [dict allKeys];
	
	int count = 0;
	
	for (NSString *key in dictKeys) {
		[returnString appendString:key];
		[returnString appendString:@"="];
		[returnString appendString:[self urlEncodeValue:[dict objectForKey:key]]];
		if (count < ([dictKeys count] - 1)) {
			[returnString appendString:@"&"];
		}
		count++;
	}
	
	NSString *stringToReturn = returnString;
	return [stringToReturn dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSMutableURLRequest *)postHostelBookersData:(NSData *)dataString {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://secure.hb-247.com/aff-sec/index.cfm"]];
	
	NSString *contentType = @"application/x-www-form-urlencoded";
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:dataString];
	
	return request;
}

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
	
	return result;
}

#pragma mark UIWebView Delegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.activityIndicator stopAnimating];
	
	if ([self.webView.request.URL.absoluteString rangeOfString:@"https://secure.hb-247.com/aff-sec/index.cfm?fuseaction=confirm"].location == NSNotFound) {
		//NSLog(@"Page loaded - %@", self.webView.request.URL.absoluteString);
	} 
	else {
		if (success == NO) {
			success = YES;
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"Success! Booking Complete"
									  message:@"Press OK to read confirmation details. You'll also receive these by email."
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
			[charAlert show];
			
			self.navigationItem.rightBarButtonItem = self.doneButton;
			[self.navigationItem setHidesBackButton:YES animated:YES];
			self.toolBar.items = nil;
		}
	}
}

@end
