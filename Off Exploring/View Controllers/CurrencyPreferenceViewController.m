//
//  CurrencyPreferenceViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 03/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "CurrencyPreferenceViewController.h"
#import "Constants.h"

#pragma mark -
#pragma mark CurrencyPreferenceViewController Implementation
@implementation CurrencyPreferenceViewController

@synthesize tableView;
@synthesize delegate;

#pragma mark UIViewController Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	oldCode = [prefs objectForKey:@"currency"][@"name"];
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
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
}

#pragma mark IBActions
- (IBAction)cancel {
	[delegate currencyPreferenceViewControllerDidCancel:self];
}

- (IBAction)set {
	NSString *defCur = nil;
	NSString *defCurName = nil;
	NSString *defCurSymbol = nil;
	
	if (selectedPath.row == 0) {
		defCur = @"USD";
		defCurName = @"United States, Dollars";
		defCurSymbol = @"$";
	}
	else if (selectedPath.row == 1) {
		defCur = @"GBP";
		defCurName = @"United Kingdom, Pounds";
		defCurSymbol = @"£";
	}
	else if (selectedPath.row == 2) {
		defCur = @"CAD";
		defCurName = @"Canada, Dollars";
		defCurSymbol = @"$";
	}
	else if (selectedPath.row == 3) {
		defCur = @"AUD";
		defCurName = @"Australia, Dollars";
		defCurSymbol = @"$";
	}
	else if (selectedPath.row == 4) {
		defCur = @"EUR";
		defCurName = @"Euro Member Countries, Euro";
		defCurSymbol = @"€";
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *currency = @{@"code": defCur, @"name": defCurName, @"symbol": defCurSymbol};
	
	[prefs setObject:currency forKey:@"currency"];
	[prefs synchronize];
	
	[delegate currencyPreferenceViewController:self didSetCurrency:defCurName];
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"generalCell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									   reuseIdentifier:CellIdentifier];
	}
	
	if (indexPath.row == 0) {
		cell.textLabel.text = @"United States, Dollars";
	}
	else if (indexPath.row == 1) {
		cell.textLabel.text = @"United Kingdom, Pounds";
	}
	else if (indexPath.row == 2) {
		cell.textLabel.text = @"Canada, Dollars";
	}
	else if (indexPath.row == 3) {
		cell.textLabel.text = @"Australia, Dollars";
	}
	else if (indexPath.row == 4) {
		cell.textLabel.text = @"Euro Member Countries, Euro";
	}
	
	if ([oldCode isEqualToString:cell.textLabel.text] && !selectedPath) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	selectedPath = indexPath;
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

@end
