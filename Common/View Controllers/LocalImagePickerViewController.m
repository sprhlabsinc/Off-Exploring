//
//  LocalImagePickerViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "LocalImagePickerViewController.h"
#import "PhotoViewController.h"
#import "User.h"
#import "Photo.h"
#import "UIImage+Resize.h"
#import "GANTracker.h"
#import "JRActivityObject.h"

#pragma mark -
#pragma mark LocalImagePickerViewController Private Interface
/**
	@brief Private methods used to download photos from Off Exploring, handle photo display and handle photo upload.
 
	This interface provides private methods for a variety of tasks. It handles photo downloads from Off Exploring, and
	displaying those photos on the UIScrollView. It allows for image capture from either the iPhone camera or the iPhone
	image library, and for those images to be captioned, appropriatly transformed and uploaded to Off Exploring. Finally,
	it allows for images to be deleted.
 */
@interface LocalImagePickerViewController()
#pragma mark Private Method Declarations
/**
	Loads the list of photos inside the activeAlbum from Off Exploring
 */
- (void)beginLoadingPhotos;
/**
	Redraws the UIScrollView with Buttons containing the thumbnails of the photos in the album
 */
- (void)reloadData;
/**
	Spawns a concurrent thread to rotate and save the image.  
	@param image The image to transform
 */
- (void)saveImage:(UIImage *)image;
/**
	Switch back to the main thread to handle File upload
	@param image The transformed image
 */
- (void)imageDidSave:(UIImage *)image;

/**
	POSTS photo details and an Image to Off Exploring
	@param photo The Photo details to post
	@param image The Image to upload
 */
- (void)postPhoto:(Photo *)photo andImage:(UIImage *)image;
/**
	DELETES a photo from the Off Exploring database
	@param photo The photo to delete
 */
- (void)deletePhoto:(Photo *)photo;
/**
	Displays the social sharing dialogue 
 */
- (void)showSocialShare:(Photo *)newPhoto; 

											

@property (nonatomic, strong) NSOperationQueue *saveImageQueue;
@property (nonatomic, strong) Photo *photoToDelete;
@property (nonatomic, strong) Photo *photoToEdit;
@property (nonatomic, assign) BOOL updatingPhoto;
@property (nonatomic, assign) BOOL addingPhoto;
@property (nonatomic, assign) BOOL saveToLibrary;

@end

#pragma mark -
#pragma mark LocalImagePickerViewController Implementation

@implementation LocalImagePickerViewController

@synthesize activeAlbum;
@synthesize scrollView;
@synthesize addPhoto;
@synthesize saveImageQueue;
@synthesize photoToDelete;
@synthesize photoToEdit;
@synthesize updatingPhoto;
@synthesize pickerView;
@synthesize saveToLibrary;
@synthesize addingPhoto;

#pragma mark UIViewController Methods

- (void)dealloc {
    [JREngage removeDelegate:self];
	NSMutableArray *delegates = activeDownloads[@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
	activeAlbum.photos = nil;
	connex.delegate = nil;
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		activeDownloads = [[NSMutableDictionary alloc] init];
		NSMutableArray *delegates = [[NSMutableArray alloc] init];
		activeDownloads[@"delegates"] = delegates;
		saveImageQueue = [[NSOperationQueue alloc] init];
		[saveImageQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	self.navigationItem.rightBarButtonItem = addPhoto;
	
	if (activeAlbum.photoCount > 0) {
		[self reloadData];
	}
	else {
		scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclamation.png"]];
		imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
		[scrollView addSubview:imageView];
		UILabel *noPhotosLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 250, 20)];
		noPhotosLabel.text = @"No Photos Yet!";
		[noPhotosLabel setFont:[UIFont boldSystemFontOfSize:16]];
		[scrollView addSubview:noPhotosLabel];
		UILabel *noPhotosSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 250, 20)];
		noPhotosSubLabel.text = @"You dont have photos in this album.";
		[noPhotosSubLabel setFont:[UIFont systemFontOfSize:14]];
		[noPhotosSubLabel setTextColor:[UIColor grayColor]];
		[scrollView addSubview:noPhotosSubLabel];
		[self.view addSubview:scrollView];
	}
		
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
	self.addPhoto = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark IBActions
