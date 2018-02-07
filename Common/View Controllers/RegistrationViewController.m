//
//  RegistrationViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 11/05/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "RegistrationViewController.h"
#import "BlogDetailTableViewCell.h"
#import "GANTracker.h"
#import "SBJson.h"

#pragma mark -
#pragma mark RegistrationViewController Private Interface
/**
	@brief Private accessors used to store temporary registration information
 
	This interface provides private accessors used to used to store temporary registration information
 */
@interface RegistrationViewController()

@property (nonatomic, strong) NSString *changeName;
@property (nonatomic, strong) NSString *changeTitle;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) NSString *welcomeMessage;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passwordRetype;
@property (nonatomic, strong) NSString *frontImage;
@property (nonatomic, strong) NSString *imageCaption;
@property (nonatomic, strong) NSString *socialProvider;
@property (nonatomic, strong) NSString *socialIdentifier;

@end

#pragma mark -
#pragma mark RegistrationViewController Implementation
@implementation RegistrationViewController

@synthesize done;
@synthesize cancel;
@synthesize table;
@synthesize delegate;
@synthesize changeName;
@synthesize changeTitle;
@synthesize dateOfBirth;
@synthesize welcomeMessage;
@synthesize email;
@synthesize username;
@synthesize password;
@synthesize passwordRetype;
@synthesize frontImage;
@synthesize imageCaption;
@synthesize socialProvider;
@synthesize socialIdentifier;

#pragma mark UIViewController Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	
		socialRegistration = NO;
		
	}
	
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	table.backgroundColor = [UIColor clearColor];
	if ([UIColor tableViewSeperatorColor]) {
        table.separatorColor = [UIColor tableViewSeperatorColor];
    }
	self.welcomeMessage = @"Optional";
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.done = nil;
	self.cancel = nil;
	self.table = nil;
}

#pragma mark IBActions
- (IBAction)donePressed {
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	
	UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
	UITextField *theTextField;
	for (UIView *nextTextField in cell.contentView.subviews) {
		theTextField = (UITextField *)nextTextField;
		username = theTextField.text;
		if ([theTextField isFirstResponder]) {
			[theTextField resignFirstResponder];
		}
		break;
	}
	
	indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
	cell = [self.table cellForRowAtIndexPath:indexPath];
	for (UIView *nextTextField in cell.contentView.subviews) {
		theTextField = (UITextField *)nextTextField;
		password = theTextField.text;
		if ([theTextField isFirstResponder]) {
			[theTextField resignFirstResponder];
		}
		break;
	}
	
	indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
	cell = [self.table cellForRowAtIndexPath:indexPath];
	for (UIView *nextTextField in cell.contentView.subviews) {
		theTextField = (UITextField *)nextTextField;
		passwordRetype = theTextField.text;
		if ([theTextField isFirstResponder]) {
			[theTextField resignFirstResponder];
		}
		break;
	}
	
	NSString *errorTitle = nil;
	
	if (username == nil || [username length] == 0) {
		errorTitle = @"Error: Please Enter Username";
	}
	else if ([username length] < 5) {
		errorTitle = @"Error: Username Too Short";
	}
	else if (password == nil || [password length] == 0) {
		errorTitle = @"Error: Please Enter Password";
	}
	else if ([password length] < 5) {
		errorTitle = @"Error: Password Too Short";
	}
	else if (![password isEqualToString:passwordRetype]) {
		errorTitle = @"Error: Passwords Don't Match";
	}
	else if (changeName == nil || [changeName length] == 0) {
		errorTitle = @"Error: Please Enter Your Full Name";
	}
	else if (changeTitle == nil || [changeTitle length] == 0) {
		errorTitle = @"Error: Please Enter A Site Title";
	}
	else if (email == nil || [email length] == 0) {
		errorTitle = @"Error: Please Enter An Email Address";
	}
	
	if (errorTitle != nil) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:errorTitle
								  message:nil
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		
		[charAlert show];
		
	}
	else {
		
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Registering...";
		[HUD show:YES];
		
		NSString *homeCountry = @"GB";
		NSString *referrer = @"IPhone";
		if (self.frontImage == nil) {
			self.frontImage = @"/journal/images/front_image.png";
		}
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd-MM-yyyy"];
		NSString *dateOfBirthText = @"";//[dateFormatter stringFromDate:dateOfBirth];
		
		if (self.welcomeMessage == nil || [self.welcomeMessage length] == 0 || [self.welcomeMessage isEqualToString:@"Optional"]) {
			self.welcomeMessage = [NSString stringWithFormat:@"This is your welcome message. It is visible to all %@ users that view your site.You can change this welcome message at a later date from the %@ website.", [NSString partnerDisplayName], [NSString partnerDisplayName]];
		}
		
		NSDictionary *postData = nil;
		
		if (socialRegistration == YES) {
			postData = @{@"username": username, @"password": password, @"passwordRetype": passwordRetype,
									  @"homeCountry": homeCountry, @"fullName": changeName, @"nickName": changeTitle, @"email": email,
									  @"dateOfBirth": dateOfBirthText, @"introductionText": welcomeMessage, @"referrer": referrer, @"frontImage": frontImage, 
										@"socialProvider": socialProvider, @"socialIdentifier": socialIdentifier};
		}
		else {
			postData = @{@"username": username, @"password": password, @"passwordRetype": passwordRetype,
									  @"homeCountry": homeCountry, @"fullName": changeName, @"nickName": changeTitle, @"email": email,
									  @"dateOfBirth": dateOfBirthText, @"introductionText": welcomeMessage, @"referrer": referrer, @"frontImage": frontImage};
		}
		
		OffexConnex *connex = [[OffexConnex alloc] init];
		connex.delegate = self;
		NSString *requestURI = [connex buildOffexRequestStringWithURI:@"user"];
		NSData *dataString = [connex paramaterBodyForDictionary:postData];
		[connex postOffexploringData:dataString withContentMode:@"application/x-www-form-urlencoded" toURL:requestURI];
		
	}
}

