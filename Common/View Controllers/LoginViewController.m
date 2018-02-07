//
//  LoginViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 06/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "GANTracker.h"
#import "SBJson.h"

#pragma mark -
#pragma mark LoginViewController Private Interface
/**
	@brief Private method used to attempt to login to Off Exploring
 
	This interface provides a private method used to attempt to login to Off Exploring with the username and password
	stored in the textfields.
 */
@interface LoginViewController()

#pragma mark Private Method Declarations
/**
	Begins a remote login request to Off Exploring
 */
- (void)loginToOffex;

/**
	Begins a remote login request to Off Exploring with a given username and password
 */
- (void)loginToOffexWithUsername:(NSString *)username password:(NSString *)password;

@end

#pragma mark -
#pragma mark LoginViewController Implementation
@implementation LoginViewController

@synthesize theTableView;
@synthesize saveButton;
@synthesize offex;
@synthesize registerUser;
@synthesize delegate;
@synthesize jrauthdelegate = _jrauthdelegate;
@synthesize cancelButton = _cancelButton;

#pragma mark UIViewController Methods
- (void)dealloc {
	self.jrauthdelegate = nil;
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		offex = [[OffexploringLogin alloc] init];
		offex.delegate = self;
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[offex logOut];
    self.theTableView.backgroundColor = [UIColor clearColor];
    if ([UIColor tableViewSeperatorColor]) {
        self.theTableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString backgroundLogo2]]];
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
	self.theTableView = nil;
	self.saveButton = nil;
	//self.registerUser = nil;
    self.cancelButton = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark IBActions
- (IBAction)attemptRegister {
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	RegistrationViewController *registration = [[RegistrationViewController alloc] initWithNibName:nil bundle:nil];
	registration.delegate = self;
	[self presentViewController:registration animated:YES completion:nil];
}

- (IBAction)attemptLogin {
	[self loginToOffex];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.delegate loginViewControllerDidCancel:self];
    
}

#pragma mark Private Methods
- (void) loginToOffex {
	
	// Retrieve the username and password for the user from the textfields
	UITextField *theTextField;
	NSString *username = @"";
	NSString *password = @"";
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	UITableViewCell *cell = [self.theTableView cellForRowAtIndexPath:indexPath];
	for (UIView *nextTextField in cell.contentView.subviews) {
		theTextField = (UITextField *)nextTextField;
		username = theTextField.text;
		if ([theTextField isFirstResponder]) {
			[theTextField resignFirstResponder];
		}
		break;
	}
	indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
	cell = [self.theTableView cellForRowAtIndexPath:indexPath];
	for (UIView *nextTextField in cell.contentView.subviews) {
		theTextField = (UITextField *)nextTextField;
		password = theTextField.text;
		if ([theTextField isFirstResponder]) {
			[theTextField resignFirstResponder];
		}
		break;
	}
	
	if (username == nil || password == nil) {
		
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"Username or Password not set, please check them and retry."
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		
		[charAlert show];
		
		
	}
	else {
		[self loginToOffexWithUsername:username password:password];
	}
}

- (void)loginToOffexWithUsername:(NSString *)username password:(NSString *)password {
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Logging in...";
	[HUD show:YES];
	[offex attemptOffexploringAuthorisationWithUsername:username andPassword:password];
}

#pragma mark OffexploringConnection Delegate Methods
- (void)offexploringLogin:(OffexploringLogin *)login didLoginWithUsername:(NSString *)username andPassword:(NSString *)password {
	[HUD hide:YES];
	usedUsername = username;
	usedPassword = password;
    [self.delegate loginViewController:self didLoginWithUsername:username andPassword:password];
}

- (void)offexploringLoginFailed:(OffexploringLogin *)login {
	[self offexploringLoginFailed:login withMessage:@"Your username and password could not be authenticated. Please check them and retry."];
}

- (void)offexploringLoginFailed:(OffexploringLogin *)login withMessage:(NSString *)string {
	[HUD hide:YES];
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"Error: Could Not Login"
							  message:string
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	
	[charAlert show];
	
}