- (void)buttonClicked:(id)selector {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/" withError:nil];
	UIButton *button = (UIButton *)selector;
	PhotoViewController *photoView = [[PhotoViewController alloc] initWithNibName:nil bundle:nil];
	photoView.photos = self.activeAlbum.photos;
	photoView.activePhoto = button.tag;
	photoView.delegate = self;
	[self.navigationController pushViewController:photoView animated:YES];
}

- (IBAction)uploadPhoto {
	
	UIActionSheet *actions;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		
		actions = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
											  delegate:self
									 cancelButtonTitle:@"Cancel"
								destructiveButtonTitle:nil
									 otherButtonTitles:@"Take Photo", @"Device Photos", nil];
		
	}
	else {
		
		actions = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
											  delegate:self
									 cancelButtonTitle:@"Cancel"
								destructiveButtonTitle:nil
									 otherButtonTitles:@"Device Photos", nil];
		
	}
	
	[actions showInView:self.view];
	
}

#pragma mark Private Methods
- (void)beginLoadingPhotos {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photosDataDidLoad:) name:@"photosDataDidLoad" object:nil];
	User *user = [User sharedUser];
	connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/album/%@/photo",user.username,(activeAlbum.trip)[@"urlSlug"], activeAlbum.slug]];
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)reloadData {
	
	for(UIView *subView in self.view.subviews) {
		if ([subView isKindOfClass:[UIScrollView class]]) {
			[subView removeFromSuperview];
		}
	}

	[self beginLoadingPhotos];
	
	scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	int row = 0;
	int column = 0;
	
	if (activeAlbum.photoCount > 0) {
	
		for(int i = 0; i < activeAlbum.photoCount; ++i) {
			
			UIImage *thumb = [UIImage imageNamed:@"placeholder.png"];
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.frame = CGRectMake(column*75+15, row*75+15, 60, 60);
			[button setBackgroundImage:thumb forState:UIControlStateNormal];
			button.contentMode = UIViewContentModeScaleToFill;
			[button addTarget:self 
					   action:@selector(buttonClicked:) 
			 forControlEvents:UIControlEventTouchUpInside];
			button.tag = i; 
			[scrollView addSubview:button];
			
			if (column == 3) {
				column = 0;
				row++;
			} else {
				column++;
			}
		}
		[scrollView setContentSize:CGSizeMake(320, (row+1) * 80 + 10)];
	}
	
	else {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclamation.png"]];
		imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
		[scrollView addSubview:imageView];
		UILabel *noPhotosLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 250, 20)];
		noPhotosLabel.text = @"No Photos Yet!";
		[noPhotosLabel setFont:[UIFont boldSystemFontOfSize:16]];
		[scrollView addSubview:noPhotosLabel];
		UILabel *noPhotosSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 250, 20)];
		noPhotosSubLabel.text = @"You dont have photos in this album.";
		[noPhotosSubLabel setFont:[UIFont systemFontOfSize:14]];
		[noPhotosSubLabel setTextColor:[UIColor grayColor]];
		[scrollView addSubview:noPhotosSubLabel];
	}
	
	[self.view addSubview:scrollView];
	
}

- (void)saveImage:(UIImage *)image {
	NSInvocationOperation *saveImage = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadTheNeedle:) object:image];
	[self.saveImageQueue cancelAllOperations];
	[self.saveImageQueue addOperation:saveImage];
}

- (void)threadTheNeedle:(UIImage *)image {
	
	if (self.saveToLibrary == YES) {
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}
	
	CGFloat width = image.size.width;
	CGFloat height = image.size.height;
    
	CGSize theSize;
    BOOL resize = NO;
	if (width > height) {
        
        if (width > 720) {
            CGFloat ratio = height / width;
            theSize = CGSizeMake(720, 720 * ratio);
            resize = YES;
        }
	}
	else {
		
        if (height > 720) {
            CGFloat ratio = width / height;
            theSize = CGSizeMake(720 * ratio, 720);
            resize = YES;
        }
	}
    
    UIImage *full = nil;
    
    if (resize) {
        full = [image resizedImage:theSize interpolationQuality:kCGInterpolationHigh];
    }
    else {
        full = image;
    }
	
	[self performSelectorOnMainThread:@selector(imageDidSave:) withObject:full waitUntilDone:NO];
}

