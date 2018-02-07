//
//  HostelAvailabilityViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 02/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelAvailabilityViewController.h"
#import "BlogDetailTableViewCell.h"
#import "HostelRoomViewController.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark HostelAvailabilityViewController Implementation
@implementation HostelAvailabilityViewController

@synthesize picker;
@synthesize tableView;
@synthesize startDate;
@synthesize endDate;
@synthesize delegate;
@synthesize hostel;
@synthesize backButton;
@synthesize searchButton;

#pragma mark UIViewController Methods
- (void)dealloc {
	[backButton release];
	[defaultColor release];
	[editingPath release];
	[hostel release];
	[startDate release];
	[endDate release];
	[picker release];
	[tableView release];
	[searchButton release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		UIBarButtonItem *navBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Change Dates" style:UIBarButtonItemStylePlain target:nil action:nil];
		self.navigationItem.backBarButtonItem = navBackButton;
		[navBackButton release];
	}
	
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = self.backButton;
	self.navigationItem.rightBarButtonItem = self.searchButton;
	self.title = @"Check Availability";
	
	self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	self.view.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundColor = [UIColor clearColor];
	
	if (!self.startDate) {
		self.startDate = [NSDate date];
		self.endDate = [NSDate dateWithTimeInterval:86400 sinceDate:self.startDate];
	}
	
	//self.picker.frame = CGRectMake(self.picker.frame.origin.x, self.picker.frame.origin.y + 44, self.picker.frame.size.width, self.picker.frame.size.height);
	[self.picker setDate:self.startDate animated:NO];
	[self.picker setMinimumDate:[NSDate date]];

	if (!editingPath) {
		editingPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
	}
	
	if (!defaultColor){
		defaultColor = [[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0] retain];
	}
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	[editingPath release];
	editingPath = nil;
	[defaultColor release];
	defaultColor = nil;
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.picker = nil;
	self.tableView = nil;
	self.backButton = nil;
	self.searchButton = nil;
}

#pragma mark IBActions

- (IBAction)cancel {
	[delegate hostelAvailabilityViewControllerDidFinish:self];
}

- (IBAction)search {
	
	if ([self.endDate earlierDate:self.startDate] == self.endDate) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Choose an end date after the start date."
								  message:nil
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
		
	}
	else {
		NSTimeInterval interval = [self.endDate timeIntervalSinceDate: self.startDate];
		
		int days = interval / 86400;
		
		if (days > 14) {
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"Choose an end date within 14 days of the start date."
									  message:nil
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
			[charAlert show];
			
		}
		else {
			//attempt lookup
			hostelLoad = [[Hostels alloc] init];
			hostelLoad.delegate = self;
			[hostelLoad loadRoomsForHostel:self.hostel forDate:self.startDate forDays:days];
			HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
			[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
			HUD.delegate = self;
			HUD.labelText = @"Searching For Rooms...";
			[HUD show:YES];
		}
	}
}

- (IBAction)datepickerChoseDate {
	if (editingPath.row == 0) {
		self.startDate = [self.picker date];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if ([self.endDate earlierDate:self.startDate] == self.endDate) {
			self.endDate = [NSDate dateWithTimeInterval:86400 sinceDate:self.startDate];
			cell.detailTextLabel.textColor = defaultColor;
		}
	}
	else {
		self.endDate = [self.picker date];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if ([self.endDate earlierDate:self.startDate] == self.endDate) {
			cell.detailTextLabel.textColor = [UIColor redColor];
		}
		else {
			cell.detailTextLabel.textColor = defaultColor;
		}
	}
	[self.tableView reloadData];
	[self.tableView selectRowAtIndexPath:editingPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}


#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
	headerLabel.text = @"When would you like to stay?";
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textAlignment = NSTextAlignmentLeft;
	headerLabel.textColor = [UIColor colorWithRed: 124/255.0 green: 107/255.0 blue: 77/255.0 alpha:1.0];
	headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
	headerLabel.shadowColor = [UIColor whiteColor];
	headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	
	[customView addSubview: headerLabel];
	
	return customView;
	
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"generalCell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									   reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Starts";
		cell.detailTextLabel.text = [dateFormatter stringFromDate:self.startDate];
	}
	else {
		cell.textLabel.text = @"Ends";
		cell.detailTextLabel.text = [dateFormatter stringFromDate:self.endDate];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[editingPath release];
	editingPath = [indexPath retain];
}

#pragma mark HostelLoader Delgate Methods
- (void)hostelLoader:(Hostels *)hostelLoader 
didLoadRoomsforHostelid:(NSUInteger)hostelid 
				 date:(NSDate *)date 
				 days:(NSUInteger)days {
	[HUD hide:YES];
	[hostelLoad release];
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/rooms/" withError:nil];
	HostelRoomViewController *hrvc = [[HostelRoomViewController alloc] initWithNibName:nil bundle:nil];
	hrvc.hostel = self.hostel;
	[self.navigationController pushViewController:hrvc animated:YES];
	[hrvc release];
}

- (void)hostelLoader:(Hostels *)hostelLoader 
failedToLoadRoomsforHostelid:(NSUInteger)hostelid 
				 date:(NSDate *)date 
				 days:(NSUInteger)days {
	[HUD hide:YES];
	[hostelLoad release];
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"No Rooms Available"
							  message:@"There are no rooms available for this hostel on those dates. Please retry with different dates."
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	

}

- (void)noConnectionforHostelLoader:(Hostels *)hostelLoader {
	[HUD hide:YES];
	[hostelLoad release];
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"Unable to Search For Rooms"
							  message:@"We were unable to connect to Off Exploring to search for rooms. Please try again!"
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
}

#pragma mark MBProgressHUD Delegate Methods
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}

@end
