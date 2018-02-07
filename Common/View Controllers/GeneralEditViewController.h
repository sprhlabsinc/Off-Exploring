//
//  GeneralEditViewController.h
//  KILROY Blogs
//
//  Created by Off Exploring on 22/10/2010.
//  Copyright 2010 KILROY Blogs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTextViewController.h"
#import "BodyTextViewController.h"

@class GeneralEditViewController;

#pragma mark -
#pragma mark GeneralEditViewControllerDelegate Declaration
/**
 @brief Details a protocol that must be adheared to, to handle creation, editing and deletion of any General Content.
 
 This protocol allows delegates to be given signals to ask for information to create a editing / adding / deleting panel
 for a given object type. The delegate is notified of the changes, and is expected to handle to commits to the server. 
 Also provides optional overrides for the delegate in order to specifiy if this View Controller is editing or creating content.
 */
@protocol GeneralEditViewControllerDelegate <NSObject>

enum {
    GeneralEditViewControllerPropertyEditingStyleSingle,
    GeneralEditViewControllerPropertyEditingStyleBlock
};
typedef NSUInteger GeneralEditViewControllerPropertyEditingStyle;

#pragma mark Required Delegate Methods
@required

/**
 Delegate method called when editing of an object takes place, returning the object to the delegate
 @param gevc The GeneralEditViewController used to perform the edits
 @param anObject The edited object
 */
- (void)generalEditViewController:(GeneralEditViewController *)gevc didEditObject:(id)anObject;
/**
 Delegate method called when a delete of an object takes place, returning the object to the delegate
 @param gevc The GeneralEditViewController used to delete the object
 @param anObject The deleted object
 */
- (void)generalEditViewController:(GeneralEditViewController *)gevc didDeleteObject:(id)anObject;
/**
 Delegate method called when a user presses the cancel button on the View
 @param gevc The GeneralEditViewController firing the event
 */
- (void)generalEditViewControllerDidCancel:(GeneralEditViewController *)gevc;

#pragma mark Optional Delegate Methods
@optional

/**
 Asks the delegate for permission to dismiss editing on save button press - allows the delegate to perfom validation
 @param gevc The GeneralEditViewController used to perform the edits
 @param anObject The edited object
 @returns The permission
 */
- (BOOL)generalEditViewController:(GeneralEditViewController *)gevc canSaveEditingObject:(id)anObject;

/**
 Asks the delegate for label for cell at indexPath
 @param editingObject The object being edited
 @param indexPath The indexPath for the cell requiring a label
 @returns The label to set
 */
- (NSString *)labelForEditingObject:(id)editingObject forCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Asks the delegate for key for the KVC for cell at indexPath
 @param editingObject The object being edited
 @param indexPath The indexPath for the cell requiring a key to set
 @returns The key to access
 */
- (NSString *)keyForEditingObject:(id)editingObject forCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Asks the delegate what editing style should be used on a perticular property for an object
 @param editingObject The object being edited
 @param indexPath The indexPath for the cell requiring an edit style
 @returns The editing style
 */
- (GeneralEditViewControllerPropertyEditingStyle)styleForEditingObject:(id)editingObject forCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Delegate method providing delegates the option to not display the delete button on the ViewController - 
 used if creating instead of editing an object
 @param gevc The GeneralEditViewController firing the event
 @param anObject The Album being edited
 @returns The boolean display status of the delete button on the GeneralEditViewController
 */
- (BOOL)deleteButtonShouldDisplayForGeneralEditViewController:(GeneralEditViewController *)gevc editingObject:(id)anObject;

@end

@interface GeneralEditViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LocationTextViewControllerDelegate, BodyTextViewControllerDelegate, UIActionSheetDelegate> {
	
	id <GeneralEditViewControllerDelegate> __weak delegate;
	UITableView *theTableView;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *saveButton;
	UINavigationBar *navBar;
	/**
		A button pressed to signal album deletion
	 */
	UIButton *deleteButton;
	
@private
	int cells;
	id editingObject;
	NSIndexPath *editingPath;
}

#pragma mark Initialiser
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *)newTitle cells:(NSUInteger)cellCount editingObject:(id)anObject;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *)newTitle cells:(NSUInteger)cellCount editingObject:(id)anObject delegate:(id)newDelegate;

#pragma mark IBActions
- (IBAction)cancel;
- (IBAction)save;
- (IBAction)deleteObject;

@property (nonatomic, weak) id <GeneralEditViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *theTableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

@end