- (IBAction)cancelPressed {
	[delegate registrationViewControllerDidCancel:self];
}

#pragma mark Social Registration 
- (void)setSocialRegistrationDetailsWithUsername:(NSString *)dfUsername
										   email:(NSString *)dfEmail 
									 dateOfBirth:(NSString *)dfDateOfBirth 
										fullName:(NSString *)dfFullName 
									 remoteImage:(NSString *)dfRemoteImageURL 
									  identifier:(NSString *)dfIndentifier 
										provider:(NSString *)dfProvider; {
	if (dfDateOfBirth) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		NSDate *dateOfBirthText = [dateFormatter dateFromString:dfDateOfBirth];
		
        self.dateOfBirth = dateOfBirthText;
	}
	
	if (dfEmail) {
		self.email = dfEmail;
	}
	
	if (dfUsername) {
		self.username = dfUsername;		
	}
	
	if (dfFullName) {
		self.changeName = dfFullName;
		self.changeTitle = [NSString stringWithFormat:@"%@'s Travels", dfFullName];
	}
	
	if (dfRemoteImageURL) {
		self.imageCaption = [NSString stringWithFormat:@"%@ Profile Photo", dfProvider];
		self.frontImage = dfRemoteImageURL;
	}
	
	socialRegistration = YES;
	
	self.socialProvider = dfProvider;
	self.socialIdentifier = dfIndentifier;
	
	[table reloadData];
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
	else if (section == 1) {
		return 3;
	}
	else if (section == 2) {
		return 2;
	}
	else {
		return 3;
	}
}

