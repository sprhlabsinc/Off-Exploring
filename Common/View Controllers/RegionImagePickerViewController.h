//
//  RegionImagePickerViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "OffexConnex.h"
#import "ImageLoader.h"
#import "MBProgressHUD.h"

@class RegionImagePickerViewController;

#pragma mark -
#pragma mark RegionImagePickerViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, to download and information about selected photos from Off Exploring
 
	This protocol allows a RegionImagePickerViewController delegate to be messaged when a user has chosen an image, either from their
	own library or Off Explorings Library Images, for use as part of something else (usually a Blog post). The delegate may also be 
	sent a cancel message in order to dismiss the view.
 */
@protocol RegionImagePickerViewControllerDelegate <NSObject>

#pragma mark Required Delegate Methods
@required

/**
	Delegate is messaged when a user selects and downloads all the appropriate information about a Photo from Off Exploring
	@param rigvc The RegionImagePickerViewController object used to select the photo
	@param photo The photo that was downloaded
	@param image The full size image of the photo that was downloaded
	@param thumb The thumbnail image of the photo that was downloaded
 */
- (void)regionImagePickerViewController:(RegionImagePickerViewController *)rigvc didSelectPhoto:(Photo *)photo andImage:(UIImage *)image andThumbnail:(UIImage *)thumb;
/**
	Delegate is messaged when a user cancels the RegionImagePickerViewController 
	@param rigvc The RegionImagePickerViewController that was cancelled
 */
- (void)regionImagePickerViewControllerDidCancel:(RegionImagePickerViewController *)rigvc;

@end

#pragma mark -
#pragma mark RegionImagePickerViewController Declaration
/**
	@brief Provides functionality to select and download a Photo from Off Exploring for use as part of another item (usually a blog post)
	
	This class provides functionality to download all the appropriate compontents of a Photo, including its caption and description, as well
	as the full size and thumbnail images it encapsulates.  These details are all passed to its delegate. The class uses a tableview to 
	display the list of photos inside the library it is looking (either a users own library or the region images library on Off Exploring), 
	and sets itself as tableview delegate and data source as appropriate.  In order to download the images, it also sets itself as an 
	ImageLoader delegate. It sets itself as a UIScrollView delegate to know when to download these images (as they are scrolled into view).
 */
@interface RegionImagePickerViewController : UIViewController <OffexploringConnectionDelegate,ImageLoaderDelegate, 
UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIScrollViewDelegate, MBProgressHUDDelegate> 
{
	/**
		The delegate that receives the photo and its images
	 */
	id <RegionImagePickerViewControllerDelegate> __weak delegate;
	/**
		A flag to say wether the picker is operating on the Region Images library or the users own library
	 */
	BOOL regionImages;
	/**
		A pointer to the navigation bar to set the title
	 */
	UINavigationBar *navBar;
	/**
		The tableview displaying the Photos
	 */
	UITableView *tableView;
	/**
		An optional subdivider to restrict from which state Region Images are downloaded
	 */
	NSString *stateSubdivider;
@private
	/**
		A connection to Off Exploring to download the photo details from.
	 */
	OffexConnex *connex;
	/**
		A store of the current image downloads in progress to stop duplicates
	 */
	NSMutableDictionary *activeDownloads;
	/**
		An NSOperationQueue used to spawn concurrent threads for downloading photo details
	 */
	NSOperationQueue *saveImageQueue;
	/**
		An array of images that have been downloaded
	 */
	NSMutableArray *images;
	/**
		An array of section index titles to subdivide tableview
	 */
	NSArray *sectionIndexTitles;
	/**
		A loader to display when making a download request from Off Exploring
	 */
	MBProgressHUD *HUD;
	/**
		A flag to say when the download is complete
	 */
	BOOL downloadedData;
}

#pragma mark IBActions
/**
	Action signalling a request to dismiss the View Controller
 */
- (IBAction)cancelPressed;

@property (nonatomic, weak) id <RegionImagePickerViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL regionImages;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *stateSubdivider;
@end
