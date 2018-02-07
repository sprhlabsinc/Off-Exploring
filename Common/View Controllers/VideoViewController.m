//
//  VideoViewController.m
//  Off Exploring
//
//  Created by Ian Outterside on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"
#import "BlogDetailTableViewCell.h"
#import "User.h"
#import "GANTracker.h"
#import "Constants.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonHMAC.h>

#pragma mark -
#pragma mark VideoViewController Private Interface
/**
 @brief Private methods used to access temporary stores for changes to an Video.
 
 This interface provides private accessors used to temporary stores for changes to an Video. Upon
 donePressed: firing, this changes are updated to the live Video object and then a remote request
 to Off Exploring updates the live site with the changes
 */
@interface VideoViewController()

@property (nonatomic, strong) NSString *changeTitle;
@property (nonatomic, strong) NSString *changeDescription;
@property (nonatomic, strong) NSString *changeState;
@property (nonatomic, strong) NSString *changeArea;
@property (nonatomic, strong) NSDictionary *changeGeolocation;
@property (nonatomic, assign) BOOL postingVideo;
@property (nonatomic, strong) UIProgressView *videoUploadProgressView;

- (void)completeUpload:(NSString *)awsResponse;
- (void)sendVideo:(Video *)video;

@end

#pragma mark -
#pragma mark VideoViewController Implementation
@implementation VideoViewController

@synthesize done;
@synthesize cancel;
@synthesize tableView;
@synthesize deleteVideo;
@synthesize activeVideo;
@synthesize navBar;
@synthesize delegate;
@synthesize changeTitle;
@synthesize changeDescription;
@synthesize changeState;
@synthesize changeArea;
@synthesize changeGeolocation;
@synthesize postingVideo;
@synthesize videoUploadProgressView;

#pragma mark UIViewController Methods

- (void)dealloc {
	connex.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	tableView.backgroundColor = [UIColor clearColor];
    
    // Required for uploading video.
    [[UIApplication sharedApplication] setStatusBarStyle:DEFAULT_UI_BAR_STYLE];
    
    if ([UIColor tableViewSeperatorColor]) {
        self.tableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
	
	if (!self.changeState) {
		self.changeState = self.activeVideo.state;
	}
	if (!self.changeArea) {
		self.changeArea = self.activeVideo.area;
	}
	if (!self.changeGeolocation) {
		self.changeGeolocation = self.activeVideo.geolocation;
	}
	if (!self.changeTitle) {
		self.changeTitle = self.activeVideo.title;
	}
    if (!self.changeDescription) {
		self.changeDescription = self.activeVideo.video_description;
	}
	
	if ([delegate respondsToSelector:@selector(titleForVideoViewController:editingVideo:)]) {
		self.navBar.topItem.title = [delegate titleForVideoViewController:self editingVideo:self.activeVideo];
	}
	
	if ([delegate respondsToSelector:@selector(deleteButtonShouldDisplayForVideoViewController:editingVideo:)]) {
		BOOL enabled = [delegate deleteButtonShouldDisplayForVideoViewController:self editingVideo:self.activeVideo];
		
		if (enabled) {
			self.deleteVideo.hidden = NO;
		}
		else {
			self.deleteVideo.hidden = YES;
		}
	}
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.view setNeedsLayout];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.navBar = nil;
	self.done = nil;
	self.cancel = nil;
	self.tableView = nil;
	self.deleteVideo = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark IBActions

- (IBAction)donePressed {
    
    if ([self.changeTitle isEqualToString:@""] || self.changeTitle == nil) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"Video title must be set!"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
        return;
	}
    
    if (activeVideo.videoID == nil && self.postingVideo == NO) {
        self.postingVideo = YES;
        [self sendVideo:self.activeVideo];
        return;
    }
    else {
        [self completeUpload:nil];
    }
}

