//
//  HostelPhotoViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 26/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoViewController.h"

@class HostelPhotoViewController;

#pragma mark -
#pragma mark HostelPhotoViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to display a Hostel objects images full screen using the HostelPhotoViewController
 
	This protocol allows delegates to be asked for an array of photos to display, and provides a signal that the user of the app has finished
	viewing photos. The delegate is then expected to dismiss the modal view.
 */
@protocol HostelPhotoViewControllerDelegate <NSObject>
#pragma mark Required Methods
@required

/**
	Delegate message requesting an array of images to display in the UIImageView
	@param hpvc The HostelPhotoViewController requesting the images
	@returns The array of images to display
 */
- (NSArray *)hostelPhotoViewControllerImages:(HostelPhotoViewController *)hpvc;

/**
	Delegate message signalling the user wishes to dismiss the HostelPhotoViewController
	@param hpvc The HostelPhotoViewController to dismiss
 */
- (void)hostelPhotoViewControllerDidFinish:(HostelPhotoViewController *)hpvc;

@end

/**
	@brief A PhotoViewController Subclass that displays an array of photos in an UIImageView
	
	This class provides the functionality to display an array of photos from there URIS by downloading and displaying
	them in a UIImageView. The class over-rides the various PhotoViewController methods to provide the correct
	functionality.
*/
@interface HostelPhotoViewController : PhotoViewController {

	/**
		Delegate to ask for images and dismiss the view
	 */
	id <HostelPhotoViewControllerDelegate> hostelPhotoDelegate;	
}

/**
	Action signalling user wishes to dismiss the modal view
	@param selector The button pressed
 */
- (IBAction)goBack:(id)selector;

@property (nonatomic, assign) id <HostelPhotoViewControllerDelegate> hostelPhotoDelegate;

@end
