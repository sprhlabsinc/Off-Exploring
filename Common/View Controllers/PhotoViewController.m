//
//  PhotoViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 21/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "PhotoViewController.h"
#import "User.h"
#import "Photo.h"
#import "OffexConnex.h"
#import "PhotoOptionsViewController.h"
#import "ImageLoader.h"
#import "GANTracker.h"
#import "Reachability.h"
#import "MessageTextViewController.h"
#import "OFXComment.h"
#import "Constants.h"

#pragma mark -
#pragma mark PhotoViewController Private Interface
/**
 @brief Private field to spawn concurrent threads to load images from Off Exploring without locking the UI.
 
 This interface provides a field to use to load a UIImage for a photo from a remote source by concurrently
 spawning a thread for it. This thread fetches the image, downloads it, and the using a selector to the main
 thread to display it.
 */
@interface PhotoViewController() <MessageTextViewControllerDelegate, OffexploringConnectionDelegate>

@property (nonatomic, strong) NSOperationQueue *loadImageQueue;
@property (nonatomic, strong) MessageTextViewController *messageTextViewController;

@end

#pragma mark -
#pragma mark PhotoViewController Implementation
@implementation PhotoViewController

@synthesize photos;
@synthesize activePhoto;
@synthesize navBar;
@synthesize navTitle;
@synthesize toolBar;
@synthesize loadImageQueue;
@synthesize previousButton;
@synthesize nextButton;
@synthesize editButton;
@synthesize delegate;
@synthesize viewBlogPhoto;
@synthesize currentlyEditingPhoto;
@synthesize pagingScrollView;
@synthesize messageTextViewController = _messageTextViewController;

#pragma mark UIViewController Methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        loadImageQueue = [[NSOperationQueue alloc] init];
		[loadImageQueue setMaxConcurrentOperationCount:3];
		
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
	self.navigationController.navigationBarHidden = YES;
	
	CGRect pagingScrollViewFrame = [[UIScreen mainScreen] bounds];
	pagingScrollViewFrame.origin.x -= 10;
	pagingScrollViewFrame.size.width += 20;
	pagingScrollViewFrame.origin.y -= 20;
	pagingScrollViewFrame.size.height += 20;
	
	pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
	pagingScrollView.pagingEnabled = YES;
	pagingScrollView.backgroundColor = [UIColor blackColor];
	pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	pagingScrollView.delegate = self;
	[self.view addSubview:pagingScrollView];
	[self.view sendSubviewToBack:pagingScrollView];
	
	recycledPages = [[NSMutableSet alloc] init];
    visiblePages  = [[NSMutableSet alloc] init];
	
	CGFloat pageWidth = pagingScrollView.bounds.size.width;
	CGRect newBounds = CGRectMake(pagingScrollView.bounds.origin.x + (pageWidth * activePhoto), pagingScrollView.bounds.origin.y, pagingScrollView.bounds.size.width, pagingScrollView.bounds.size.height);
	CGSize currentBounds = [self contentSizeForPagingScrollView];
	if (newBounds.origin.x < currentBounds.width) {
		pagingScrollView.bounds = newBounds;
	}
	
	if (viewBlogPhoto == YES) {
		self.toolBar.hidden = YES;
	}
	else {
		self.toolBar.hidden = NO;
	}
	
	[self tilePages];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.navBar = nil;
	self.navTitle = nil;
	self.toolBar = nil;
	self.previousButton = nil;
	self.nextButton = nil;
	
	self.pagingScrollView = nil;
    recycledPages = nil;
    visiblePages = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (self.navBar.hidden == YES) {
		self.navBar.frame = CGRectMake(0, 20, self.navBar.frame.size.width, self.navBar.frame.size.height);
	}
	else {
		self.navBar.frame = CGRectMake(0, 0, self.navBar.frame.size.width, self.navBar.frame.size.height);
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
    // place to calculate the content offset that we will need in the new orientation
    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    
    if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// adjust frames and configuration of each visible page
    for (ImageScrollView *page in visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
        
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}

- (void)imageScrollViewDidSingleTap:(ImageScrollView *)isv {
    
	if (self.navBar.hidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		
		self.navBar.hidden = YES;
		self.toolBar.hidden = YES;
	}
	else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		
		self.navBar.hidden = NO;
		if (viewBlogPhoto == YES) {
			self.toolBar.hidden = YES;
		}
		else {
			self.toolBar.hidden = NO;
		}
	}
}

#pragma mark IBActions