- (void)completeUpload:(NSString *)awsResponse {
	
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
        HUD.delegate = self;
        [HUD show:YES];
    }
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Saving...";
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.changeTitle, @"title", nil]; 
    
    if (self.changeState != nil) {
        dict[@"state"] = self.changeState;
    }
    
    if (self.changeArea != nil) {
        dict[@"area"] = self.changeArea; 
    }
    
    if (self.changeDescription != nil) {
        dict[@"description"] = self.changeDescription;
    }
    
    if (self.changeGeolocation != nil) {
        NSString *latitude = [NSString stringWithFormat:@"%f",[(self.changeGeolocation)[@"latitude"] doubleValue]];
        NSString *longitude = [NSString stringWithFormat:@"%f",[(self.changeGeolocation)[@"longitude"] doubleValue]];
        
        dict[@"latitude"] = latitude;
        dict[@"longitude"] = longitude;
    }
    
    if (awsResponse != nil) {
        dict[@"response"] = awsResponse;
    }
    
    User *user = [User sharedUser];
    NSString *url = nil;
    connex = [[OffexConnex alloc] init];
    connex.delegate = self;
    if (activeVideo.videoID != nil) {
        dict[@"id"] = activeVideo.videoID;
        url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/video/%@", user.username, (activeVideo.trip)[@"urlSlug"], activeVideo.videoID]];
    }
    else {
        
        url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/video", user.username, (activeVideo.trip)[@"urlSlug"]]];
    }
    NSData *dataString = [connex paramaterBodyForDictionary:dict];
    [connex postOffexploringData:dataString withContentMode:@"application/x-www-form-urlencoded" toURL:url];
}

- (IBAction)cancelPressed {
	[delegate videoViewControllerDidCancel:self];
}

- (IBAction)deleteVideoPressed {
	
	UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:nil
														 delegate:self
												cancelButtonTitle:@"Cancel"
										   destructiveButtonTitle:@"Delete"
												otherButtonTitles:nil];
	[actions showInView:self.view];
	
	
}

