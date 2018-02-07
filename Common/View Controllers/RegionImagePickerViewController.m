//
//  RegionImagePickerViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "RegionImagePickerViewController.h"
#import "PhotoViewController.h"
#import "BlogLocationTableViewCell.h"
#import "User.h"
#import "Photo.h"

#pragma mark -
#pragma mark RegionImagePickerViewController Private Interface
/**
 @brief Private methods used to load images from Off Exploring.
 
 This interface provides a methods that start a request to download photos from Off Exploring. The first, beginLoadingPhotos:
 downlaods the list of photos to be displayed (either from the region images library or a users own library). The second, 
 loadImagesForOnscreenRows: then is called when a user stopps scrolling the tableview. Images are downloaded for those
 UITableViewCells that are currently in view. 
 */
@interface RegionImagePickerViewController()

#pragma mark Private Method Declarations
/**
 Starts the download for Photo objects from a remote source.
 */
- (void)beginLoadingPhotos;

/**
 Downloads the UIImage thumbnails for the Photos currently in view on the tableview.
 */
- (void)loadImagesForOnscreenRows;

@property (nonatomic, strong) NSOperationQueue *saveImageQueue;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, assign) BOOL downloadedData;
@property (nonatomic, strong) NSArray *sectionIndexTitles;

@end

#pragma mark -
#pragma mark RegionImagePickerViewController Implementation
@implementation RegionImagePickerViewController

@synthesize regionImages;
@synthesize saveImageQueue;
@synthesize delegate;
@synthesize images;
@synthesize navBar;
@synthesize tableView;
@synthesize downloadedData;
@synthesize stateSubdivider;
@synthesize sectionIndexTitles;

