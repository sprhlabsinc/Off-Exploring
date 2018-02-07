//
//  LocalImagePickerViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "OffexConnex.h"
#import "ImageLoader.h"
#import "PhotoViewController.h"
#import "PhotoOptionsViewController.h"
#import "MBProgressHUD.h"
#import "JREngage.h"

#pragma mark -
#pragma mark LocalImagePickerViewController Declaration
/**
 @brief A UIViewController subclass to display a list of users photos inside an album belonging to a user
 
 This class handles all drawing and display of a users photos. It goes and fetches the list of photos
 from Off Exploring, and then once downloaded it displays those photos. The class uses an ImageLoader to 
 download each thumbnail for all the photos inside the album, and displays that image. The class allows 
 the selection of an image, to progress through to viewing the image full size in a PhotoViewController. 
 The class also provides the functionality to add a photo to Off Exploring from the iPhone app. 
 The class uses a UIScrollView, setting itself as the delegate to display photo information. It sets itself as an
 ImageLoader delegate to receive downloaded images, and an OffexploringConnection delegate to receive 
 data from Off Exploring API. It also sets itself as a PhotoOptionsViewController delegate to receive 
 notifications about changes to a photo or for adding a new photo. 
 
 @note It is expected that LocalImagePickerViewController will handle requests to change or create a photo 
 */
@interface LocalImagePickerViewController : UIViewController <OffexploringConnectionDelegate,ImageLoaderDelegate, UIScrollViewDelegate, UIActionSheetDelegate,
																UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoOptionsViewControllerDelegate,
																PhotoViewControllerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate,
																JREngageSharingDelegate>
{

	/**
		The Album the Photo objects belong to
	 */
	Album *activeAlbum;
	/**
		The UIScrollView the thumbnails are placed upon
	 */
	UIScrollView *scrollView;
	/**
		A button pressed to add a Photo to the Album
	 */
	UIBarButtonItem *addPhoto;
	/**
		A UIImagePickerController object used to pick photos from a users photo library, or to access the camera
	 */
	UIImagePickerController *pickerView;
	
@private
	/**
		A connection to Off Exploring to get the list of photos and add a photo
	 */
	OffexConnex *connex;
	/**
		A NSOperationQueue to handle image scaling and transformation off the main thread.
	 */
	NSOperationQueue *saveImageQueue;
	/**
		A repositry of active image downloads to stop double image requests
	 */
	NSMutableDictionary *activeDownloads;
	/**
		A utility loading view to display whilst making remote requests
	 */
	MBProgressHUD *HUD;
	/**
		A pointer to a photo marked for deletion
	 */
	Photo *photoToDelete;
	/**
	 A pointer to a photo marked for edit
	 */
	Photo *photoToEdit;
	/**
		A flag to say a photo is currently updating
	 */
	BOOL updatingPhoto;
	/**
	 A flag to say a photo is currently being added
	 */
	BOOL addingPhoto;
	/**
		A flag to say wether a photo needs to be saved to a users Off Exploring library if it is coming from the Camera or the phones
		image library
	 */
	BOOL saveToLibrary;
	/**
		Stores the previous caption for a photo in case of failure
	 */
	NSString *editingCaption;
	/**
		Stores the previous description for a photo in case of failure
	 */
	NSString *editingDescription;
}

#pragma mark IBActions
/**
	Opens a PhotoViewController with a photo to be displayed using the buttons tag property
	@param selector The button that was pressed triggering the event
 */
- (void)buttonClicked:(id)selector;
/**
	Displays an UIActionSheet asking for the source of the phot to upload
 */
- (IBAction)uploadPhoto;

@property (nonatomic, strong) Album *activeAlbum;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addPhoto;
@property (nonatomic, strong) UIImagePickerController *pickerView;

@end
