//
//  HostelInfoViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 01/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelInfoViewController.h"
#import "BlogDetailTableViewCell.h"
#import "StringHelper.h"

#pragma mark -
#pragma mark HostelInfoViewController Implementation
@implementation HostelInfoViewController

#pragma mark UIViewController Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:@"HostelRatingViewController" bundle:nil];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (!hostel.features) {
		hostel.features = [hostel loadFeatures];
	}
	self.navItem.title = @"More Information";
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (![hostel.importantinfo isEqualToString:@""] && ![hostel.checkin isEqualToString:@""]) {
		return 3;
	}
	if (![hostel.importantinfo isEqualToString:@""] || ![hostel.checkin isEqualToString:@""]) {
		return 2;
	}
	else {
		return 1;
	}
	
}

// Build the header label for the page
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
		if (section == 0) {
			headerLabel.text = @"Hostel Features";
		}
		else if (section == 1 && ![hostel.checkin isEqualToString:@""]) {
			headerLabel.text = @"Check In Information";
		}
		else {
			headerLabel.text = @"Important Information";
		}
			
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.textColor = [UIColor colorWithRed: 124/255.0 green: 107/255.0 blue: 77/255.0 alpha:1.0];
		headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
		headerLabel.shadowColor = [UIColor whiteColor];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		
		[customView addSubview: headerLabel];
		
		
		return customView;
	
}

// Set the header hight for the page
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [hostel.features count];
	}
	else if (section == 1 && ![hostel.checkin isEqualToString:@""]) {
		return 2;
	}
	else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2 || (indexPath.section == 1 && [hostel.checkin isEqualToString:@""])) {
		NSString *hostelDescriptionString = hostel.importantinfo;
		return [hostelDescriptionString RAD_textHeightForSystemFontOfSize:15.0] + 20.0;
	}
	else {
		return 40.0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0 || (indexPath.section == 1 && ![hostel.checkin isEqualToString:@""])) {
		BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogDetailTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogDetailTableViewCell class]]) {
					cell = (BlogDetailTableViewCell *)currentObject;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				}
			}
		}
		if (indexPath.section == 1) {
			if(indexPath.row == 0) {
				cell.label.text = @"Check In";
				cell.detail.text = hostel.checkin;
			}
			else if(indexPath.row == 1) {
				cell.label.text = @"Check Out";
				cell.detail.text = hostel.checkout;
			}
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			cell.label.text = [hostel.features objectAtIndex:indexPath.row];
			cell.detail.text = @"";
		}
		return cell;
	}
	else {
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
		NSString *hostelDescriptionString = hostel.importantinfo;
		UILabel *cellLabel = [hostelDescriptionString RAD_newSizedCellLabelWithSystemFontOfSize:15.0];
		[cell.contentView addSubview:cellLabel];
		return cell;
	}
}

@end
