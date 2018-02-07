//
//  HostelPhotoViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 26/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelPhotoViewController.h"

#pragma mark -
#pragma mark HostelPhotoViewController Implementation
@implementation HostelPhotoViewController

@synthesize hostelPhotoDelegate;

#pragma mark UIViewController Methods
- (void)dealloc {
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	if (self = [super initWithNibName:@"PhotoViewController" bundle:nibBundleOrNil]) {
		self.activePhoto = 0;
	}
	
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolBar.items];
	[items removeObjectAtIndex:0];
	NSArray *insertItems = [NSArray arrayWithArray:items];
	[self.toolBar setItems:insertItems animated:NO];
	
	[self.navTitle.leftBarButtonItem setTarget:self];
	self.navTitle.title =  @"Hostel Photos";
	
	if (hostelPhotoDelegate != nil) {
		NSArray *photoURIs = [hostelPhotoDelegate hostelPhotoViewControllerImages:self];
		if ([photoURIs count] > 0) {
			NSMutableArray *photosToAdd = [[NSMutableArray alloc] initWithCapacity:[photoURIs count]];
			for (NSString *aURI in photoURIs) {
				Photo *photo = [[Photo alloc] init];
				photo.imageURI = aURI;
				photo.caption = @"Hostel Photos";
				[photosToAdd addObject:photo];
				[photo release];
			}
			self.photos = [NSArray arrayWithArray:photosToAdd];
			[photosToAdd release];
		}
		//[photoURIs release];
		photoURIs = nil;
	}
	[super viewDidLoad];
}

#pragma mark IBActions

- (IBAction)goBack:(id)selector {
	[super goBack:selector];
	[hostelPhotoDelegate hostelPhotoViewControllerDidFinish:self];
}

/**
	Over-riding super:toolbarPressed to stop any editing actions
 */
- (IBAction)toolBarPressed {}

#pragma mark PhotoLoader over-ride
- (void)loadPhoto:(Photo *)photo {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSURL *urlToAccess = [NSURL URLWithString:photo.imageURI];
	NSData *data = [NSData dataWithContentsOfURL:urlToAccess options:NSDataReadingMapped error:nil];
	UIImage *downloadImage = [UIImage imageWithData:data];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	photo.imageDownloading = NO;
	photo.theImage = downloadImage;
	
	[self performSelectorOnMainThread:@selector(displayImage:) withObject:photo waitUntilDone:NO];	
}


@end
