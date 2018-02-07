//
//  HostelRatingViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 01/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelRatingViewController.h"
#import "BlogDetailTableViewCell.h"

#pragma mark -
#pragma mark HostelRatingViewController Implementation
@implementation HostelRatingViewController

@synthesize navItem;
@synthesize tableView;
@synthesize delegate;
@synthesize hostel;

#pragma mark UIViewController Methods
- (void)dealloc {
	[navItem release];
	[tableView release];
	[hostel release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	self.tableView.backgroundColor = [UIColor clearColor];
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
	self.navItem = nil;
	self.tableView = nil;
}

#pragma mark IBAction
- (IBAction)backPressed {
	[delegate hostelRatingViewControllerDidFinish:self];
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
	
	if(indexPath.row == 0) {
		cell.label.text = @"Overall";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.overall];
	}
	else if(indexPath.row == 1) {
		cell.label.text = @"Atmosphere";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.atmosphere];
	}
	else if(indexPath.row == 2) {
		cell.label.text = @"Staff";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.staff];
	}
	else if(indexPath.row == 3) {
		cell.label.text = @"Location";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.location];
	}
	else if(indexPath.row == 4) {
		cell.label.text = @"Cleanliness";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.cleanliness];
	}
	else if(indexPath.row == 5) {
		cell.label.text = @"Facilities";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.facilities];
	}
	else if(indexPath.row == 6) {
		cell.label.text = @"Safety";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.safety];
	}
	else if(indexPath.row == 7) {
		cell.label.text = @"Fun";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.fun];
	}
	else if(indexPath.row == 8) {
		cell.label.text = @"Value";
		cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.value];
	}
	return cell;
}


@end
