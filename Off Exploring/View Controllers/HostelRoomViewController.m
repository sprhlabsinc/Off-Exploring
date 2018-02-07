//
//  HostelRoomViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 03/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelRoomViewController.h"
#import "Hostels.h"
#import "User.h"
#import "HostelBookingWebView.h"
#import "GANTracker.h"
#import "Reachability.h"

#pragma mark -
#pragma mark HostelRoomViewController Implementation
@implementation HostelRoomViewController

@synthesize tableView;
@synthesize hostel;
@synthesize rooms;

#pragma mark UIViewController Methods
- (void)dealloc {
	[selectedRoom release];
	[actionSheet release];
	[rooms release];
	[hostel release];
	[tableView release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Rooms Available";
	if ([rooms count] == 0) {
		self.rooms = [Hostels loadRoomsFromDBForHostelid:hostel.hostelid];
	}
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor clearColor];
	self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background]]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	[selectedRoom release];
	selectedRoom = nil;
	[actionSheet release];
	actionSheet = nil;
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.tableView = nil;
	self.rooms = nil;
}

#pragma mark Actions

- (void)bookHostel:(id)button {
	UIButton *thebutton = (UIButton *)button;
	
	if (selectedRoom) {
		[selectedRoom release];
	}
	
	selectedRoom = [[rooms objectAtIndex:thebutton.tag] retain];
	
	actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	
	CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
	
	UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
	pickerView.showsSelectionIndicator = YES;
	pickerView.dataSource = self;
	pickerView.delegate = self;
	
	
	UIToolbar * pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
	[pickerDateToolbar sizeToFit];
	
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(pickerCancelClick)];
	[barItems addObject:cancelBtn];
	
	
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace];
	
	UIBarButtonItem *titleBtn = [[UIBarButtonItem alloc] initWithTitle:@"No. of People" style:UIBarButtonItemStylePlain target:nil action:nil];
	[barItems addObject:titleBtn];
	
	UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace2];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClick)];
	[barItems addObject:doneBtn];
	
	[pickerDateToolbar setItems:barItems animated:YES];
	[barItems release];
	[actionSheet addSubview:pickerDateToolbar];
	[actionSheet addSubview:pickerView];
	[actionSheet showInView:self.view];
	[actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
	
	int bedmultiplier = selectedRoom.blockbeds;
	if (bedmultiplier == 0) {
		bedmultiplier = 1;
	}
	people = 1 * bedmultiplier;
}

- (void)pickerDoneClick {
	[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	
	Reachability *r = [Reachability reachabilityWithHostName:@"www.hostelbookers.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/room/book/" withError:nil];
		HostelBookingWebView *hbwv = [[HostelBookingWebView alloc] initWithNibName:nil bundle:nil];
		hbwv.hostel = self.hostel;
		hbwv.room = selectedRoom;
		hbwv.people = people;
		[self.navigationController pushViewController:hbwv animated:YES];
		[hbwv release];
	}
	else {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Off Exploring Connection Error"
								  message:@"Unable to book hostel, please check your internet connection and retry."
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
}

- (void)pickerCancelClick { 
	[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [rooms count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"generalCell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									   reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	cell.textLabel.backgroundColor = [UIColor whiteColor];
	cell.backgroundColor = [UIColor whiteColor];
	
	Room *room = [rooms objectAtIndex:indexPath.section];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	
	
	if (indexPath.row == 0) {
		cell.textLabel.text = room.roomName;
		cell.detailTextLabel.text = @"";
		cell.textLabel.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
		cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
	}
	else if (indexPath.row == 1) {
		cell.textLabel.text = @"Available Beds";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", room.beds];
	}
	else if (indexPath.row == 2) {
		cell.textLabel.text = @"Start Date";
		cell.detailTextLabel.text = [dateFormatter stringFromDate:room.startDate];
	}
	else if (indexPath.row == 3) {
		cell.textLabel.text = @"End Date";
		cell.detailTextLabel.text = [dateFormatter stringFromDate:room.endDate];
	}
	else if (indexPath.row == 4) {
		User *user = [User sharedUser];
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		NSDictionary *lastHostelLookup = [[prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]] retain];
		NSString *currencySymbol = [[lastHostelLookup objectForKey:@"currency"] objectForKey:@"symbol"];
		[lastHostelLookup release];
		cell.textLabel.text = @"Price Per Person";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%.2f",currencySymbol, room.pricefrom];
	}
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 44.0)];		
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setBackgroundImage:[UIImage imageNamed:@"greenButton.png"] forState:UIControlStateNormal];
	[button setTitle:@"Book Room" forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.frame = CGRectMake(10, 10, 300.0, 40.0);
	button.tag = section;
	[button addTarget:self action:@selector(bookHostel:) forControlEvents:UIControlEventTouchUpInside];
	[customView addSubview: button];
	return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 84;
}

#pragma mark UIPickerView Delegate and Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	int bedmultiplier = selectedRoom.blockbeds;
	if (bedmultiplier == 0) {
		bedmultiplier = 1;
	}
	return selectedRoom.beds / bedmultiplier;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	int num = row +1;
	int bedmultiplier = selectedRoom.blockbeds;
	if (bedmultiplier == 0) {
		bedmultiplier = 1;
	}
	num = num * bedmultiplier;
	return [NSString stringWithFormat:@"%d", num];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	int bedmultiplier = selectedRoom.blockbeds;
	if (bedmultiplier == 0) {
		bedmultiplier = 1;
	}
	people = (row + 1) * bedmultiplier;
}

@end
