//
//  VideosViewController.m
//  Off Exploring
//
//  Created by Ian Outterside on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideosViewController.h"
#import "BlogLocationTableViewCell.h"
#import "GANTracker.h"
#import "Constants.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface VideosViewController()

- (void)loadImagesForOnscreenRows;
- (void)updateProcessingVideo:(Video *)video;
- (void)handleProcessingVideoWithId:(NSString *)videoId;
- (void)checkVideoProcessingHasUpdated:(NSDictionary *)videoDictionary;
- (void)startProcessingTimer;
- (void)handleFailedProcessingVideoWithId:(NSString *)videoId;

@property (nonatomic, strong) NSTimer *processingTimerTracker;
@property (nonatomic, strong) NSMutableDictionary *videoUploadInfo;
@property (nonatomic, assign) BOOL resumeTimer;

@end

@implementation VideosViewController

@synthesize tableView = _tableView;
@synthesize activeTrip = _activeTrip;
@synthesize downloadedData;
@synthesize pickerView;
@synthesize processingTimerTracker;
@synthesize videoUploadInfo;
@synthesize resumeTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Videos";
        self.downloadedData = NO;
        activeDownloads = [[NSMutableDictionary alloc] init];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    NSArray *sources = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    NSArray *videoMediaTypesOnly = [sources filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", (NSString *)kUTTypeMovie]];
    BOOL movieOutputPossible = ([videoMediaTypesOnly count] > 0);
    
    if (movieOutputPossible) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
        
        self.navigationItem.rightBarButtonItem = item;
    }
    
    [super viewDidLoad];
    if (!self.downloadedData) {
        [self downloadVideos];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseTimer:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTimer:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[activeDownloads removeAllObjects];
	NSMutableArray *delegates = [[NSMutableArray alloc] init];
	activeDownloads[@"delegates"] = delegates;
	[self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma Button Pressed

- (void)addButtonPressed:(id)sender {
    
    UIActionSheet *actions = nil;
	
    BOOL video = NO;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        NSArray *sources = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
		NSArray *videoMediaTypesOnly = [sources filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", (NSString *)kUTTypeMovie]];
        BOOL movieOutputPossible = ([videoMediaTypesOnly count] > 0);
        
        if (movieOutputPossible) {
            video = YES;
            
            actions = [[UIActionSheet alloc] initWithTitle:@"Select Video Source"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Take Video", @"Device Videos", nil];
        }
    }
	
    if (!video){
		
		actions = [[UIActionSheet alloc] initWithTitle:@"Select Video Source"
											  delegate:self
									 cancelButtonTitle:@"Cancel"
								destructiveButtonTitle:nil
									 otherButtonTitles:@"Device Videos", nil];
		
	}
	
	[actions showInView:self.view];
	
    
}

#pragma mark UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet.title isEqualToString:@"Select Video Source"]) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.videoUploadInfo = dict;
        
        BOOL video = NO;
        NSArray *videoMediaTypesOnly = nil;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            NSArray *sources = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            videoMediaTypesOnly = [sources filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", (NSString *)kUTTypeMovie]];
            BOOL movieOutputPossible = ([videoMediaTypesOnly count] > 0);
            
            if (movieOutputPossible) {
                video = YES;
            }
            
            videoUploadInfo[@"videoMediaTypesOnly"] = videoMediaTypesOnly;
        }
        
        if (buttonIndex == 0 && video == YES) {
            videoUploadInfo[@"Camera"] = @YES;
            videoUploadInfo[@"Library"] = @NO;
        }
        else if ((buttonIndex == 1 && video == YES) || (buttonIndex == 0 && video == NO)) {
        
            NSArray *sources = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            videoMediaTypesOnly = [sources filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", (NSString *)kUTTypeMovie]];
            
            videoUploadInfo[@"videoMediaTypesOnly"] = videoMediaTypesOnly;
            videoUploadInfo[@"Camera"] = @NO;
            videoUploadInfo[@"Library"] = @YES;
        }
        else {
            // User cancelled
            
            self.videoUploadInfo = nil;
            return; 
        }
        
        
        UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:@"Select Video Quality"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"High (WiFi)", @"Medium (WiFi - Faster)", @"Low (3G)", nil];
        
        [actions showInView:self.view];
        
        
    }
    else {
        
        if (pickerView == nil) {
			pickerView = [[UIImagePickerController alloc] init];
		}
        
        pickerView.delegate = self;
        [pickerView setMediaTypes:videoUploadInfo[@"videoMediaTypesOnly"]];
        
        if (buttonIndex == 0) {
            [pickerView setVideoQuality:UIImagePickerControllerQualityTypeHigh];
        }
        else if (buttonIndex == 1) {
            [pickerView setVideoQuality:UIImagePickerControllerQualityTypeMedium];
        }
        else if (buttonIndex == 2) {
            [pickerView setVideoQuality:UIImagePickerControllerQualityTypeLow];
        }
        else {
            // User cancelled
            
            self.videoUploadInfo = nil;
            return;
        }
        
        if ([videoUploadInfo[@"Camera"] isEqualToNumber:@YES]) {
            // use camera
            
            [[GANTracker sharedTracker] trackPageview:@"/home/videos/video/upload/camera/" withError:nil];
            [pickerView setSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else {
            // use library
            
            [[GANTracker sharedTracker] trackPageview:@"/home/videos/video/upload/photo_library/" withError:nil];
            [pickerView setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        
        pickerView.navigationBar.barStyle = UIBarStyleBlack;
        pickerView.navigationBar.translucent = true;
        
        [self presentViewController:pickerView animated:YES completion:nil];
        
    }
}

#pragma mark UIImagePickerController Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    NSString *moviePath = [info[UIImagePickerControllerMediaURL] path];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, nil, nil, nil);
        }
    }
    
    VideoViewController *videoView = [[VideoViewController alloc] initWithNibName:nil bundle:nil];
	Video *newVideo = [[Video alloc] init];
	newVideo.localVideoPath = moviePath;
    newVideo.trip = @{@"name": self.activeTrip.name, @"urlSlug": self.activeTrip.urlSlug};
	videoView.activeVideo = newVideo;
	videoView.delegate = self;
	
	[picker presentViewController:videoView animated:YES completion:nil];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.videoUploadInfo = nil;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.activeTrip.videos.videos count] > 0) {
		return [self.activeTrip.videos.videos count];
	}
	else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.activeTrip.videos.videos count] > 0) {
        
		BlogLocationTableViewCell *cell = (BlogLocationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
        
		if (cell == nil) {
            
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogLocationTableViewCell" owner:nil options:nil];
            
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogLocationTableViewCell class]]) {
					cell = (BlogLocationTableViewCell *)currentObject;
                    cell.contentCount.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                    cell.title.frame = CGRectMake(cell.title.frame.origin.x, cell.title.frame.origin.y, 200, cell.title.frame.size.height);
                }
			}
		}
		
		Video *video = (self.activeTrip.videos.videos)[indexPath.row];
		
		NSString *pngPath = [video getThumbImageFilePath];
		
        if (video.processing) {
            cell.title.text = [NSString stringWithFormat:@"[Processing] %@", video.title];
        }
        else if (video.failedUpload) {
            cell.title.text = [NSString stringWithFormat:@"[Failed] %@", video.title];
        }
        else {
            cell.title.text = video.title;
        }
        cell.coverImage.image = [UIImage imageWithContentsOfFile:pngPath];
		
		return cell;
	}
	else if (self.downloadedData == YES) {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
														reuseIdentifier:nil];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		cell.imageView.image = [UIImage imageNamed:@"exclamation.png"];
		cell.textLabel.text = @"No Videos Yet!";
		cell.detailTextLabel.text = @"You do not have any videos yet.";
		
		return cell;
	}
	else {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
														reuseIdentifier:nil];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activity startAnimating];
		activity.frame = CGRectMake(19, 20, 20, 20);
		[cell.contentView addSubview:activity];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(52, 20, 100, 20)];
		label.text = @"Loading...";
		label.textColor = [UIColor colorWithRed: 64/255.0 green: 64/255.0 blue: 64/255.0 alpha:1.0];
		label.font = [UIFont boldSystemFontOfSize: 16.0];
		[cell.contentView addSubview:label];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.activeTrip.videos.videos count] > 0) {
		BlogLocationTableViewCell *theCell = (BlogLocationTableViewCell *)cell;
		
		if (theCell.coverImage.image == nil) {	
			theCell.coverImage.image = [UIImage imageNamed:@"placeholder.png"];
			Video *video = (self.activeTrip.videos.videos)[indexPath.row];
			NSString *remotePath = [video getThumbImageFullRemotePath];
			
			if (activeDownloads[remotePath] == nil && self.tableView.dragging == NO && self.tableView.decelerating == NO) {
				activeDownloads[remotePath] = indexPath;
				ImageLoader *imageLoader = [[ImageLoader alloc] init];
				imageLoader.delegate = self;
				NSMutableArray *dels = activeDownloads[@"delegates"];
				[dels addObject:imageLoader];
				[imageLoader startDownloadForURL:remotePath];
			}
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.activeTrip.videos.videos count] > 0) {
		[[GANTracker sharedTracker] trackPageview:@"/home/videos/video" withError:nil];
		Video *video = (self.activeTrip.videos.videos)[indexPath.row];
        
        if (video.processing) {
            UIAlertView *charAlert = [[UIAlertView alloc]
                                      initWithTitle:@"Video Processing"
                                      message:@"This video can not be played yet as it is still processing. Please try again later."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [charAlert show];
            

        }
        else if (video.failedUpload) {
            UIAlertView *charAlert = [[UIAlertView alloc]
                                      initWithTitle:@"Video Processing Failed"
                                      message:@"This video can not be played as we were unable to process the upload. Please retry the upload."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [charAlert show];
            
        }
        else {
            
            MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:[video videoRemotePath]];
            
            MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
            if ([[[video videoRemotePath] pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame) 
            {
                movieSourceType = MPMovieSourceTypeStreaming;
            }
            
            [playerController.moviePlayer setMovieSourceType:movieSourceType];
            [playerController.moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
            [self presentMoviePlayerViewControllerAnimated:playerController];
            
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[[GANTracker sharedTracker] trackPageview:@"/home/videos/video/edit/" withError:nil];
	VideoViewController *videoView = [[VideoViewController alloc] initWithNibName:nil bundle:nil];
	Video *video = (self.activeTrip.videos.videos)[indexPath.row];
	
	videoView.activeVideo = video;
	videoView.delegate = self;
	
	[self presentViewController:videoView animated:YES completion:nil];
	
}

#pragma mark Image Loading 

- (void)loadImagesForOnscreenRows
{
    if ([self.activeTrip.videos.videos count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
			Video *video = (self.activeTrip.videos.videos)[indexPath.row];
			NSString *pngPath = [video getThumbImageFilePath];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:pngPath] == NO) {
				
				NSString *remotePath = [video getThumbImageFullRemotePath];
				
				if (activeDownloads[remotePath] == nil) {
					activeDownloads[remotePath] = indexPath;
					ImageLoader *imageLoader = [[ImageLoader alloc] init];
					imageLoader.delegate = self;
					NSMutableArray *dels = activeDownloads[@"delegates"];
					[dels addObject:imageLoader];
					[imageLoader startDownloadForURL:remotePath];
				}
			}
        }
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
	
	NSIndexPath *indexPath = activeDownloads[uri];
	Video *video = (self.activeTrip.videos.videos)[indexPath.row];
	
	BlogLocationTableViewCell *cell = (BlogLocationTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	
	if (![uri isEqualToString:@"/journal/images/placeholder.png"]) {
		NSString *pngPath = [video getThumbImageFilePath];
		[UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
		cell.coverImage.image = [UIImage imageWithContentsOfFile:pngPath];
	}
	else {
		cell.coverImage.image = image;
	}
}

#pragma mark UIScrollView Delegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


#pragma mark OffexploringConnection Delegate Methods

/**
 Sends the album list data off to the trip object to parse and store the list of albums
 @param offex The OffexConnex object used to load the data
 @param results The results from teh query
 */
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	connex = nil;
    
    if (results[@"response"][@"video"] && results[@"response"][@"video"][0]) {
        [self checkVideoProcessingHasUpdated:results[@"response"][@"video"][0]];
    }
    else {
        [self.activeTrip setVideosDataFromArray:results[@"response"][@"videos"][@"video"]];
    }
    
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	connex = nil;
    if (self.downloadedData == NO) {
        [self.activeTrip setVideosDataFromArray:nil];
    }
}

#pragma mark Download data 
- (void)downloadVideos {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDataDidLoad:) name:@"videoDataDidLoad" object:nil];
	connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	User *user = [User sharedUser];
    
    NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/video", user.username, _activeTrip.urlSlug]];
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)videoDataDidLoad:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"videoDataDidLoad" object:nil];
    self.downloadedData = YES;
    
    for (Video *video in self.activeTrip.videos.videos) {
        if (video.processing) {
            // Start a timer to update processing
            [self startProcessingTimer];
            break;
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark Processing Video

- (void)startProcessingTimer {
    if (!self.processingTimerTracker) {
        self.processingTimerTracker = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                                       target:self
                                                                     selector:@selector(updateProcessingVideos:)
                                                                     userInfo:nil
                                                                      repeats:YES];
        self.resumeTimer = NO;
    }
}

- (void)pauseTimer:(NSNotification *)notification {
    if (self.processingTimerTracker && [self.processingTimerTracker isKindOfClass:[NSTimer class]]) {
        [self.processingTimerTracker invalidate];
        self.processingTimerTracker = nil;
        self.resumeTimer = YES;
    }
}

- (void)resumeTimer:(NSNotification *)notification {
    if (self.resumeTimer) {
        [self startProcessingTimer];
        [self.processingTimerTracker fire];
    }
}
 
- (void)updateProcessingVideos:(NSTimer *)timer {
    BOOL stillProcessing = NO;
    
    for (Video *video in self.activeTrip.videos.videos) {
        if (video.processing) {
            stillProcessing = YES;
            [self updateProcessingVideo:video];
        }
    }
    
    if (!stillProcessing) {
        [self.processingTimerTracker invalidate];
        self.processingTimerTracker = nil;
    }
}

- (void)updateProcessingVideo:(Video *)video {
    if (video.processing) {
        connex = [[OffexConnex alloc] init];
        connex.delegate = self;
        User *user = [User sharedUser];
        
        NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/video/%@", user.username, _activeTrip.urlSlug, video.videoID]];
        [connex beginLoadingOffexploringDataFromURL:url];
    }
}

- (void)checkVideoProcessingHasUpdated:(NSDictionary *)videoDictionary {
    if ([videoDictionary[@"processing"] isEqualToString:@"complete"]) {
        [self handleProcessingVideoWithId:videoDictionary[@"id"]];
    }
    else if ([videoDictionary[@"processing"] isEqualToString:@"failed"]) {
        [self handleFailedProcessingVideoWithId:videoDictionary[@"id"]];
    }
}

- (void)handleProcessingVideoWithId:(NSString *)videoId {
    // handle processing video
    
    for (Video *video in self.activeTrip.videos.videos) {
        if ([video.videoID isEqualToString:videoId]) {
            video.processing = NO;
            
            UIAlertView *charAlert = [[UIAlertView alloc]
                                      initWithTitle:@"Video Processing Complete"
                                      message:@"A video has finished processing and can now be viewed"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [charAlert show];
            
            
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)handleFailedProcessingVideoWithId:(NSString *)videoId {
    // handle processing video
    
    for (Video *video in self.activeTrip.videos.videos) {
        if ([video.videoID isEqualToString:videoId]) {
            video.processing = NO;
            video.failedUpload = YES;
            
            UIAlertView *charAlert = [[UIAlertView alloc]
                                      initWithTitle:@"Video Processing Failed"
                                      message:@"A video was unable to process and can not be viewed. Please retry the upload."
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [charAlert show];
            
            
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark VideoViewController Delegate Methods

- (void)videoViewControllerDidCancel:(VideoViewController *)vvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/videos/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoViewController:(VideoViewController *)vvc didEditVideo:(Video *)video {
	[[GANTracker sharedTracker] trackPageview:@"/home/videos/" withError:nil];
    
    if (video.processing) {
        [self startProcessingTimer];
    }
    
	[self.activeTrip.videos insertVideo:video];
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoViewController:(VideoViewController *)vvc didDeleteVideo:(Video *)video {
	[[GANTracker sharedTracker] trackPageview:@"/home/videos/" withError:nil];
	[self.activeTrip.videos deleteVideo:video];
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)titleForVideoViewController:(VideoViewController *)vvc editingVideo:(Video *)video {
	if (video.videoID != nil) {
		return @"Edit Video";
	}
	else {
		return @"Add Video";
	}
}

- (BOOL)deleteButtonShouldDisplayForVideoViewController:(VideoViewController *)vvc editingVideo:(Video *)video {
	if (video.videoID != nil && video.processing == NO) {
		return YES;
	}
	else {
		return NO;
	}
}

#pragma mark MBProgressHUD Delegate Methods
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [processingTimerTracker invalidate];
    NSMutableArray *delegates = activeDownloads[@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
	connex.delegate = nil;
}

@end