- (void)imageDidSave:(UIImage *)image {
	if (HUD != nil) {
		[HUD hide:YES];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
	if (image != nil) {
		[self performSelector:@selector(addImageDetails:) withObject:image afterDelay:1.2];
	}
	else  {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Camera Error"
								  message:@"An error occurred saving your image. Please retry"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
}

- (void)postPhoto:(Photo *)photo andImage:(UIImage *)image {
	User *user = [User sharedUser];
    NSDictionary *dict = nil;
    if (photo.caption && photo.description) {
        dict = @{@"caption": photo.caption, @"description": photo.description};
    }
    else if (photo.description) {
        dict = @{@"description": photo.description};
    }
    else if (photo.caption) {
        dict = @{@"caption": photo.caption};
    }
    else {
        dict = @{};
    }
	 
	NSData *bodyText;
	NSString *url;
	NSString *contentMode;
	connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	if (image == nil) {
		contentMode = @"application/x-www-form-urlencoded";
		bodyText = [connex paramaterBodyForDictionary:dict];
		url = [connex buildOffexRequestStringWithURI:[[[[[[[@"user/" stringByAppendingString:user.username]
														   stringByAppendingString:@"/trip/"]
														  stringByAppendingString:(activeAlbum.trip)[@"urlSlug"]]
														 stringByAppendingString:@"/album/"]
														stringByAppendingString:activeAlbum.slug]
													   stringByAppendingString:@"/photo/"]
													  stringByAppendingString:photo.photoid]];
	}
	else {
		
		NSString *boundary = @"---------------------------14737809831466499882746641449"; 
		contentMode = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]; 
		
		int timestamp = [[NSDate date] timeIntervalSince1970];
		NSString *filename = [NSString stringWithFormat:@"%d-iphone-photo.jpg", timestamp];
		
		bodyText = [connex parameterBodyForImage:image andBoundary:boundary andFilename:filename andDictionary:dict];
		
		url = [connex buildOffexRequestStringWithURI:[[[[[[@"user/" stringByAppendingString:user.username]
														  stringByAppendingString:@"/trip/"]
														 stringByAppendingString:(activeAlbum.trip)[@"urlSlug"]]
														stringByAppendingString:@"/album/"]
													   stringByAppendingString:activeAlbum.slug]
													  stringByAppendingString:@"/photo"]];
	}
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	if (self.updatingPhoto == YES) {
		HUD.labelText = @"Updating...";
	}
	else {
		HUD.labelText = @"Uploading...";
	}
	[HUD show:YES];
	[connex postOffexploringData:bodyText withContentMode:contentMode toURL:url];
}

- (void)deletePhoto:(Photo *)photo {
	self.photoToDelete = photo;
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Deleting...";
	[HUD show:YES];
	User *user = [User sharedUser];
	connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	NSString *url = [connex buildOffexRequestStringWithURI:[[[[[[[@"user/" stringByAppendingString:user.username] 
																 stringByAppendingString:@"/trip/"] 
																stringByAppendingString:(photo.trip)[@"urlSlug"]] 
															   stringByAppendingString:@"/album/"] 
															  stringByAppendingString:(photo.album)[@"urlSlug"]]
															 stringByAppendingString:@"/photo/"] 
															stringByAppendingString:photo.photoid]];
	[connex deleteOffexploringDataAtUrl:url];
}

#pragma mark OffexploringConnection Delegate Methods

- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	connex = nil;
	if ([results[@"request"][@"method"] isEqualToString:@"DELETE"]) {
		[HUD hide:YES];
		if ([results[@"response"][@"success"] isEqualToString:@"true"]){
			[self.activeAlbum deletePhoto:self.photoToDelete];
			self.photoToDelete = nil;
			[self reloadData];
		}
	}
	else if (results[@"response"][@"success"] != nil) {
		editingCaption = nil;
		editingDescription = nil;
		
		Photo *photo = [[Photo alloc] initWithDictionary:results[@"response"][@"photo"][@"photo"]]; 
		photo.album = @{@"albumname": self.activeAlbum.name, @"urlSlug": self.activeAlbum.slug};
		photo.trip = self.activeAlbum.trip;
		[self.activeAlbum addPhoto:photo];
		[HUD hide:YES];
		if (self.updatingPhoto == YES) {
			self.updatingPhoto = NO;
		}
		else {
			self.addingPhoto = NO;
			[self reloadData];
			[self showSocialShare:photo];
		}
	}
	else {
		if (results[@"response"][@"photos"] != [NSNull null]) {
			[self.activeAlbum setPhotosDataFromArray:results[@"response"][@"photos"][@"photo"]];
		}
	}
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	connex = nil;
	[HUD hide:YES];
	
	UIAlertView *charAlert = nil;
	
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
					 message:[NSString stringWithFormat:@"An error has occured connecting to %@. Please retry.", [NSString partnerDisplayName]]
					 delegate:nil
					 cancelButtonTitle:@"OK"
					 otherButtonTitles:nil];
		
	}
	
	
	
	if (self.addingPhoto == NO && self.updatingPhoto == NO && self.photoToDelete == nil) {
		charAlert.delegate = self;
	}
	
	if (self.photoToEdit) {
		self.photoToEdit.caption = editingCaption;
		self.photoToEdit.description = editingDescription;
	}
	
	self.photoToEdit = nil;
	self.photoToDelete = nil;
	self.updatingPhoto = NO;
	self.addingPhoto = NO;
	editingCaption = nil;
	editingDescription = nil;
	
	[charAlert show];
	
}


