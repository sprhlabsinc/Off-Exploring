//
//  MergeViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 12/08/2011.
//  Copyright 2011 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffexConnex.h"
#import "MBProgressHUD.h"

@class MergeViewController;

@protocol MergeViewControllerDelegate

- (void)mergeViewControllerDidCancel:(MergeViewController *)mergeViewController;
- (void)mergeViewController:(MergeViewController *)mergeViewController didMergeAccountWithUsername:(NSString *)username password:(NSString *)password;

@end


@interface MergeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MBProgressHUDDelegate, OffexploringConnectionDelegate> {

	id <MergeViewControllerDelegate> __weak _delegate;
	UITableView *_tableView;
	UIBarButtonItem *_mergeButton;
	NSString *_socialIdentifier;
	NSString *_socialProvider;
	NSString *_username;
	NSString *_password;
	UITextField *_usernameTextField;
	UITextField *_passwordTextField;
	
	/**
	 A loader to display whilst making remote login requests
	 */
	MBProgressHUD *HUD;
}

@property (nonatomic, weak) id <MergeViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *mergeButton;
@property (nonatomic, strong) NSString *socialIdentifier;
@property (nonatomic, strong) NSString *socialProvider;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

- (IBAction)cancelButtonPressed;
- (IBAction)mergeButtonPressed;

@end