- (IBAction)goBack:(id)selector {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
    self.navigationController.navigationBarHidden = NO;
	if (self.currentlyEditingPhoto == YES) {
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/" withError:nil];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	else {
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/" withError:nil];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction)previousPhoto {
	CGFloat pageWidth = pagingScrollView.bounds.size.width;
	CGRect newBounds = CGRectMake(pagingScrollView.bounds.origin.x - pageWidth, pagingScrollView.bounds.origin.y, pagingScrollView.bounds.size.width, pagingScrollView.bounds.size.height);
	if (newBounds.origin.x >= 0) {
		pagingScrollView.bounds = newBounds;
		[self tilePages];
	}
}

- (IBAction)nextPhoto {	
	CGFloat pageWidth = pagingScrollView.bounds.size.width;
	CGRect newBounds = CGRectMake(pagingScrollView.bounds.origin.x + pageWidth, pagingScrollView.bounds.origin.y, pagingScrollView.bounds.size.width, pagingScrollView.bounds.size.height);
	CGSize currentBounds = [self contentSizeForPagingScrollView];
	if (newBounds.origin.x < currentBounds.width) {
		pagingScrollView.bounds = newBounds;
		[self tilePages];
	}
}

- (IBAction)toolBarPressed {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/edit/" withError:nil];
	
	Reachability *r = [Reachability reachabilityWithHostName:@"www.offexploring.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
		PhotoOptionsViewController *photoView = [[PhotoOptionsViewController alloc] initWithNibName:nil bundle:nil];
		Photo *photo = (self.photos)[self.activePhoto];
		photoView.activePhoto = photo;
		photoView.delegate = self;
		
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
		[self presentViewController:photoView animated:YES completion:nil];
		
	}
	else {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:[NSString stringWithFormat:@"%@ Connection Error", [NSString partnerDisplayName]]
								  message:@"Unable to edit photos, please check your internet connection and retry."
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
}

#pragma mark UIScrollView Paging Stuff
- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
	return CGSizeMake(bounds.size.width * [self.photos count], bounds.size.height);
}

- (void)tilePages {
    // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
	int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    
	int displayPage = MAX(firstNeededPageIndex, 0);
    self.activePhoto = MIN(displayPage,[self.photos count] - 1);
	
	firstNeededPageIndex = MAX(firstNeededPageIndex - 1, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex + 1, [self.photos count] - 1);
    
    // Recycle no-longer-visible pages 
    for (ImageScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
			[page clearPhoto];
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
			Photo *photo = (self.photos)[index];
			if (photo.theImage == nil && photo.imageDownloading == NO) {
				photo.imageDownloading = YES;
				[self concurrentlyLoadPhoto:photo];
			}
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[ImageScrollView alloc] init];
				page.imageScrollViewDelegate = self;
            }
            [self configurePage:page forIndex:index];
			[page displayPhoto:photo];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    } 
	
	Photo *captionPhoto = (self.photos)[self.activePhoto];
	self.navTitle.title = captionPhoto.caption;
}

- (ImageScrollView *)dequeueRecycledPage{
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        
        [recycledPages removeObject:page];
    }
	page.displayPhoto = nil;
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    BOOL foundPage = NO;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index {
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * 10);
    pageFrame.origin.x = (bounds.size.width * index) + 10;
	return pageFrame;
}

#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tilePages];
}

#pragma mark UIImageView Setter
- (void)displayImage:(Photo *)photo {
	for (ImageScrollView *page in visiblePages) {
        if ([page.displayPhoto.imageURI isEqualToString:photo.imageURI]) {
			[page displayImage];
		}
    }
}

#pragma mark Concurrent Photo Download

- (void)concurrentlyLoadPhoto:(Photo *)photo {
	NSInvocationOperation *loadThePhoto = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadPhoto:) object:photo];
	[self.loadImageQueue addOperation:loadThePhoto];
}

#pragma mark Private Methods
- (void)loadPhoto:(Photo *)photo {
	OffexConnex *offex = [[OffexConnex alloc] init];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *theURI = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)photo.imageURI, NULL, CFSTR(":?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8));
	
	NSURL *urlToAccess = [NSURL URLWithString: [S3_IMAGE_ADDRESS stringByAppendingString:theURI]];
	NSData *data = [NSData dataWithContentsOfURL:urlToAccess options:(NSUInteger)nil error:nil];
	UIImage *downloadImage = [UIImage imageWithData:data];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	photo.theImage = downloadImage;
	photo.imageDownloading = NO;
	
	[self performSelectorOnMainThread:@selector(displayImage:) withObject:photo waitUntilDone:NO];	
}

#pragma mark PhotoOptionsViewController Delegate Methods
- (void)photoOptionsViewController:(PhotoOptionsViewController *)povc didEditPhoto:(Photo *)photo andImage:(UIImage *)image oldCaption:(NSString *)oldCaption oldDescription:(NSString *)oldDescription {
	[delegate photoViewController:self didRequestUpdateOfPhoto:photo oldCaption:oldCaption oldDescription:oldDescription];
}
- (void)photoOptionsViewControllerDidCancel:(PhotoOptionsViewController *)povc {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];	
}