// Set the header hight for the page
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
		headerLabel.text = @"Sign up with";
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.textColor = [UIColor headerLabelTextColor];
		headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
		headerLabel.shadowColor = [UIColor headerLabelShadowColor];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		
		[customView addSubview: headerLabel];
		
		return customView;
	}
	else if (section == 1) {
		
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
		headerLabel.text = @"Account Details";
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.textColor = [UIColor headerLabelTextColor];
		headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
		headerLabel.shadowColor = [UIColor headerLabelShadowColor];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		
		[customView addSubview: headerLabel];
		
		return customView;
	}
	else if (section == 2) {
		
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
		headerLabel.text = @"About You";
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.textColor = [UIColor headerLabelTextColor];
		headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
		headerLabel.shadowColor = [UIColor headerLabelShadowColor];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		
		[customView addSubview: headerLabel];
		
		return customView;
	}
	else {
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
		headerLabel.text = @"Site Preferences";
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.textColor = [UIColor headerLabelTextColor];
		headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
		headerLabel.shadowColor = [UIColor headerLabelShadowColor];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		
		[customView addSubview: headerLabel];
		
		return customView;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maincell"];
		UITextField *tableLabel = nil;
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"maincell"];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			tableLabel = [[UITextField alloc] initWithFrame:CGRectMake(10, 10.0, 285, 20)];
			tableLabel.textAlignment = NSTextAlignmentLeft;
			tableLabel.clearButtonMode = UITextFieldViewModeAlways;
			tableLabel.delegate = self;
			[tableLabel setAutocorrectionType:UITextAutocorrectionTypeNo];
			[tableLabel setEnabled:YES];
		}
		
		for (UIView *subView in cell.contentView.subviews) {
			[subView removeFromSuperview];
		}		
		
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fb.png"]];
		imageView.frame = CGRectMake(20, 4, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];
		
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tw.png"]];
		imageView.frame = CGRectMake(62, 4, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];
		
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gm.png"]];
		imageView.frame = CGRectMake(104, 4, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];
		
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ms.png"]];
		imageView.frame = CGRectMake(146, 4, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];
		
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fl.png"]];
		imageView.frame = CGRectMake(188, 4, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];
		
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"oi.png"]];
		imageView.frame = CGRectMake(230, 4, imageView.frame.size.width, imageView.frame.size.height);
		[cell.contentView addSubview:imageView];
		
		cell.textLabel.text = @"";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	else if (indexPath.section == 1) {
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maincell"];
		UITextField *tableLabel = nil;
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"maincell"];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			tableLabel = [[UITextField alloc] initWithFrame:CGRectMake(10, 10.0, 285, 20)];
			tableLabel.textAlignment = NSTextAlignmentLeft;
			tableLabel.clearButtonMode = UITextFieldViewModeAlways;
			tableLabel.delegate = self;
			[tableLabel setAutocorrectionType:UITextAutocorrectionTypeNo];
			[tableLabel setEnabled:YES];
		}
		else {
			tableLabel = (cell.contentView.subviews)[0];
		}
		
		if (indexPath.row == 0) {
			tableLabel.placeholder = @"Username";
			tableLabel.text = self.username;
			tableLabel.tag = 0;
		}
		else if(indexPath.row == 1) {
			tableLabel.placeholder = @"Account Password";
			tableLabel.text = self.password;
			tableLabel.tag = 1;
			[tableLabel setSecureTextEntry:YES];
		}
		else {
			tableLabel.placeholder = @"Retype Password";
			tableLabel.text = self.passwordRetype;
			tableLabel.returnKeyType = UIReturnKeyDone;
			tableLabel.tag = 2;
			[tableLabel setSecureTextEntry:YES];		
		}

		[cell.contentView addSubview:tableLabel];
		return cell;
	}
	else {		
		BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.table dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogDetailTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogDetailTableViewCell class]]) {
					cell = (BlogDetailTableViewCell *)currentObject;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
			}
		}
		
		if (indexPath.section == 2) {
			if(indexPath.row == 0) {
				cell.label.text = @"Full Name";
				cell.detail.text = changeName;
			}
			else {
				cell.label.text = @"Email";
				cell.detail.text = email;
			}
		}
		else if (indexPath.section == 3) {
			if (indexPath.row == 0) {
				cell.label.text = @"Site Title";
				cell.detail.text = changeTitle;
			}
			else if (indexPath.row == 1) {
				cell.label.text = @"Intro Message";
				cell.detail.text = welcomeMessage;
			}
			else {
				cell.label.text = @"Cover Photo";
				if (self.frontImage != nil) {
					cell.detail.text = self.imageCaption;
				}
				else {
					cell.detail.text = @"Optional";
				}
			}
			
		}
		else {
			return nil;
		}
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		[delegate showJanrainAuthenticationWithCallbackDelegate:self];
	}
	else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			[[GANTracker sharedTracker] trackPageview:@"/login/register/edit/full_name/" withError:nil];
			LocationTextViewController *ltvc = [[LocationTextViewController alloc]initWithNibName:nil bundle:nil];
			ltvc.delegate = self;
            if (!self.changeName) {
                self.changeName = @"";
            }
			ltvc.area = @{@"name": self.changeName};	
			ltvc.title = @"Full Name";
			[self presentViewController:ltvc animated:YES completion:nil];
			
		}
		else if (indexPath.row == 1) {
			[[GANTracker sharedTracker] trackPageview:@"/login/register/edit/email/" withError:nil];
			LocationTextViewController *ltvc = [[LocationTextViewController alloc]initWithNibName:nil bundle:nil];
			ltvc.delegate = self;
            if (!self.email) {
                self.email = @"";
            }
			ltvc.area = @{@"name": self.email};	
			ltvc.title = @"Email";
			[self presentViewController:ltvc animated:YES completion:nil];
		}

	}
	else if(indexPath.section == 3) {
		if (indexPath.row == 0) {
			[[GANTracker sharedTracker] trackPageview:@"/login/register/edit/site_name/" withError:nil];
			LocationTextViewController *ltvc = [[LocationTextViewController alloc]initWithNibName:nil bundle:nil];
			ltvc.delegate = self;
            
            if (!self.changeTitle) {
                self.changeTitle = @"";
            }
            
			ltvc.area = @{@"name": self.changeTitle};
			ltvc.title = @"Site Title";
			[self presentViewController:ltvc animated:YES completion:nil];
			
		}
		else if(indexPath.row == 1) {
			[[GANTracker sharedTracker] trackPageview:@"/login/register/edit/welcome/" withError:nil];
			BodyTextViewController *btvc = [[BodyTextViewController alloc] initWithNibName:nil bundle:nil];
			btvc.delegate = self;
			
			if([welcomeMessage isEqual:@"Optional"]) {
				btvc.body = @"";
			}
			else {
				btvc.body = welcomeMessage;	
			}
			
			[self presentViewController:btvc animated:YES completion:nil];
		}
		else if (indexPath.row == 2) {
			[[GANTracker sharedTracker] trackPageview:@"/login/register/edit/photo/" withError:nil];
			RegionImagePickerViewController *picker = [[RegionImagePickerViewController alloc] initWithNibName:nil bundle:nil];
			picker.delegate = self;
			picker.regionImages = YES;
			[self presentViewController:picker animated:YES completion:nil];
		}
	}

}
#pragma mark BodyTextViewController Delegate Methods
- (void)bodyTextViewController:(BodyTextViewController *)btvc didFinishEditingBody:(NSString *)bodyText {
	self.welcomeMessage = bodyText;	
	[self.table reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (void)bodyTextViewControllerDidCancel:(BodyTextViewController *)btvc {
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark OffexploringConnection Delegate Methods
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	[HUD hide:YES];
	[delegate registrationViewController:self didRegisterUserWithUsername:self.username	andPassword:self.password];
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	[HUD hide:YES];
	
	if ([self.frontImage isEqualToString:@"/journal/images/front_image.png"]) {
		self.frontImage = nil;
	}
	
	NSString *errorMessage = nil;
	if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"DOB_Year_invalid"]) {
		errorMessage = [NSString stringWithFormat:@"You are too young to register for %@", [NSString partnerDisplayName]];
	}
	else if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"Username_in_use"]) {
		errorMessage = @"The username you have requested is already in use. Please try another.";
	}
	else if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"Username_contains_bad_characters"]) {
		errorMessage = @"There are invalid characters in your username, please remove any punctuation or spaces.";
	}
	else if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"Email_invalid"]) {
		errorMessage = @"Your email address is invalid, please retype it.";
	}
	else if ([[error userInfo][NSLocalizedDescriptionKey] isEqualToString:@"No Connection Error"]) {
		errorMessage = [NSString stringWithFormat:@"We were unable to connect to %@. Please check your internet connection and retry.", [NSString partnerDisplayName]];
	}
	else {
		errorMessage = [error userInfo][NSLocalizedDescriptionKey];
	}
	
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:errorMessage
							  message:nil
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[table reloadData];
	[charAlert show];
	
}

