//
//  SettingsViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 06/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "User.h"
#import "GANTracker.h"
#import "SettingsTableViewCell.h"
#import "OffexConnex.h"
#import "LocationTextViewController.h"
#import "BodyTextViewController.h"
#import "Reachability.h"
#import "Constants.h"

#define PROFILE_PHOTO_TAG 99999
#define CLEAR_TEMPORARY_TAG 88888

@interface SettingsViewController() <OffexploringConnectionDelegate, LocationTextViewControllerDelegate, BodyTextViewControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, retain) UIImage *profilePhoto;
@property (nonatomic, retain) UIImage *profilePhotoChanged;
@property (nonatomic, assign) NSInteger editingTag;
@property (nonatomic, retain) NSOperationQueue *saveImageQueue;
@property (nonatomic, assign) BOOL userDataChanged;
@property (nonatomic, retain) UIImagePickerController *pickerView;
@property (nonatomic, retain) ImageLoader *imageLoader;

- (void)saveImage:(UIImage *)image;
- (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
@end

#pragma mark -
#pragma mark SettingsViewController Implementation
@implementation SettingsViewController

@synthesize root;
@synthesize tableView = _tableView;
@synthesize profilePhoto;
@synthesize editingTag;
@synthesize saveImageQueue = _saveImageQueue;
@synthesize userDataChanged;
@synthesize profilePhotoChanged;
@synthesize pickerView;
@synthesize imageLoader = _imageLoader;

#pragma mark UIViewController Methods

- (void) viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.userDataChanged = NO;
    
    User *user = [User sharedUser];
    [user loadUserInfo];
    [self.tableView reloadData];
    
    // Only attempt to update the user if the api is live
    Reachability *r = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {        
        OffexConnex *connex = [[OffexConnex alloc] init];
        NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@", user.username]];
        connex.delegate = self;
        [connex beginLoadingOffexploringDataFromURL:url];
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setTableView:nil];
	// Release any retained subviews of the main view.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark OffexploringConnection Delegate
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
    
    User *user = [User sharedUser];
    [user setFromDictionary:results[@"response"]];
    [user saveUserInfo];
    
    // Editing
    if ([results[@"request"][@"method"] isEqualToString:@"POST"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.tableView reloadData];
    
        ImageLoader *imageLoader = [[ImageLoader alloc] init];
        imageLoader.delegate = self;
        [imageLoader startDownloadForURL:user.frontImageUrl];
        self.imageLoader = imageLoader;
    }
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *)error {
    UIAlertView *charAlert = nil;
	
    User *user = [User sharedUser];
    
    if (!([[[offex.request URL] absoluteString] isEqualToString:[offex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@", user.username]]] && [[offex.request HTTPMethod] isEqualToString:@"GET"])) {
        
        if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"site_read_only_enabled"]) {
            
            charAlert = [[UIAlertView alloc]
                         initWithTitle:[NSString stringWithFormat:@"Error Communicating With %@, please retry", [NSString partnerDisplayName]]
                         message:[error localizedDescription]
                         delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
            
        }
        else {
            
            charAlert = [[UIAlertView alloc]
                         initWithTitle:[NSString stringWithFormat:@"%@ Connection Error", [NSString partnerDisplayName]]
                         message:[NSString stringWithFormat:@"An error has occured sending to %@. Please retry.", [NSString partnerDisplayName]]
                         delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
            
        }
        
        [charAlert show];
    }
}

- (void)imageLoader:(ImageLoader *)loader didLoadImage:(UIImage *)image forURI:(NSString *)uri {
	loader.delegate = nil;
    self.profilePhoto = image;
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegate and UITableViewDataSourceMethods;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    switch (indexPath.row) {
        case 0:
            return 97.0;
        case 1:
            return 67.0;
        case 2:
            return 97.0;
        case 3:
            return 97.0;
        case 4:
            return 97.0;
        case 5:
            return 97.0;
        case 6:
            return 147.0;
        case 7:
            return 97.0;
        case 8:
            return 117.0;
        default:  
            return 97.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SettingsCell";
    
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[SettingsTableViewCell alloc] initWithSettingStyle:SettingsTableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [[cell.contentView viewWithTag:PROFILE_PHOTO_TAG] removeFromSuperview];
    [[cell.contentView viewWithTag:CLEAR_TEMPORARY_TAG] removeFromSuperview];
    cell.actionButton.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    User *user = [User sharedUser];
    
    switch (indexPath.row) {
        case 0:
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            cell.titleLabel.text = @"User Account";
            cell.textLabel.text = user.username;
            
            [cell.actionButton setTitle:@"Log Out" forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        case 1:
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            cell.titleLabel.text = @"Your Web Address";
            cell.textLabelBackgroundView.hidden = YES;
            
            [cell.actionButton setTitle:[[NSString stringWithFormat:@"%@/", [NSString partnerWebsite]] stringByAppendingString:user.username] forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(viewWebsite) forControlEvents:UIControlEventTouchUpInside];
            [cell.actionButton setBackgroundImage:nil forState:UIControlStateNormal];
            cell.actionButton.frame = CGRectMake(cell.contentView.bounds.origin.x + 15, cell.contentView.bounds.origin.y + 50, cell.contentView.bounds.size.width - 30, 20);
            cell.actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            [cell.actionButton setTitleColor:[UIColor settingsWebsiteButtonColor] forState:UIControlStateNormal];
            cell.actionButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
            
            break;
        case 2:
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            cell.titleLabel.text = @"Full Name";
            cell.textLabel.text = user.fullName;
            
            [cell.actionButton setTitle:@"Change" forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(editField:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 3:
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            cell.titleLabel.text = @"Site Title";
            cell.textLabel.text = user.siteTitle;
            
            [cell.actionButton setTitle:@"Change" forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(editField:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 4:
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            cell.titleLabel.text = @"Email Address";
            cell.textLabel.text = user.emailAddress;
            
            [cell.actionButton setTitle:@"Change" forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(editField:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 5:
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            cell.titleLabel.text = @"Introduction Text";
            cell.textLabel.text = user.introductionText;
            
            [cell.actionButton setTitle:@"Change" forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(editField:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 6: {
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            cell.titleLabel.text = @"Profile Photo";
            cell.textLabelBackgroundView.hidden = NO;
            cell.textLabelBackgroundView.frame = CGRectMake(cell.textLabelBackgroundView.frame.size.width / 2 - 50, cell.textLabelBackgroundView.frame.origin.y, 130, 100);
            cell.textLabel.hidden = YES;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.textLabelBackgroundView.bounds.origin.x + 10, cell.textLabelBackgroundView.bounds.origin.y + 10, cell.textLabelBackgroundView.bounds.size.width - 20, cell.textLabelBackgroundView.bounds.size.height-20)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            if (self.profilePhotoChanged) {
                imageView.image = self.profilePhotoChanged;
            }
            else {
                imageView.image = self.profilePhoto;
            }
            imageView.tag = PROFILE_PHOTO_TAG;
            [cell.textLabelBackgroundView addSubview:imageView];
            
            [cell.actionButton setTitle:@"Change" forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(changePhoto:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case 7: {
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            cell.titleLabel.text = @"Default Currency";
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            cell.textLabel.text = [prefs objectForKey:@"currency"][@"name"];
            
            [cell.actionButton setTitle:@"Change" forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(changeCurrency) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case 8: {
            [cell switchSettingStyle:SettingsTableViewCellStyleThin];
            
            UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y + cell.titleLabel.frame.size.height - 10, 200, 20)];
            aLabel.tag = CLEAR_TEMPORARY_TAG;
            aLabel.text = @"Clear Temporary Files";
            aLabel.textColor = [UIColor settingsClearTemporaryLabelColor];
            aLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:aLabel];
            
            cell.titleLabel.text = @"Advanced Options";
            cell.textLabelBackgroundView.hidden = YES;
            cell.textLabel.hidden = YES;
            
            cell.detailTextLabel.text = @"Refreshes your photos - use if your photos do not display correctly";
            cell.detailTextLabel.hidden = NO;
            cell.detailTextLabel.frame = CGRectMake(aLabel.frame.origin.x, aLabel.frame.origin.y + aLabel.frame.size.height, aLabel.frame.size.width, 40);
            
            [cell.actionButton setTitle:@"Clear" forState:UIControlStateNormal];
            [cell.actionButton addTarget:self action:@selector(clearImages) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        default:
            cell.titleLabel.text = @"";
            [cell switchSettingStyle:SettingsTableViewCellStyleDefault];
            
            break;
    }
    return cell;
}

#pragma mark IBActions
- (IBAction)exitSettings {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logout {
	[self.parentViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	LoginViewController *logout = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	logout.delegate = root;
    self.imageLoader.delegate = nil;
	[self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentViewController:logout animated:YES completion:nil];
}

- (void)viewWebsite {
	User *user = [User sharedUser]; 
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", [NSString partnerWebsite], user.username]];
	[[UIApplication sharedApplication] openURL:url];
}

- (IBAction)clearImages {
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	NSString *saveFolder = [NSString stringWithFormat:@"~/Library/Application Support/Offexploring/Temp_Save"]; 
	saveFolder = [saveFolder stringByExpandingTildeInPath];
	if ([fileManager fileExistsAtPath: saveFolder] == NO) { 
		[fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:YES attributes:nil error:nil];
	} 
	
	NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/Offexploring/Blog_Draft"]; 
	folder = [folder stringByExpandingTildeInPath];
	
	NSArray *paths = [fileManager contentsOfDirectoryAtPath:folder error:nil];
	
	for (NSString *path in paths) {
		NSArray *subFolder = [fileManager contentsOfDirectoryAtPath:[folder stringByAppendingPathComponent:path] error:nil];
		
		for (NSString *subPath in subFolder) {
			Blog *newBlog = [NSKeyedUnarchiver unarchiveObjectWithFile:[folder stringByAppendingPathComponent:[path stringByAppendingPathComponent:subPath]]];
			
			NSString *imagePath = [newBlog getImageFilePath];
			
			if ([fileManager fileExistsAtPath:imagePath]) {
				NSString *tempImageNewPath = [NSString stringWithFormat:@"Blog_%d.jpg",newBlog.original_timestamp];
				[fileManager moveItemAtPath:imagePath toPath:[saveFolder stringByAppendingPathComponent:tempImageNewPath] error:nil];
			}
			
			imagePath = [newBlog getThumbImageFilePath];
			if ([fileManager fileExistsAtPath:imagePath]) {
				NSString *tempImageNewPath = [NSString stringWithFormat:@"Blog_Thumb_%d.png",newBlog.original_timestamp];
				[fileManager moveItemAtPath:imagePath toPath:[saveFolder stringByAppendingPathComponent:tempImageNewPath] error:nil];
			}
		}
	}
	
	NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSError *error = nil;
	for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
		[fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
	}
	
	NSArray *savedImages = [fileManager contentsOfDirectoryAtPath:saveFolder error:nil];
	
	for (NSString *path in savedImages) {
		[fileManager moveItemAtPath:[saveFolder stringByAppendingPathComponent:path] toPath:[directory stringByAppendingPathComponent:path] error:nil];
	}
    
    self.imageLoader.delegate = nil;
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeCurrency {
	[[GANTracker sharedTracker] trackPageview:@"/home/settings/currency/" withError:nil];
	CurrencyPreferenceViewController *cpvc = [[CurrencyPreferenceViewController alloc] initWithNibName:nil bundle:nil];
	cpvc.delegate = self;
	[self presentViewController:cpvc animated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    
    User *user = [User sharedUser];
    NSDictionary *dict = @{@"fullName": user.fullName, @"nickName": user.siteTitle, @"email": user.emailAddress, @"introductionText": user.introductionText};
    
    OffexConnex *connex = [[OffexConnex alloc] init];
    connex.delegate = self;
    NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@",user.username]];
    
    if (self.profilePhotoChanged) {
        NSString *boundary = @"---------------------------14737809831466499882746641449"; 
        NSString *contentMode = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]; 
        
        int timestamp = [[NSDate date] timeIntervalSince1970];
        NSString *filename = [NSString stringWithFormat:@"%d-iphone-photo.jpg", timestamp];
        NSData *bodyText = [connex parameterBodyForImage:self.profilePhotoChanged andBoundary:boundary andFilename:filename andDictionary:dict];
        
        [connex postOffexploringData:bodyText withContentMode:contentMode toURL:url];
    }
    else {
        NSData *bodyText = [connex paramaterBodyForDictionary:dict];
        NSString *contentMode = @"application/x-www-form-urlencoded";
        [connex postOffexploringData:bodyText withContentMode:contentMode toURL:url];
    }
}

- (void)changePhoto:(id)sender {
    UIActionSheet *actions;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actions = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"Take Photo", @"Camera Roll", nil];
        
    }
    else {
        actions = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"Camera Roll", nil];
    }
    
    [actions showInView:self.view];
    
}

#pragma mark UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (pickerView == nil) {
            pickerView = [[UIImagePickerController alloc] init];
            pickerView.delegate = self;
        }
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerView animated:YES completion:nil];
    }
    else if ((buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) || (buttonIndex == 0 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])) {
        if (pickerView == nil) {
            pickerView = [[UIImagePickerController alloc] init];
            pickerView.delegate = self;
        }
        pickerView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerView.navigationBar.barStyle = UIBarStyleBlack;
        pickerView.navigationBar.translucent = true;
        [self presentViewController:pickerView animated:YES completion:nil];
    }
}

#pragma mark CurrencyPreferenceViewController Delegate Methods
- (void) currencyPreferenceViewController:(CurrencyPreferenceViewController *)cpvc didSetCurrency:(NSString *)currency {
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
    cell.textLabel.text = currency;
    
    
    // TODO: Fix this.
    //self.root.forceHostelsRedownload = YES;
	[[GANTracker sharedTracker] trackPageview:@"/home/settings/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) currencyPreferenceViewControllerDidCancel:(CurrencyPreferenceViewController *)cpvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/settings/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editField:(id)sender {
    UIButton *button = (UIButton *)sender;
    self.editingTag = button.tag;
    
    User *user = [User sharedUser];
    
    if (self.editingTag == 2 || self.editingTag == 3 || self.editingTag == 4) {
        
        LocationTextViewController *ltvc = [[LocationTextViewController alloc]initWithNibName:nil bundle:nil];
        ltvc.delegate = self;
        
        switch (self.editingTag) {
            case 2:
                ltvc.title = @"Full Name";
                ltvc.area = @{@"name": user.fullName};
                break;
            case 3:
                ltvc.title = @"Site Title";
                ltvc.area = @{@"name": user.siteTitle};
                break;
            case 4:
                ltvc.title = @"Email Addresss";
                ltvc.area = @{@"name": user.emailAddress};
                break;
            default:
                return;
                break;
        }
        
        [self presentViewController:ltvc animated:YES completion:nil];
    }
    else if (self.editingTag == 5) {
        
        BodyTextViewController *btvc = [[BodyTextViewController alloc]initWithNibName:nil bundle:nil];
        btvc.delegate = self;
        btvc.body = user.introductionText;
        [self presentViewController:btvc animated:YES completion:nil];

    }
}

#pragma mark LocationTextViewController Delegate Methods
- (void)locationTextViewController:(LocationTextViewController *)ltvc withTitle:(NSString *)title didFinishEditingLocation:(NSDictionary *)location {
    
    User *user = [User sharedUser];
    
    switch (self.editingTag) {
        case 2:
            user.fullName = location[@"name"];
            break;
        case 3:
            user.siteTitle = location[@"name"];
            break;
        case 4:
            user.emailAddress = location[@"name"];
            break;
        default:
            return;
            break;
    }
    
    self.userDataChanged = YES;
	
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationTextViewControllerDidCancel:(LocationTextViewController *)ltvc {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)labelForLocationTextViewController:(LocationTextViewController *)ltvc {
	switch (self.editingTag) {
        case 2:
            return @"Full Name";
            break;
        case 3:
            return @"Site Title";
            break;
        case 4:
            return @"Email Addresss";
            break;
        default: 
            return @"";
            break;
    }
}

#pragma mark BodyTextViewController Delegate Methods
- (void)bodyTextViewController:(BodyTextViewController *)btvc didFinishEditingBody:(NSString *)bodyText {
	
	User *user = [User sharedUser];
    user.introductionText = bodyText;
	
    self.userDataChanged = YES;
    
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)bodyTextViewControllerDidCancel:(BodyTextViewController *)btvc {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)titleForBodyTextViewController:(BodyTextViewController *)btvc {
	return @"Introduction Text";
}

- (BOOL)bodyTextViewControllerShouldClearOnEdit:(BodyTextViewController *)btvc {
	return NO;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *thePhoto = info[UIImagePickerControllerOriginalImage];
    
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Saving...";
	HUD.detailsLabelText = @"Please do not close the application!";
	[HUD show:YES];
    
    NSOperationQueue *saveImageQueue = [[NSOperationQueue alloc] init];
    [saveImageQueue setMaxConcurrentOperationCount:1];
	self.saveImageQueue = saveImageQueue;
    
	[self saveImage:thePhoto];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image {
	NSInvocationOperation *saveImage = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadTheNeedle:) object:image];
	[self.saveImageQueue cancelAllOperations];
	[self.saveImageQueue addOperation:saveImage];
}

- (void)threadTheNeedle:(UIImage *)image {
	
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	UIImage *saveImage = [self imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(200, 200)];
	[self performSelectorOnMainThread:@selector(imageDidSave:) withObject:saveImage waitUntilDone:NO];
}

- (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{  
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
		
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }     
	
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
	
    CGContextRef bitmap;
	
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
    }   
	
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
		
		CGContextRotateCTM (bitmap, (90 * (3.1415927/180.0)));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
		
        CGContextRotateCTM (bitmap, (-90 * (3.1415927/180.0)));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, (-180 * (3.1415927/180.0)));
    }
	
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
	
    CGContextRelease(bitmap);
    CGImageRelease(ref);
	
    return newImage; 
}

- (void)imageDidSave:(UIImage *)newImage {
    self.profilePhotoChanged = newImage;
    self.saveImageQueue = nil;
    [HUD hide:NO];
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MBProgressHUD Delegate Methods
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}


@end
