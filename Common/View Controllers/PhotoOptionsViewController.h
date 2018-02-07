//
//  PhotoOptionsViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 05/05/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "LocationTextViewController.h"
#import "BodyTextViewController.h"

@class PhotoOptionsViewController;

#pragma mark -
#pragma mark PhotoOptionsViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive requests for changes to a photo on Off Exploring.
 
	This protocol allows delegates to be given signals in relation to changes a user wishes to make to a Photo on Off Exploring.
	These changes will be signalled from the PhotoOptionsViewController.  The delegate should handle these signals appropriately,
	hence these messages are required to have a delegate receiver.
 */
@protocol PhotoOptionsViewControllerDelegate <NSObject>

#pragma mark Required Delegate Methods
@required

/**
	Delegate message signalled when the user confirms changes to a photo (including caption, description etc)
	@param povc The PhotoOptionsViewController used for editing the Photo
	@param photo The Photo that was edited
	@param image The image the photo encapsulates
	@param oldCaption The old caption for the photo
	@param oldDescription The old description for the photo
 */
- (void)photoOptionsViewController:(PhotoOptionsViewController *)povc didEditPhoto:(Photo *)photo andImage:(UIImage *)image oldCaption:(NSString *)oldCaption oldDescription:(NSString *)oldDescription;

/**
	Delegate message signalled when the user cancells changes to a photo
	@param povc The PhotoOptionsViewController	
 */
- (void)photoOptionsViewControllerDidCancel:(PhotoOptionsViewController *)povc;
/**
	Delegate message signalled when the user confirms they wish to delete a photo from Off Exploring
	@param povc The PhotoOptionsViewController used for editing the Photo
	@param photo The Photo to be deleted
 */
- (void)photoOptionsViewController:(PhotoOptionsViewController *)povc didRequestDeleteOfPhoto:(Photo *)photo;

@end

#pragma mark -
#pragma mark PhotoOptionsViewController Declaration
/**
	@brief Provides functionality to edit a Photos details
 
	The class handles all user input in order to make changes to a Photo. This currently involves setting / editing a a photos caption,
	and setting / editing a photos description. The editor displays Photo details in a tableview, and so sets itself as a UITableView
	delegate and data source appropriatly.  It uses a LocationTextViewControllerDelegate as a method of free-text entry to change thh 
	caption and a BodyTextViewControllerDelegate as a method of free-text entry to change the description. Finally, it uses a 
	UIActionSheetDelegate to confirm deletion of a Photo.
 */
@interface PhotoOptionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LocationTextViewControllerDelegate, BodyTextViewControllerDelegate,
															UIActionSheetDelegate> 
{
	/**
		The Delegate to message with changes to the Photo
	 */
	id <PhotoOptionsViewControllerDelegate> __weak delegate;
	/**
		A button to press to signal changes are complete
	 */
	UIBarButtonItem *done;
	/**
		A button to press to cancel changes to a Photo
	 */
	UIBarButtonItem *cancel;
	/**
		A tableview to display Photo details
	 */
	UITableView *tableView;
	/**
		A button to press to delete a Photo from Off Exploring.
	 */
	UIButton *deletePhoto;
	/**
		The Photo being edited
	 */
	Photo *activePhoto;
	/**
		The associated image being edited
	 */
	UIImage *thePhoto;

@private
	/**
		A temporary store for a new caption for the Photo
	 */
	NSString *changeCaption;
	/**
		A temporary store for a new description for the Photo
	 */
	NSString *changeDescription;
}

#pragma mark IBActions
/**
	Action signalling editing complete
 */
- (IBAction)donePressed;
/**
	Action signalling editing cancelled
 */
- (IBAction)cancelPressed;
/**
	Action signalling delete of photo
 */
- (IBAction)deletePhotoPressed;

@property (nonatomic, weak) id <PhotoOptionsViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *done;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *deletePhoto;
@property (nonatomic, strong) Photo *activePhoto;
@property (nonatomic, strong) UIImage *thePhoto;

@end
