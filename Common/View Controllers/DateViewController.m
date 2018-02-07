//
//  DateViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 28/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "DateViewController.h"
#import "User.h"
#import "Constants.h"

#pragma mark -
#pragma mark DateViewController Implementation

@implementation DateViewController

@synthesize dateLabel;
@synthesize delegate;
@synthesize theDate;
@synthesize picker;

#pragma mark UIVIewController Methods
- (void)dealloc {
	delegate = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppClose:) name:UIApplicationWillTerminateNotification object:nil];
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString datepicker2]]];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	
	if (self.theDate == nil) {
		self.theDate = [NSDate date];
	}
	
	dateLabel.text = [dateFormatter stringFromDate:self.theDate];
	self.picker.date = theDate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.picker	= nil;
	self.dateLabel = nil;
}

- (void)handleAppClose:(NSNotification *)notification {
	User *user = [User sharedUser];
	if (user.editingBlog == YES) {	
		[[NSUserDefaults standardUserDefaults] setObject:self.theDate forKey:@"autoSavedDate"];
	}
}

#pragma mark IBActions
- (IBAction)cancel {
	[delegate dateViewControllerDidCancel:self];
}

- (IBAction)save {
	[delegate dateViewController:self didSaveWithDate:self.theDate];

}
- (IBAction)datePicked:(id)sender{
	UIDatePicker *thePicker = (UIDatePicker *)sender;
	
	self.theDate = [thePicker date];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	
	dateLabel.text = [dateFormatter stringFromDate:theDate];	
}

@end
