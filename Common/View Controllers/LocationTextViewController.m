//
//  LocationTextViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 30/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "LocationTextViewController.h"
#import "Constants.h"

#pragma mark -
#pragma mark LocationTextViewController Implementation
@implementation LocationTextViewController

@synthesize area;
@synthesize delegate;
@synthesize locationName;
@synthesize textLabel;
@synthesize navBar;

#pragma mark UIViewController Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	if (self.title != nil) {
		self.navBar.topItem.title = self.title;
	}
	
	if ([delegate respondsToSelector:@selector(labelForLocationTextViewController:)] == YES) {
		self.textLabel.text = [delegate labelForLocationTextViewController:self];
	}
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString datepicker2]]];
	
	[self.locationName becomeFirstResponder];
	
	if (self.area) {
		self.locationName.text = (self.area)[@"name"];
	}
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.locationName = nil;
	self.textLabel = nil;
	self.navBar = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark IBActions
- (IBAction)cancel {
	[delegate locationTextViewControllerDidCancel:self];
}

- (IBAction)save {
	NSString *locationNameText = [self.locationName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	self.area = [[NSDictionary alloc] initWithObjectsAndKeys:locationNameText, @"name", nil];
	[delegate locationTextViewController:self withTitle:self.navBar.topItem.title didFinishEditingLocation:self.area];
}

#pragma mark UITextField Delegate Methods
- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.area = [[NSDictionary alloc] initWithObjectsAndKeys:textField.text, @"name", nil];
	[textField resignFirstResponder];
	[delegate locationTextViewController:self withTitle:self.navBar.topItem.title didFinishEditingLocation:self.area];
	return YES;
}

@end