#pragma mark UIAlertView Delegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alertView.title isEqualToString:@"Register or Merge"]) {
		if (buttonIndex == 1) {
			RegistrationViewController *registrationView = [[RegistrationViewController alloc] initWithNibName:nil bundle:nil];
			registrationView.delegate = self;
			
			NSDictionary *profileInfo = authData[@"profile"];
			
			[registrationView setSocialRegistrationDetailsWithUsername:profileInfo[@"preferredUsername"]
																 email:profileInfo[@"email"] 
														   dateOfBirth:profileInfo[@"birthday"]
															  fullName:profileInfo[@"name"][@"formatted"]
														   remoteImage:profileInfo[@"photo"] 
															identifier:profileInfo[@"identifier"] 
															  provider:profileInfo[@"providerName"]];
			
			[self presentViewController:registrationView animated:YES completion:nil];
		}
		else if (buttonIndex == 2) {
			NSDictionary *profileInfo = authData[@"profile"];
			
			MergeViewController *mergeViewController = [[MergeViewController alloc] initWithNibName:nil bundle:nil];
			mergeViewController.delegate = self;
			mergeViewController.socialIdentifier = profileInfo[@"identifier"];
			mergeViewController.socialProvider = profileInfo[@"providerName"];
			[self presentViewController:mergeViewController animated:YES completion:nil];
		}
	}
	else {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		UITableViewCell *cell = [self.theTableView cellForRowAtIndexPath:indexPath];
		for (UIView *nextTextField in cell.contentView.subviews) {
			[nextTextField becomeFirstResponder];
			break;
		}
	}
}

#pragma mark UITextField Delegate Method
// Method to only allow save button to be pressed if a password is input
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.tag == 1) {
		if (![string isEqualToString:@""]) {
			saveButton.enabled = YES;
		}
		else {
			if ([textField.text length] == 1) {
				saveButton.enabled = NO;
			}
		}
	}
	return YES;
}

// Handle enter button presses - either advance the first responder or attempt login
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (textField.tag == 0) {
		
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
		UITableViewCell *cell = [self.theTableView cellForRowAtIndexPath:indexPath];
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
			[self loginToOffex];
			return YES;
		}
	}
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	saveButton.enabled = NO;
	return YES;
}

#pragma mark UITableView Delegate and Data Source Methods
// Build the header label for the page
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
	
	if (section == 0) {
		headerLabel.text = @"Log in to your existing account";
	}
	else {
		headerLabel.text = @"Or sign in with";
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

#pragma mark UITableView Delegate and Data Source Methods
// Build the header label for the page
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
    if (section == 1) {
        
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 15, 300, 29)];
        
        headerLabel.text = @"Or";
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.textColor = [UIColor headerLabelTextColor];
        headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
        headerLabel.shadowColor = [UIColor headerLabelShadowColor];
        headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        
        [customView addSubview: headerLabel];
        
        return customView;
        
    }
    
    return nil;
}

// Set the header hight for the page
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44.0;
}

// Set the header hight for the page
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 1) {
        return 44.0;
    }
    
    return 0;
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
	
	if (indexPath.section == 0) {
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
		}
		else {
			tableLabel.placeholder = @"Password";
			tableLabel.returnKeyType = UIReturnKeyDone;
			tableLabel.tag = 1;
			[tableLabel setSecureTextEntry:YES];
		}
		[cell.contentView addSubview:tableLabel];
	}
	else {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fb.png"]];
		imageView.frame = CGRectMake(20, 6, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];
		
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tw.png"]];
		imageView.frame = CGRectMake(62, 6, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];

		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gm.png"]];
		imageView.frame = CGRectMake(104, 6, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];

		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ms.png"]];
		imageView.frame = CGRectMake(146, 6, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];

		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fl.png"]];
		imageView.frame = CGRectMake(188, 6, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];

		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"oi.png"]];
		imageView.frame = CGRectMake(230, 6, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];
		
		cell.textLabel.text = @"";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

// Set number of rows (2 as username and password)
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 2;
	}
	else {
		return 1;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		[self showJanrainAuthenticationWithCallbackDelegate:self];
	}
}

#pragma mark Janrain accessors 

- (void)showJanrainAuthenticationWithCallbackDelegate:(id <LoginViewControllerJRAuthDelegate>)jrAuthDelegate {
	self.jrauthdelegate = jrAuthDelegate;
	
	NSString *tokenURL = [NSString stringWithFormat:@"%@auth/social.json?key=%@", OFFEX_API_ADDRESS, OFFEX_API_KEY];
	
	[JREngage setEngageAppId:TARGET_PARTNER_JANRAIN_APP_ID
                    tokenUrl:tokenURL
                 andDelegate:self];
	
	[JREngage showAuthenticationDialog];
}