#pragma mark UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	NSIndexPath *indexPath;
	
	if (textField.tag == 0) {
		username = textField.text;
		indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
		UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
		for (UIView *nextTextField in cell.contentView.subviews) {
			[nextTextField becomeFirstResponder];
			break;
		}
		[self.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		return YES;
	}
	else if(textField.tag == 1) {
		password = textField.text;
		indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
		UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
		for (UIView *nextTextField in cell.contentView.subviews) {
			[nextTextField becomeFirstResponder];
			break;
		}
		[self.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		return YES;	
	}
	else {
		passwordRetype = textField.text;
		[textField resignFirstResponder];
		return YES;
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField.tag == 0) {
		username = [textField.text lowercaseString];
		return YES;
	}
	else if(textField.tag == 1) {
		password = textField.text;
		return YES;	
	}
	else {
		passwordRetype = textField.text;
		return YES;
	}
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

#pragma mark LocationTextViewController Delegate Methods
- (NSString *)labelForLocationTextViewController:(LocationTextViewController *)ltvc {
	if ([ltvc.title isEqualToString:@"Full Name"]) {
		return @"Full Name";
	}
	else if ([ltvc.title isEqualToString:@"Email"]) {
		return @"Email";
	}
	else {
		return @"Site Title";
	}
}

- (void)locationTextViewController:(LocationTextViewController *)ltvc withTitle:(NSString *)title didFinishEditingLocation:(NSDictionary *)location {
	if ([ltvc.title isEqualToString:@"Full Name"]) {
		self.changeName = location[@"name"];
	}
	else if ([ltvc.title isEqualToString:@"Email"]) {
		self.email = location[@"name"];
	}
	else {
		self.changeTitle = location[@"name"];
	}

	[self.table reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationTextViewControllerDidCancel:(LocationTextViewController *)ltvc {
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark DateViewController Delegate Methods
- (void)dateViewController:(DateViewController *)dvc didSaveWithDate:(NSDate *)date {
	self.dateOfBirth = date;
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
	[table reloadData];
}

- (void)dateViewControllerDidCancel:(DateViewController *)dvc {
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark RegionImagePickerViewController Delegate Methods
- (void)regionImagePickerViewController:(RegionImagePickerViewController *)rigvc didSelectPhoto:(Photo *)photo andImage:(UIImage *)image andThumbnail:(UIImage *)thumb {
	self.frontImage = photo.imageURI;
	self.imageCaption = photo.caption;
	[self.table	reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)regionImagePickerViewControllerDidCancel:(RegionImagePickerViewController *)rigvc {
	[[GANTracker sharedTracker] trackPageview:@"/login/register/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
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
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error: Already Registered"
								  message:[NSString stringWithFormat:@"This account has already been registered for %@, please use a different account or log in", [NSString partnerDisplayName]]
								  delegate:nil
								  cancelButtonTitle:@"Ok"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else {
		NSDictionary *profileInfo = authInfo[@"profile"];
	
		[self setSocialRegistrationDetailsWithUsername:profileInfo[@"preferredUsername"]
														 email:profileInfo[@"email"] 
												   dateOfBirth:profileInfo[@"birthday"]
													  fullName:profileInfo[@"name"][@"formatted"]
												   remoteImage:profileInfo[@"photo"] 
													identifier:profileInfo[@"identifier"] 
													  provider:profileInfo[@"providerName"]];
	}
	
	
	
}

#pragma mark MBProgressHUD Delegate Methods
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}


@end
