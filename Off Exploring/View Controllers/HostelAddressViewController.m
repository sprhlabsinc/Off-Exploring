//
//  HostelAddressViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 01/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelAddressViewController.h"
#import "StringHelper.h"

#pragma mark -
#pragma mark HostelAddressViewController Implementation
@implementation HostelAddressViewController

#pragma mark UIViewController Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:@"HostelRatingViewController" bundle:nil];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navItem.title = @"Hostel Address";
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *hostelDescriptionString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@", hostel.name, hostel.street1, hostel.street2, hostel.street3, hostel.city, hostel.state, hostel.country, hostel.zip];
	return [hostelDescriptionString RAD_textHeightForSystemFontOfSize:15.0] + 20.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"generalCell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	if ([[cell.contentView subviews] count] > 0) {
		UIView *labelToClear = [[cell.contentView subviews] objectAtIndex:0];
		[labelToClear removeFromSuperview];
	}
	NSString *hostelDescriptionString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@", hostel.name, hostel.street1, hostel.street2, hostel.street3, hostel.city, hostel.state, hostel.country, hostel.zip];
	UILabel *cellLabel = [hostelDescriptionString RAD_newSizedCellLabelWithSystemFontOfSize:15.0];
	[cell.contentView addSubview:cellLabel];
	
	return cell;
}

@end