#pragma mark Janrain Social Share functionality

- (void)showSocialShare:(Photo *)newPhoto {
    
	[JREngage setEngageAppId:TARGET_PARTNER_JANRAIN_APP_ID
                    tokenUrl:nil
                 andDelegate:self];
	
	User *user = [User sharedUser];
	
	NSString *socialAddress		= [NSString stringWithFormat:@"http://%@/%@/albums/%@/%@", [NSString partnerWebsite] ,
								   user.username,(newPhoto.album)[@"urlSlug"],newPhoto.photoid];
	NSString *photoTitle		= nil;
	
	if (newPhoto.caption == nil || [newPhoto.caption isEqualToString:@""]) {
		photoTitle = [NSString stringWithFormat:@"New photo in %@", (newPhoto.album)[@"albumname"]];
	}
	else {
		photoTitle = [NSString stringWithFormat:@"%@ in %@", newPhoto.caption, (newPhoto.album)[@"albumname"]];
	}
	
	NSString *photoImage		= [NSString stringWithFormat:@"%@%@", S3_IMAGE_ADDRESS, newPhoto.imageURI];
	
	JRImageMediaObject *image	= [[JRImageMediaObject alloc] initWithSrc:photoImage 
																andHref:socialAddress];
	
	JRActivityObject *activity = [[JRActivityObject alloc]
								   initWithAction:@"posted a new photo"
								   andUrl:socialAddress];
	
	[activity setMedia:[NSMutableArray arrayWithArray:@[image]]];
	
	[JREngage showSharingDialogWithActivity:activity];
}

#pragma mark Notification Listener

- (void)photosDataDidLoad:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"photosDataDidLoad" object:nil];

	Photo *aPhoto;
	int imageNumber = 0;
	for (aPhoto in self.activeAlbum.photos) {
		NSString *remotePath = [aPhoto getThumbImageFullRemotePath];
		if (activeDownloads[remotePath] == nil) {
			activeDownloads[remotePath] = @(imageNumber);
			ImageLoader *imageLoader = [[ImageLoader alloc] init];
			imageLoader.delegate = self;
			NSMutableArray *dels = activeDownloads[@"delegates"];
			[dels addObject:imageLoader];
			[imageLoader startDownloadForURL:remotePath];
		}
		imageNumber++;
	}	
}

#pragma mark ImageLoader Delegate Method

- (void)imageLoader:(ImageLoader *)loader didLoadImage:(UIImage *)image forURI:(NSString *)uri {
	loader.delegate = nil;
	NSMutableArray *delegates = activeDownloads[@"delegates"];
	int count = 0;
	for (ImageLoader *obj in delegates) {
		if ([loader isEqual:obj]) {
			[delegates removeObjectAtIndex:count];
			delegates = nil;
			break;
		}
		count = count +1;
	}
	
	int imageNumber = [activeDownloads[uri] intValue];
	[activeDownloads removeObjectForKey:uri];
	UIButton *aButton;
	int counter = 0;
	
	for (aButton in self.scrollView.subviews) {
		if (imageNumber == counter) {
			[aButton setBackgroundImage:image forState:UIControlStateNormal];
			return;
		}
		counter++;
	}
}