#pragma mark video upload
- (void)sendVideo:(Video *)video {
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(0, 0, 80, progressView.frame.size.height);
    self.videoUploadProgressView = progressView;
    
    HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Uploading...";
    HUD.detailsLabelText = @"Your video is uploading, please wait...";
    HUD.customView = self.videoUploadProgressView;    
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD show:YES];
    
    User *user = [User sharedUser];
    
    NSData *videoData = [NSData dataWithContentsOfMappedFile:video.localVideoPath];
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *filename = [NSString stringWithFormat:@"%d-iphone-video.mov", timestamp];
    
    NSString *key = [NSString stringWithFormat:@"uploads/%@[__]%@", user.username, filename];
    
    NSString *s3Folder = [NSString stringWithFormat:@"%@/%@", OFFEX_S3_FOLDER, user.username];
    
    NSTimeInterval expTime = ([[NSDate date] timeIntervalSince1970]  + (1 * 60 * 60));
    NSDate *conversationDate = [NSDate dateWithTimeIntervalSince1970:expTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"Y-M-d"];
    NSString *part1 = [dateFormatter stringFromDate:conversationDate];
    [dateFormatter setDateFormat:@"H:m:s"];
    NSString *part2 = [dateFormatter stringFromDate:conversationDate];
    
    NSString *expTimeStr = [NSString stringWithFormat:@"%@T%@Z", part1, part2];
    
    NSString *policyDoc = [NSString stringWithFormat:@"{'expiration':'%@','conditions':[{'bucket': '%@'},['starts-with', '$key', '%@'],['starts-with', '$Filename', ''],['starts-with', '$folder',''],['starts-with', '$fileext', ''],{'acl': 'public-read'},['starts-with', '$success_action_status', ''],['content-length-range', 0, '%@']]}", expTimeStr, OFFEX_S3_BUCKET, s3Folder, OFFEX_MAX_FILE_SIZE];
    
    policyDoc = [policyDoc stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    policyDoc = [policyDoc stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSData *policyDocData = [policyDoc dataUsingEncoding:NSUTF8StringEncoding];
    NSString  *policyDoc64 = [policyDocData base64EncodedString];
    
    const char *cKey  = [OFFEX_AWS_SECRET_KEY cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [policyDoc64 cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *sigPolicyDoc = [HMAC base64EncodedString];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:OFFEX_VIDEO_UPLOAD_ADDRESS]];
    
    // Upload an NSData instance
    [request setData:videoData withFileName:filename andContentType:@"video/mov" forKey:@"file"];
	[request addPostValue:OFFEX_AWS_ACCESS_KEY forKey:@"AWSAccessKeyId"];
    [request addPostValue:@"public-read" forKey:@"acl"];
    [request addPostValue:@"201" forKey:@"success_action_status"];
    [request addPostValue:key forKey:@"key"];
    [request addPostValue:policyDoc64 forKey:@"policy"];
    [request addPostValue:sigPolicyDoc forKey:@"signature"];
    [request addPostValue:@"" forKey:@"folder"];
    [request addPostValue:@"*.asf; *.avi; *.flv; *.m4v; *.mov; *.mp4; *.m4a; *.3gp; *.3g2; *.mj2; *.wmv; *.mpg; *.mpeg; *.ASF; *.AVI; *.FLV; *.M4V; *.MOV; *.MP4; *.M4A; *.3GP; *.3G2; *.MJ2; *.WMV; *.MPG; *.MPEG" forKey:@"fileext"];
    [request addPostValue:filename forKey:@"Filename"];
    [request setDelegate:self];
    [request startAsynchronous];
    [request setUploadProgressDelegate:self.videoUploadProgressView];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.postingVideo = NO;
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    [self completeUpload:responseString];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [HUD hide:YES];
    self.postingVideo = NO;
    NSError *error = [request error];
    
    NSLog(@"%@", error);
    
    UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:[NSString stringWithFormat:@"Error Sending to %@", [NSString partnerDisplayName]]
							  message:@"There was a problem uploading your video, please try again. We recommend connecting to WiFi to upload video."
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
}

#pragma mark OffexploringConnection Delegate Methods

- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	connex = nil;
	[HUD hide:YES];
	if ([results[@"request"][@"method"] isEqualToString:@"DELETE"]) {
		[delegate videoViewController:self didDeleteVideo:self.activeVideo];
	}
	else {
		Video *video = [[Video alloc] initFromDictionary:results[@"response"]];
		video.trip = activeVideo.trip;
		[delegate videoViewController:self didEditVideo:video];
	}
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	connex = nil;
	[HUD hide:YES];
	NSString *errorMessage = nil;
	NSString *errorTitle = nil;
	if ([[error userInfo][NSLocalizedDescriptionKey] isEqualToString:@"No Connection Error"]) {
		errorTitle = [NSString stringWithFormat:@"Error Sending to %@", [NSString partnerDisplayName]];
		errorMessage = [NSString stringWithFormat:@"We were unable to connect to %@. Please check your internet connection and retry.", [NSString partnerDisplayName]];
	}
	else {
		errorTitle = [NSString stringWithFormat:@"Error Communicating With %@, please retry", [NSString partnerDisplayName]];
		errorMessage = [error userInfo][NSLocalizedDescriptionKey];
	}
	
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:errorTitle
							  message:errorMessage
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
}