#pragma mark JREngageDelegate Methods
- (void)engageDialogDidFailToShowWithError:(NSError*)error { 
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"Error"
							  message:[error localizedDescription]
							  delegate:nil
							  cancelButtonTitle:@"Dismiss"
							  otherButtonTitles:nil];
	[charAlert show];
	
}

- (void)authenticationDidNotComplete { 
	// Do nothing, should simply be dismissed
}

- (void)authenticationDidSucceedForUser:(NSDictionary*)auth_info
                              forProvider:(NSString*)provider { 
	authData = auth_info;
}

- (void)authenticationDidFailWithError:(NSError*)error
                             forProvider:(NSString*)provider { 
    UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"Error"
							  message:@"A problem occured with social sign in, please retry."
							  delegate:nil
							  cancelButtonTitle:@"Dismiss"
							  otherButtonTitles:nil];
	[charAlert show];
	
}

- (void)authenticationDidReachTokenUrl:(NSString*)tokenUrl
                            withResponse:(NSURLResponse*)response
                              andPayload:(NSData*)tokenUrlPayload
                             forProvider:(NSString*)provider {
	[self.jrauthdelegate loginViewController:self jrAuthenticationDidReachTokenUrl:tokenUrl withResponse:response andPayload:tokenUrlPayload forProvider:provider authInfo:authData];
}

- (void)authenticationCallToTokenUrl:(NSString*)tokenUrl
                      didFailWithError:(NSError*)error
                           forProvider:(NSString*)provider { 
	
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"Error"
							  message:@"A problem occured with social sign in, please retry."
							  delegate:nil
							  cancelButtonTitle:@"Dismiss"
							  otherButtonTitles:nil];
	[charAlert show];
	
}

#pragma mark LoginViewControllerJRAuthDelegate Methods
- (void)loginViewController:(LoginViewController *)login 
jrAuthenticationDidReachTokenUrl:(NSString*)tokenUrl
			   withResponse:(NSURLResponse*)response
				 andPayload:(NSData*)tokenUrlPayload
				forProvider:(NSString*)provider
				   authInfo:(NSDictionary *)authInfo {
	
	NSString *responseString = [[NSString alloc] initWithData:tokenUrlPayload encoding:NSUTF8StringEncoding];
	NSDictionary *results = [responseString JSONValue];
	
	if ([results[@"response"][@"success"] isEqualToNumber:@YES]) {
		NSString *username = results[@"response"][@"username"];
		NSString *password = results[@"response"][@"password"];
		
		[self loginToOffexWithUsername:username password:password];
	}
	else {
		if ([results[@"response"][@"error"] isEqualToString:@"user_does_not_exist"]) {
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"Register or Merge"
									  message:[NSString stringWithFormat:@"We cannot find this account in our system. You can register a new %@ account or merge this social account with an existing %@ account", [NSString partnerDisplayName], [NSString partnerDisplayName]]
									  delegate:self
									  cancelButtonTitle:@"Cancel"
									  otherButtonTitles:@"Register New Account", @"Merge Current Account", nil];
			[charAlert show];
			
		}
		else {
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"Error"
									  message:@"A problem occured with social sign in, please retry."
									  delegate:nil
									  cancelButtonTitle:@"Dismiss"
									  otherButtonTitles:nil];
			[charAlert show];
			
		}
	}
}

#pragma mark RegistrationViewController Delegate Methods
- (void) registrationViewController:(RegistrationViewController *)rvc didRegisterUserWithUsername:(NSString *)username andPassword:(NSString *)password {
	rvc.delegate = nil;
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Saving...";
	[HUD show:YES];
	[offex attemptOffexploringAuthorisationWithUsername:username andPassword:password];
}

- (void) registrationViewControllerDidCancel:(RegistrationViewController *)rvc {
	rvc.delegate = nil;
	[[GANTracker sharedTracker] trackPageview:@"/login/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];	
}

#pragma mark MergeViewController Delegate Methods
- (void)mergeViewControllerDidCancel:(MergeViewController *)mergeViewController {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mergeViewController:(MergeViewController *)mergeViewController didMergeAccountWithUsername:(NSString *)username password:(NSString *)password {
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Saving...";
	[HUD show:YES];
	[offex attemptOffexploringAuthorisationWithUsername:username andPassword:password];
}

#pragma mark MBProgressHUD Delegate Method
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	if (usedUsername != nil && usedPassword != nil) {
		[delegate loginViewController:self didLoginWithUsername:usedUsername andPassword:usedPassword];
	}
}

@end