#pragma mark UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

	if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		if (pickerView == nil) {
			pickerView = [[UIImagePickerController alloc] init];
			pickerView.delegate = self;
		}
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/upload/camera/" withError:nil];
		pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentViewController:pickerView animated:YES completion:nil];
	}
	else if ((buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) || (buttonIndex == 0 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])) {
		if (pickerView == nil) {
			pickerView = [[UIImagePickerController alloc] init];
			pickerView.delegate = self;
		}
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/upload/photo_library/" withError:nil];
		pickerView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerView.navigationBar.barStyle = UIBarStyleBlack;
        
		[self presentViewController:pickerView animated:YES completion:nil];
	}
}

#pragma mark UIAlertView Delegate Method
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([alertView.title isEqualToString:[NSString stringWithFormat:@"%@ Connection Error", [NSString partnerDisplayName]]]) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark UIImagePickerController Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *thePhoto = info[UIImagePickerControllerOriginalImage];
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Saving...";
	HUD.detailsLabelText = @"Please do not close the application!";
	[HUD show:YES];
	
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		self.saveToLibrary = YES;
	}
	else {
		self.saveToLibrary = NO;
	}
	
	[self saveImage:thePhoto];
}

/**
	Called by ImageDidSave: to return to the main thread and add captions to a new photo.
 */
- (void)addImageDetails: (UIImage *)thePhoto {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/edit/" withError:nil];
	PhotoOptionsViewController *photoOptions = [[PhotoOptionsViewController alloc] initWithNibName:nil bundle:nil];
	Photo *newPhoto = [[Photo alloc] init];
	photoOptions.activePhoto = newPhoto;
	photoOptions.delegate = self;
	photoOptions.thePhoto = thePhoto;
	[self presentViewController:photoOptions animated:YES completion:nil];
}

#pragma mark PhotoOptionsViewController Delegate Methods

- (void)photoOptionsViewController:(PhotoOptionsViewController *)povc didEditPhoto:(Photo *)photo andImage:(UIImage *)image oldCaption:(NSString *)oldCaption oldDescription:(NSString *)oldDescription {
	[[UIApplication sharedApplication] setStatusBarStyle:DEFAULT_UI_BAR_STYLE];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	self.navigationController.navigationBarHidden = NO;
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
	self.addingPhoto = YES;
	[self postPhoto:photo andImage:image];
}

- (void)photoOptionsViewControllerDidCancel:(PhotoOptionsViewController *)povc {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoOptionsViewController:(PhotoOptionsViewController *)povc didRequestDeleteOfPhoto:(Photo *)photo {
}

#pragma mark PhotoViewController Delegate Methods

- (void)photoViewController:(PhotoViewController *)povc didRequestDeleteOfPhoto:(Photo *)photo {
	[[UIApplication sharedApplication] setStatusBarStyle:DEFAULT_UI_BAR_STYLE];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	self.navigationController.navigationBarHidden = NO;
	[self dismissViewControllerAnimated:YES completion:nil];
	[self.navigationController popViewControllerAnimated:NO];
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/" withError:nil];
	[self deletePhoto:photo];
}

- (void)photoViewController:(PhotoViewController *)povc didRequestUpdateOfPhoto:(Photo *)photo oldCaption:(NSString *)oldCaption oldDescription:(NSString *)oldDescription{
	editingCaption = oldCaption;
	editingDescription = oldDescription;
	self.photoToEdit = photo;
	[[UIApplication sharedApplication] setStatusBarStyle:DEFAULT_UI_BAR_STYLE];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	self.navigationController.navigationBarHidden = NO;
	[self dismissViewControllerAnimated:YES completion:nil];
	[self.navigationController popViewControllerAnimated:NO];
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/" withError:nil];
	self.updatingPhoto = YES;
	[self postPhoto:photo andImage:nil];
}

#pragma mark MBProgressHUD Delegate Methods
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}

@end
