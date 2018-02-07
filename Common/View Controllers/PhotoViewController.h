//
//  PhotoViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 21/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "PhotoOptionsViewController.h"
#import "ImageScrollView.h"

@class PhotoViewController;

#pragma mark -
#pragma mark PhotoViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, to pass through messages from a PhotoOptionsViewController to a PhotoViewControllerDelegate.
 
	This protocol requires the PhotoViewController Delegate to handle messages from a PhotoOptionsViewController by providing pass-through methods.
	This is because the PhotoViewController does not and should not handle these changes with Off Exploring, but needs to have appropriate processing
	on the Photo be handled. PhotoViewController handles cancellation delegate method from PhotoOptionsViewController so no pass-through is required.
 */
@protocol PhotoViewControllerDelegate <NSObject>

#pragma mark Required Delegate Methods
@required

/**
	Pass-through delegate method to handle updates of a Photo's Details
	@param povc The PhotoViewController passing through the Photo
	@param photo The Photo being edited
 */
- (void)photoViewController:(PhotoViewController *)povc didRequestUpdateOfPhoto:(Photo *)photo oldCaption:(NSString *)oldCaption oldDescription:(NSString *)oldDescription;
/**
	Pass-through delegate method to handle deletion of a Photo
	@param povc The PhotoViewController passing through the Photo
	@param photo The Photo to be deleted
 */
- (void)photoViewController:(PhotoViewController *)povc didRequestDeleteOfPhoto:(Photo *)photo;

@end

#pragma mark -
#pragma mark PhotoViewController Declaration
/**
	@brief Provides functionality to view full size Photos from an album
 
	This class provides functionality to display, full size Photos to the user. It allows the image to be displayed in landscape or 
	portrait mode. Users can progress through the album using the navigation controls on the toolbar at the bottom of the view. Class
	sets itself as a PhotoOptionsViewController Delegate to allow editing of a photo and provide a pass through to handle changes made
	to Photos
 */
@interface PhotoViewController : UIViewController <PhotoOptionsViewControllerDelegate, UIScrollViewDelegate, ImageScrollViewDelegate> {

	/**
		Delegate that receives pass through messages from a PhotoOptionsViewController
	 */
	id <PhotoViewControllerDelegate> __weak delegate;
	/**
		A navigation bar access for hiding the bar
	 */
	UINavigationBar *navBar;
	/**
		A pointer to the page title so it can be set via photo caption
	 */
	UINavigationItem *navTitle;
	/**
		A toolbar with back, forward and edit buttons, access provided for hiding the bar
	 */
	UIToolbar *toolBar;
	/**
		The photos to display
	 */
	NSArray *photos;
	/**
		The array index of the photo being viewed
	 */
	int activePhoto;
	/**
		A button to press to go to the previous photo in the album
	 */
	UIBarButtonItem *previousButton;
	/**
		A button to press to go the next photo in the album
	 */
	UIBarButtonItem *nextButton;
	/**
		A button to press to edit details about the photo
	 */
	UIBarButtonItem *editButton;
	/**
		A flag to set if the photo belongs to a blog
	 */
	BOOL viewBlogPhoto;
	/**
		A flag to set if the photo is currently part of an edited blog. This flag alters
		captioning of the photo.
	 */
	BOOL currentlyEditingPhoto;
	/**
	 Scroll View for scrolling through images
	 */
	UIScrollView *pagingScrollView;
	
@private
	/**
		An NSOperationQueue used to spawn concurrent threads for downloading and showing different Photos in an album
	 */
	NSOperationQueue *loadImageQueue;
	
	/**
		Page Caching - spare pages for reuse
	 */
	NSMutableSet *recycledPages;
	
	/**
		Page Caching - pages in use
	 */
    NSMutableSet *visiblePages;
	
	// these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int           firstVisiblePageIndexBeforeRotation;
    CGFloat       percentScrolledIntoFirstVisiblePage;
}

#pragma mark IBActions
/**
	Action signalling close of the PhotoViewController 
	@param selector The button pressing
 */
- (IBAction)goBack:(id)selector;
/**
	Action signalling request of previous photo to view
 */
- (IBAction)previousPhoto;
/**
	Action signalling request of next photo to view
 */
- (IBAction)nextPhoto;
/**
	Action signalling request to edit a photo
 */
- (IBAction)toolBarPressed;

#pragma mark UIImageView Setter
/**
	Main thread access to set the image from a photo to the UIImageView
	@param photo The UIImage to set to the view
 */
- (void)displayImage:(Photo *)photo;

#pragma mark Concurrent Photo Download
/**
 Concurrently loads a UIImage from a Photo and attempts to display it on the UIImageView
 @param photo The Photo to load
 */
- (void) concurrentlyLoadPhoto:(Photo *)photo;

- (CGSize)contentSizeForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (void)tilePages;
- (ImageScrollView *)dequeueRecycledPage;

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;

- (IBAction)commentsButtonPressed:(id)sender;

@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UINavigationItem	*navTitle;
@property (nonatomic, strong) UIScrollView *pagingScrollView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *previousButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *nextButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, assign) int activePhoto;
@property (nonatomic, weak) id <PhotoViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL viewBlogPhoto;
@property (nonatomic, assign) BOOL currentlyEditingPhoto;

@end