#pragma mark UIViewController Methods
- (void)dealloc {
	NSMutableArray *delegates = activeDownloads[@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
	[saveImageQueue cancelAllOperations];
	connex.delegate = nil;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		images = [[NSMutableArray alloc] init];
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
	if (self.regionImages == YES) {
		self.title = @"Library Photos";
	}
	self.view.backgroundColor = [UIColor blackColor];
	self.navBar.topItem.title = self.title;
	[self beginLoadingPhotos];
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
	self.navBar = nil;
	self.tableView = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark IBActions
- (IBAction)cancelPressed {
	NSMutableArray *delegates = activeDownloads[@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
	[activeDownloads removeAllObjects];
	[delegate regionImagePickerViewControllerDidCancel:self];
}

#pragma mark Private Methods
- (void)beginLoadingPhotos {
	self.downloadedData = NO;
	NSString *url;
	connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	if (self.regionImages == YES && self.stateSubdivider != nil) {
		url = [[[connex buildOffexRequestStringWithURI:@"region_images"] stringByAppendingString:@"&state="] stringByAppendingString:[self.stateSubdivider stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	else if (self.regionImages == YES) {
		url = [connex buildOffexRequestStringWithURI:@"region_images"];
	}
	else {
		User *user = [User sharedUser];
		url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/photo",user.username]];
	}
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)loadImagesForOnscreenRows
{
    if ([self.images count] > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
			NSString *theFirstLetter = sectionIndexTitles[indexPath.section];
			int amount = 0;
			Photo *aPhoto = nil;
			for (Photo *aSinglePhoto in self.images) {
				NSString *indexTitle;
				if (self.regionImages == YES) {
					indexTitle = aSinglePhoto.state;
				}
				else {
					indexTitle = aSinglePhoto.albumName;
				}
				NSString *firstLetter = [indexTitle substringToIndex:1];
				if ([firstLetter caseInsensitiveCompare:theFirstLetter] == NSOrderedSame) {
					if (amount == indexPath.row) {
						aPhoto = aSinglePhoto;
						break;
					}
					amount++;
				}
			}
			
			if (aPhoto == nil || aPhoto.theImage == nil) {	
				NSString *remotePath = aPhoto.thumbURI;
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
}

#pragma mark OffexploringConnection Delegate Methods
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	connex = nil;
	
	if (results[@"response"][@"photos"] != [NSNull null]) {
		for (NSDictionary *anImage in results[@"response"][@"photos"][@"photo"]) {
			Photo *newPhoto = [[Photo alloc] initWithDictionary:anImage];
			if ((self.regionImages == YES && newPhoto.state != nil) || (self.regionImages == NO && newPhoto.albumName != nil) ) {
				[self.images addObject:newPhoto];
			}
		}
	}
	if ([self.images count] == 0) {
        
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"No Photos"
								  message:@"You do not have any saved photos yet!"
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else {
		NSMutableSet *setOfSectionIndexTitles = [[NSMutableSet alloc] init];
		
		Photo *aPhoto;
		
		for (aPhoto in self.images) {
			NSString *indexTitle;
			if (self.regionImages == YES) {
				indexTitle = aPhoto.state;
			}
			else {
				indexTitle = aPhoto.albumName;
			}
			NSString *firstLetter = [indexTitle substringToIndex:1]; 
			[setOfSectionIndexTitles addObject:firstLetter];
		}
		NSArray *unsortedTitles = [[NSArray alloc] initWithArray:[setOfSectionIndexTitles allObjects]];
		sectionIndexTitles = [unsortedTitles sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	}
	self.downloadedData = YES;
	[self.tableView reloadData];
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {	
	connex = nil;
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:[NSString stringWithFormat:@"%@ Connection Error", [NSString partnerDisplayName]]
							  message:[NSString stringWithFormat:@"An error has occured connecting to %@. Please retry.", [NSString partnerDisplayName]]
							  delegate:nil
							  cancelButtonTitle:@"Cancel"
							  otherButtonTitles:nil];
	charAlert.delegate = self;
	[charAlert show];
	
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.downloadedData == NO) {
		return 1;
	}
	else {
		return [sectionIndexTitles count];
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.downloadedData == NO) {
		return 1;
	}
	else {
		NSString *theFirstLetter = sectionIndexTitles[section];
		int count = 0;
		int amount = 0;
		for (Photo *aPhoto in self.images) {
			NSString *indexTitle;
			if (self.regionImages == YES) {
				indexTitle = aPhoto.state;
			}
			else {
				indexTitle = aPhoto.albumName;
			}
			NSString *firstLetter = [indexTitle substringToIndex:1];
			if ([firstLetter caseInsensitiveCompare:theFirstLetter] == NSOrderedSame) {
				amount++;
			}
			count++;
		}
		return amount;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if ([self.images count] > 0) {
		UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 22.0)];
		header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"divider.png"]];
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, 300, 20)];
		headerLabel.text = sectionIndexTitles[section];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.font = [UIFont boldSystemFontOfSize: 13];
		headerLabel.textColor = [UIColor headerLabelTextColorPlainStyle];
        headerLabel.shadowColor = [UIColor headerLabelShadowColorPlainStyle];
        headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		[header addSubview: headerLabel];
		return header;
	}
	else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.downloadedData == NO) {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
														reuseIdentifier:nil];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activity startAnimating];
		activity.frame = CGRectMake(20, 20, 20, 20);
		[cell.contentView addSubview:activity];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, 100, 20)];
		label.text = @"Loading...";
		label.textColor = [UIColor colorWithRed: 64/255.0 green: 64/255.0 blue: 64/255.0 alpha:1.0];
		label.font = [UIFont boldSystemFontOfSize: 16.0];
		[cell.contentView addSubview:label];
		return cell;
	}
	else {
		
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"generalCell"];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:@"generalCell"];
			
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 60)];
			
			imageView.image = [UIImage imageNamed:@"placeholder.png"];
			imageView.contentMode = UIViewContentModeScaleToFill;
			
			[cell.contentView addSubview:imageView];
		}
		
		NSString *theFirstLetter = sectionIndexTitles[indexPath.section];
		
		int amount = 0;
		Photo *aPhoto = nil;
		for (Photo *aSinglePhoto in self.images) {
			NSString *indexTitle;
			if (self.regionImages == YES) {
				indexTitle = aSinglePhoto.state;
			}
			else {
				indexTitle = aSinglePhoto.albumName;
			}
			NSString *firstLetter = [indexTitle substringToIndex:1];
			if ([firstLetter caseInsensitiveCompare:theFirstLetter] == NSOrderedSame) {
				if (amount == indexPath.row) {
					aPhoto = aSinglePhoto;
					break;
				}
				amount++;
			}
		}
        
		
		for (UIView *aTextLabel in cell.contentView.subviews) {
			if ([aTextLabel isKindOfClass:[UILabel class]]) {
				[aTextLabel removeFromSuperview];
			}
			else if ([aTextLabel isKindOfClass:[UIImageView class]]) {
				UIImageView *imageView = (UIImageView *)aTextLabel;
				imageView.image = [UIImage imageNamed:@"placeholder.png"];
			}
		}
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 230, 40)];
		if (self.regionImages == YES) {
            if (aPhoto && aPhoto.caption) {
                textLabel.text = aPhoto.caption;
            }
		}
		else {
			if (aPhoto.caption != nil) {
				textLabel.text = [[aPhoto.caption stringByAppendingString:@", "] stringByAppendingString:aPhoto.albumName];
			}
			else {
				textLabel.text = [@"Untitled, " stringByAppendingString:aPhoto.albumName];
			}
		}
		
		textLabel.font = [UIFont boldSystemFontOfSize:16];
		textLabel.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
		[cell.contentView addSubview:textLabel];
		
		return cell;
	}
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.images count] > 0) {
		NSString *theFirstLetter = sectionIndexTitles[indexPath.section];
		int amount = 0;
		Photo *aPhoto = nil;
		for (Photo *aSinglePhoto in self.images) {
			NSString *indexTitle;
			if (self.regionImages == YES) {
				indexTitle = aSinglePhoto.state;
			}
			else {
				indexTitle = aSinglePhoto.albumName;
			}
			NSString *firstLetter = [indexTitle substringToIndex:1];
			if ([firstLetter caseInsensitiveCompare:theFirstLetter] == NSOrderedSame) {
				if (amount == indexPath.row) {
					aPhoto = aSinglePhoto;
					break;
				}
				amount++;
			}
		}
		
		if (aPhoto == nil || aPhoto.theImage == nil) {	
			NSString *remotePath = aPhoto.thumbURI;
			if (activeDownloads[remotePath] == nil && self.tableView.dragging == NO && self.tableView.decelerating == NO) {
				activeDownloads[remotePath] = indexPath;
				ImageLoader *imageLoader = [[ImageLoader alloc] init];
				imageLoader.delegate = self;
				NSMutableArray *dels = activeDownloads[@"delegates"];
				[dels addObject:imageLoader];
				[imageLoader startDownloadForURL:remotePath];
			}
		}
		else {
			for (id aImageView in cell.contentView.subviews) {
				if ([aImageView isKindOfClass:[UIImageView class]]) {
					UIImageView *imageView = (UIImageView *)aImageView;
					imageView.image = aPhoto.theImage;
					break;
				}
			}
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *theFirstLetter = sectionIndexTitles[indexPath.section];
	int amount = 0;
	Photo *aPhoto = nil;
	for (Photo *aSinglePhoto in self.images) {
		NSString *indexTitle;
		if (self.regionImages == YES) {
			indexTitle = aSinglePhoto.state;
		}
		else {
			indexTitle = aSinglePhoto.albumName;
		}
		NSString *firstLetter = [indexTitle substringToIndex:1];
		if ([firstLetter caseInsensitiveCompare:theFirstLetter] == NSOrderedSame) {
			if (amount == indexPath.row) {
				aPhoto = aSinglePhoto;
				break;
			}
			amount++;
		}
	}
	
	if (aPhoto == nil || aPhoto.theImage == nil) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"Thumbnail must be downloaded to select image!"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else {
        
		for (ImageLoader *loader in activeDownloads[@"delegates"]) {
			loader.delegate = nil;
		}
		[activeDownloads removeAllObjects];
		
		ImageLoader *imageLoader = [[ImageLoader alloc] init];
		activeDownloads[aPhoto.imageURI] = indexPath;
		imageLoader.delegate = self;
		
		[imageLoader startDownloadForURL:aPhoto.imageURI];
		
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Saving...";
		[HUD show:YES];
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

#pragma mark ImageLoader Delegate Method
- (void)imageLoader:(ImageLoader *)loader didLoadImage:(UIImage *)image forURI:(NSString *)uri {
	NSIndexPath *indexPath = (NSIndexPath *)activeDownloads[uri];
	
	NSString *theFirstLetter = sectionIndexTitles[indexPath.section];
	int amount = 0;
	Photo *thePhoto = nil;
	for (Photo *aSinglePhoto in self.images) {
		NSString *indexTitle;
		if (self.regionImages == YES) {
			indexTitle = aSinglePhoto.state;
		}
		else {
			indexTitle = aSinglePhoto.albumName;
		}
		NSString *firstLetter = [indexTitle substringToIndex:1];
		if ([firstLetter caseInsensitiveCompare:theFirstLetter] == NSOrderedSame) {
			if (amount == indexPath.row) {
				thePhoto = aSinglePhoto;
				break;
			}
			amount++;
		}
	}
	
	if ([uri isEqualToString:thePhoto.imageURI]) {
		UIImage *thumb = thePhoto.theImage;
		[HUD hide:NO];
		[delegate regionImagePickerViewController:self didSelectPhoto:thePhoto andImage:image andThumbnail:thumb];
	}
	else {
		thePhoto.theImage = image;
		UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];
		for (id aImageView in theCell.contentView.subviews) {
			if ([aImageView isKindOfClass:[UIImageView class]]) {
				UIImageView *imageView = (UIImageView *)aImageView;
				imageView.image = thePhoto.theImage;
				break;
			}
		}
	}
}

#pragma mark MBProgressHUD Delegate Method
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}


@end
