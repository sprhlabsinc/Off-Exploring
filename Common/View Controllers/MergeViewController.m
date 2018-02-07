//
//  MergeViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 12/08/2011.
//  Copyright 2011 Off Exploring Ltd. All rights reserved.
//

#import "MergeViewController.h"
#import "Constants.h"

@implementation MergeViewController

@synthesize delegate = _delegate, tableView = _tableView, mergeButton = _mergeButton, usernameTextField = _usernameTextField, passwordTextField = _passwordTextField; 
@synthesize socialIdentifier = _socialIdentifier, socialProvider = _socialProvider, username = _username, password = _password;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString backgroundLogo2]]];
    if ([UIColor tableViewSeperatorColor]) {
        self.tableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.mergeButton = nil;
}

#pragma mark -
#pragma mark Inteface Actions

- (IBAction)cancelButtonPressed {
	[_delegate mergeViewControllerDidCancel:self];
}

- (IBAction)mergeButtonPressed {
	self.username = self.usernameTextField.text;
	self.password = self.passwordTextField.text;
	
	if ([self.username length] == 0) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"You must enter a username"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else if ([self.username length] == 0) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"You must enter a password"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else {
		
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Merging...";
		[HUD show:YES];
		
		
		NSDictionary *postData = nil;
		
		postData = @{@"username": self.username, @"password": self.password, 
					@"socialProvider": self.socialProvider, @"socialIdentifier": self.socialIdentifier};
		
		OffexConnex *connex = [[OffexConnex alloc] init];
		connex.delegate = self;
		NSString *requestURI = [connex buildOffexRequestStringWithURI:@"auth/social/merge"];
		NSData *dataString = [connex paramaterBodyForDictionary:postData];
		[connex postOffexploringData:dataString withContentMode:@"application/x-www-form-urlencoded" toURL:requestURI];
	}
}

#pragma mark -
#pragma mark OffexploringConnection Delegate Methods
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	[HUD hide:YES];
	[_delegate mergeViewController:self didMergeAccountWithUsername:self.username password:self.password];
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	[HUD hide:YES];
	
	NSString *errorMessage = nil;
	if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"incorrect_username_or_password"]) {
		errorMessage = [NSString stringWithFormat:@"You did not enter the correct login details for your %@ account", [NSString partnerDisplayName]];
	}
	else {
		errorMessage = [error userInfo][NSLocalizedDescriptionKey];
	}
	
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"Error"
							  message:errorMessage
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
}


#pragma mark -
#pragma mark UITableView Delegate and Data Source Methods

// Build the header label for the page
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
	
	if (section == 0) {
		headerLabel.text = [NSString stringWithFormat:@"Enter Your %@ Account Details", [NSString partnerDisplayName]];
	}
	
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textAlignment = NSTextAlignmentLeft;
	headerLabel.textColor = [UIColor headerLabelTextColor];
	headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
	headerLabel.shadowColor = [UIColor headerLabelShadowColor];
	headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	
	[customView addSubview: headerLabel];
	
	return customView;
}

// Set the header hight for the page
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44.0;
}

// Build the cell being requested
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maincell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"maincell"];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	for (UIView *subView in cell.contentView.subviews) {
		[subView removeFromSuperview];
	}
	
	UITextField *tableLabel = [[UITextField alloc] initWithFrame:CGRectMake(10, 12.0, cell.contentView.bounds.size.width - 35, 25)];
	tableLabel.textAlignment = NSTextAlignmentLeft;
	tableLabel.clearButtonMode = UITextFieldViewModeAlways;
	tableLabel.delegate = self;
	[tableLabel setAutocorrectionType:UITextAutocorrectionTypeNo];
	[tableLabel setEnabled:YES];
	
	if (indexPath.row == 0) {
		tableLabel.placeholder = @"Username";
		tableLabel.returnKeyType = UIReturnKeyNext;
		tableLabel.tag = 0;
		self.usernameTextField = tableLabel;
	}
	else {
		tableLabel.placeholder = @"Password";
		tableLabel.returnKeyType = UIReturnKeyDone;
		tableLabel.tag = 1;
		[tableLabel setSecureTextEntry:YES];
		self.passwordTextField = tableLabel;
	}
	[cell.contentView addSubview:tableLabel];
	
	return cell;
}

// Set number of rows (2 as username and password)
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 2;
}

#pragma mark -
#pragma mark UITextField Delegate Method
// Method to only allow save button to be pressed if a password is input
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.tag == 1) {
		if (![string isEqualToString:@""]) {
			self.mergeButton.enabled = YES;
		}
		else {
			if ([textField.text length] == 1) {
				self.mergeButton.enabled = NO;
			}
		}
	}
	return YES;
}

// Handle enter button presses - either advance the first responder or attempt login
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (textField.tag == 0) {
		
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		for (UIView *nextTextField in cell.contentView.subviews) {
			[nextTextField becomeFirstResponder];
			break;
		}
		return YES;
	}
	else {
		if ([textField.text isEqualToString:@""]) {
			return NO;
		}
		else {
			[textField resignFirstResponder];
			[self mergeButtonPressed];
			return YES;
		}
	}
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	self.mergeButton.enabled = NO;
	return YES;
}

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
}

@end