- (void)photoOptionsViewController:(PhotoOptionsViewController *)povc didRequestDeleteOfPhoto:(Photo *)photo {
	[delegate photoViewController:self didRequestDeleteOfPhoto:photo];
}

#pragma mark Comments
- (IBAction)commentsButtonPressed:(id)sender {
    Photo *photo = (self.photos)[self.activePhoto];
    User *user = [User sharedUser];
	OffexConnex *connex = [[OffexConnex alloc] init];
	connex.delegate = self;
    NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/comments", user.username]];
	[connex beginLoadingOffexploringDataFromURL:[NSString stringWithFormat:@"%@&contentType=photo&contentId=%@", url, photo.photoid]];
}

- (void)messageTextViewControllerDidFinish:(MessageTextViewController *)messageTextViewController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendMessage:(NSString *)message {
    Photo *photo = (self.photos)[self.activePhoto];
    
    User *user = [User sharedUser];
    NSDictionary *dict = @{@"name": user.username, @"comment": message, @"username": user.username, @"email": @"", @"contentId": photo.photoid, @"contentType": @"photo"};
    
    OffexConnex *connex = [[OffexConnex alloc] init];
    connex.delegate = self;
    NSData *bodyText = [connex paramaterBodyForDictionary:dict];
    NSString *contentMode = @"application/x-www-form-urlencoded";
    NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/comment",user.username]];
    [connex postOffexploringData:bodyText withContentMode:contentMode toURL:url];
}

- (void)deleteMessage:(id <MessageTextMessage>)aMessage {
    OffexConnex *connex = [[OffexConnex alloc] init];
    connex.delegate = self;
    
    User *user = [User sharedUser];
    NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/comment", user.username]];
    [connex deleteOffexploringDataAtUrl:[NSString stringWithFormat:@"%@&contentType=photo&id=%@", url, aMessage.messageId]];
}

#pragma mark OffexploringConnection Delegate
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
    
    if (([results[@"request"][@"method"] isEqualToString:@"DELETE"])  && results[@"response"][@"success"] && [results[@"response"][@"success"] isEqualToString:@"true"]) {
        
        [self.messageTextViewController hideHUDMessage];
        
        NSNumber *messageId = @([results[@"request"][@"getVars"][@"id"] intValue]);
        
        if ([self.messageTextViewController.messages count] == 1) {
            self.messageTextViewController.messages = @[];
            [self.messageTextViewController.tableView reloadData];
        }
        else {
            
            
            [self.messageTextViewController.tableView beginUpdates];
            
            NSMutableArray *messageArray = [self.messageTextViewController.messages mutableCopy];
            
            int count = 0;
            for (id <MessageTextMessage> aMessage in messageArray) {
                if ([aMessage.messageId isEqualToNumber:messageId]) {
                    [self.messageTextViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    [messageArray removeObject:aMessage];
                    break;
                }
                count++;
            }
            
            self.messageTextViewController.messages = messageArray;
            
            [self.messageTextViewController.tableView endUpdates];
            
        }
    }
    else if (results[@"response"][@"comment"]) {
        [self.messageTextViewController hideHUDMessage];
        
        // Animate adding the message
        OFXComment *newMessage = [[OFXComment alloc] initWithDictionary:results[@"response"][@"comment"]];
        
        if ([self.messageTextViewController.messages count] == 0) {
            self.messageTextViewController.messages = @[newMessage];
            [self.messageTextViewController.tableView reloadData];
        }
        else {
            [self.messageTextViewController.tableView beginUpdates];
            
            NSMutableArray *messagesArray = [self.messageTextViewController.messages mutableCopy];
            [messagesArray insertObject:newMessage atIndex:0];
            self.messageTextViewController.messages = messagesArray;
            
            [self.messageTextViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            
            [self.messageTextViewController.tableView endUpdates];
        }
        
        [self.messageTextViewController resetView];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarStyle:DEFAULT_UI_BAR_STYLE];
        
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in results[@"response"][@"comments"][@"comment"]) {
            OFXComment *aComment = [[OFXComment alloc] initWithDictionary:dict];
            [messages addObject:aComment];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        MessageTextViewController *messageTextViewController = [[MessageTextViewController alloc] initWithNibName:nil bundle:nil];
        self.messageTextViewController = messageTextViewController;
        self.messageTextViewController.delegate = self;
        self.messageTextViewController.messages = [messages sortedArrayUsingDescriptors:sortDescriptors];
        self.messageTextViewController.title = @"Comments";
        [self presentViewController:self.messageTextViewController animated:YES completion:nil];
    }
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *)error {
    
    [self.messageTextViewController hideHUDMessage];
    
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
    
    [charAlert show];
}

@end
