//
//  PhotoOptionsViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 05/05/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "PhotoOptionsViewController.h"
#import "BlogDetailTableViewCell.h"
#import "User.h"
#import "GANTracker.h"
#import "Constants.h"

#pragma mark -
#pragma mark PhotoOptionsViewController Private Interface
/**
	@brief Private fields to store a temporary caption and description for a Photo.
 
	This interface provides private accessors to fields storing a temporary caption and description for a Photo.
	When the users signalls completion the temporary details will be commited to the Photo.
 */
@interface PhotoOptionsViewController() 

@property (nonatomic, strong) NSString *changeCaption;
@property (nonatomic, strong) NSString *changeDescription;

@end

#pragma mark -
#pragma mark PhotoOptionsViewController Implementation
@implementation PhotoOptionsViewController

@synthesize done;
@synthesize cancel;
@synthesize tableView;
@synthesize deletePhoto;
@synthesize activePhoto;
@synthesize delegate;
@synthesize changeCaption;
@synthesize changeDescription;
@synthesize thePhoto;

#pragma mark UIViewController Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	tableView.backgroundColor = [UIColor clearColor];
    if ([UIColor tableViewSeperatorColor]) {
        tableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
	
	if (!self.changeCaption) {
		self.changeCaption = self.activePhoto.caption;
	}
	if (!self.changeDescription) {
		self.changeDescription = self.activePhoto.description;
	}
	
	if (!self.activePhoto.imageURI) {
		self.deletePhoto.hidden = YES;
	}
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
	self.done = nil;
	self.cancel = nil;
	self.tableView = nil;
	self.deletePhoto = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark IBActions

- (IBAction)donePressed {
	
	NSString *oldCaption = [self.activePhoto.caption copy];
	NSString *oldDescription = [self.activePhoto.description copy];
	
	self.activePhoto.caption = self.changeCaption;
	self.activePhoto.description = self.changeDescription;
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/update/" withError:nil];
	[delegate photoOptionsViewController:self didEditPhoto:self.activePhoto andImage:self.thePhoto oldCaption:oldCaption oldDescription:oldDescription];
}

- (IBAction)cancelPressed {
	[delegate photoOptionsViewControllerDidCancel:self];
}

- (IBAction)deletePhotoPressed {
	UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:nil
														 delegate:self
												cancelButtonTitle:@"Cancel"
										   destructiveButtonTitle:@"Delete"
												otherButtonTitles:nil];
	[actions showInView:self.view];
	
}

#pragma mark UITableView Delegate and UITableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
	if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogDetailTableViewCell" owner:nil options:nil];
		for (id currentObject in nibObjects) {
			if ([currentObject isKindOfClass:[BlogDetailTableViewCell class]]) {
				cell = (BlogDetailTableViewCell *)currentObject;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
	}
	
	if (indexPath.row == 0) {
		cell.label.text = @"Caption";
		cell.detail.text = changeCaption;
	}
	else if(indexPath.row == 1) {
		cell.label.text = @"Description";
		cell.detail.text = changeDescription;
	}
	
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == 0) {
		LocationTextViewController *ltvc = [[LocationTextViewController alloc] initWithNibName:nil bundle:nil];
		ltvc.delegate = self;
		ltvc.title = @"Caption";
        if (!self.changeCaption) {
            self.changeCaption = @"";
        }
		ltvc.area = @{@"name": self.changeCaption};	
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/edit/caption/" withError:nil];
		[self presentViewController:ltvc animated:YES completion:nil];
	}
	else {
		BodyTextViewController *btvc = [[BodyTextViewController alloc]initWithNibName:nil bundle:nil];
		btvc.delegate = self;
		btvc.body = self.changeDescription;
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/edit/description/" withError:nil];
		[self presentViewController:btvc animated:YES completion:nil];
	}
}

#pragma mark BodyTextViewController Delegate Methods
- (void)bodyTextViewController:(BodyTextViewController *)btvc didFinishEditingBody:(NSString *)bodyText {
	self.changeDescription = bodyText;
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)bodyTextViewControllerDidCancel:(BodyTextViewController *)btvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)titleForBodyTextViewController:(BodyTextViewController *)btvc {
	return @"Description";
}

- (BOOL)bodyTextViewControllerShouldClearOnEdit:(BodyTextViewController *)btvc {
	return NO;
}

#pragma mark LocationTextViewController Delegate Methods
- (void)locationTextViewController:(LocationTextViewController *)ltvc withTitle:(NSString *)title didFinishEditingLocation:(NSDictionary *)location {
	self.changeCaption = location[@"name"];
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationTextViewControllerDidCancel:(LocationTextViewController *)ltvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)labelForLocationTextViewController:(LocationTextViewController *)ltvc {
	return @"Caption";
}

#pragma mark UIActionSheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/photo/delete/" withError:nil];
		[delegate photoOptionsViewController:self didRequestDeleteOfPhoto:self.activePhoto];
	}
}

@end