#pragma mark UITableView Delegate and UITableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
	if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogDetailTableViewCell" owner:nil options:nil];
		for (id currentObject in nibObjects) {
			if ([currentObject isKindOfClass:[BlogDetailTableViewCell class]]) {
				cell = (BlogDetailTableViewCell *)currentObject;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
	}
	
	if (indexPath.row == 0) {
		cell.label.text = @"Title";
		cell.detail.text = changeTitle;
	}
	else if(indexPath.row == 1) {
		cell.label.text = @"Location";
		
		if (changeArea != nil) {
			cell.detail.text = [NSString stringWithFormat:@"%@, %@",changeArea, changeState];
		}
		else if (changeState != nil) {
			cell.detail.text = changeState;
		}
		else {
			cell.detail.text = @"";
		}
	}
    else if (indexPath.row == 2) {
        cell.label.text = @"Description";
		cell.detail.text = changeDescription;
    }
	
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == 0) {
		[[GANTracker sharedTracker] trackPageview:@"/home/videos/video/edit/title/" withError:nil];
		LocationTextViewController *ltvc = [[LocationTextViewController alloc]initWithNibName:nil bundle:nil];
		ltvc.delegate = self;
        if (!self.changeTitle) {
            self.changeTitle = @"";
        }
		ltvc.area = @{@"name": self.changeTitle};
		ltvc.title = @"Video Title";
		[self presentViewController:ltvc animated:YES completion:nil];
	}
	else if (indexPath.row == 1) {
		[[GANTracker sharedTracker] trackPageview:@"/home/videos/video/edit/location/" withError:nil];
		LocationViewController *lvc = [[LocationViewController alloc]initWithNibName:nil bundle:nil];
		if (changeState != nil) {
            NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:changeState, @"name", nil];
			lvc.state = stateDictionary;
		}
		if (changeArea != nil) {
            NSDictionary *areaDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:changeArea, @"name", nil];
			lvc.area = areaDictionary;
		}
		lvc.geolocation = activeVideo.geolocation;
		lvc.delegate = self;
		[self presentViewController:lvc animated:YES completion:nil];
	}
    else if (indexPath.row == 2) {
        [[GANTracker sharedTracker] trackPageview:@"/home/videos/video/edit/description/" withError:nil];
		BodyTextViewController *ltvc = [[BodyTextViewController alloc]initWithNibName:nil bundle:nil];
		ltvc.delegate = self;
		ltvc.body = self.changeDescription;
		ltvc.title = @"Video Description";
		[self presentViewController:ltvc animated:YES completion:nil];
    }
}

#pragma mark LocationTextViewController Delegate Methods

- (NSString *)labelForLocationTextViewController:(LocationTextViewController *)ltvc {
	return @"Video Title";
}

- (void)locationTextViewController:(LocationTextViewController *)ltvc withTitle:(NSString *)title didFinishEditingLocation:(NSDictionary *)location {
	[[GANTracker sharedTracker] trackPageview:@"/home/videos/video/edit/" withError:nil];
	self.changeTitle = location[@"name"];
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationTextViewControllerDidCancel:(LocationTextViewController *)ltvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LocationViewController Delegate Methods

- (void)locationViewController:(LocationViewController *)dvc 
            didFinishWithState:(NSDictionary *)state 
                      withArea:(NSDictionary *)area
               withGeolocation:(NSDictionary *)geolocation {
    
	if (![state[@"name"] isEqualToString:@""]) {
		self.changeState = state[@"name"];
	}
	if (![area[@"name"] isEqualToString:@""]) {
		self.changeArea = area[@"name"];
	}
    
	self.changeGeolocation = geolocation;
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/videos/video/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)locationViewControllerMustHaveCompleteLocationDetails:(LocationViewController *)lvc {
	return YES;
}

#pragma mark BodyTextViewController Delegate Methods

- (void)bodyTextViewController:(BodyTextViewController *)btvc didFinishEditingBody:(NSString *)bodyText {
    [[GANTracker sharedTracker] trackPageview:@"/home/videos/video/edit/" withError:nil];
	self.changeDescription = bodyText;
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)bodyTextViewControllerShouldDisplayCancelWarning:(BodyTextViewController *)btvc {
	return YES;
}

- (void)bodyTextViewControllerDidCancel:(BodyTextViewController *)btvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/videos/video/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        User *user = [User sharedUser];
		connex = [[OffexConnex alloc] init];
		connex.delegate = self;
        NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/video/%@", user.username, (activeVideo.trip)[@"urlSlug"], activeVideo.videoID]];
        [connex deleteOffexploringDataAtUrl:url];
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Deleting...";
		[HUD show:YES];
	}
}

#pragma mark MBProgressHUD Delegate Method

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

@end
