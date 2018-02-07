//
//  AlbumTableViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 05/05/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "AlbumTableViewController.h"
#import "BlogDetailTableViewCell.h"
#import "User.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark AlbumTableViewController Private Interface
/**
	@brief Private methods used to access temporary stores for changes to an Album.
 
	This interface provides private accessors used to temporary stores for changes to an Album. Upon
	donePressed: firing, this changes are updated to the live Album object and then a remote request
	to Off Exploring updates the live site with the changes
 */
@interface AlbumTableViewController()

@property (nonatomic, strong) NSString *changeName;
@property (nonatomic, strong) NSString *changeState;
@property (nonatomic, strong) NSString *changeArea;
@property (nonatomic, strong) NSDictionary *changeGeolocation;

@end

#pragma mark -
#pragma mark AlbumTableViewController Implementation
@implementation AlbumTableViewController

@synthesize done;
@synthesize cancel;
@synthesize tableView;
@synthesize deleteAlbum;
@synthesize activeAlbum;
@synthesize navBar;
@synthesize delegate;
@synthesize changeName;
@synthesize changeState;
@synthesize changeArea;
@synthesize changeGeolocation;

#pragma mark UIViewController Methods

- (void)dealloc {
	connex.delegate = nil;
}

/**
	Additional setup after loading the view. Changes title of Navigation controller and hides delete button if necessary
 */
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	tableView.backgroundColor = [UIColor clearColor];
    
    if ([UIColor tableViewSeperatorColor]) {
        self.tableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
	
	if (!self.changeState) {
		self.changeState = self.activeAlbum.state;
	}
	if (!self.changeArea) {
		self.changeArea = self.activeAlbum.area;
	}
	if (!self.changeGeolocation) {
		self.changeGeolocation = self.activeAlbum.geolocation;
	}
	if (!self.changeName) {
		self.changeName = self.activeAlbum.name;
	}
	
	if ([delegate respondsToSelector:@selector(titleForAlbumTableViewController:editingAlbum:)]) {
		self.navBar.topItem.title = [delegate titleForAlbumTableViewController:self editingAlbum:self.activeAlbum];
	}
	
	if ([delegate respondsToSelector:@selector(deleteButtonShouldDisplayForAlbumTalbeViewController:editingAlbum:)]) {
		BOOL enabled = [delegate deleteButtonShouldDisplayForAlbumTalbeViewController:self editingAlbum:self.activeAlbum];
		
		if (enabled) {
			self.deleteAlbum.hidden = NO;
		}
		else {
			self.deleteAlbum.hidden = YES;
		}
	}
	
	[super viewDidLoad];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.view setNeedsLayout];
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
	self.done = nil;
	self.cancel = nil;
	self.tableView = nil;
	self.deleteAlbum = nil;
}

#pragma mark IBActions

- (IBAction)donePressed {
	
	if ([self.changeName isEqualToString:@""] || self.changeName == nil) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"Album name must be set!"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else {
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Saving...";
		[HUD show:YES];
		
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.changeName, @"albumname", self.changeState, @"state", self.changeArea, @"area", nil]; 
		
		if (self.changeGeolocation != nil) {
			NSString *latitude = [NSString stringWithFormat:@"%f",[(self.changeGeolocation)[@"latitude"] doubleValue]];
			NSString *longitude = [NSString stringWithFormat:@"%f",[(self.changeGeolocation)[@"longitude"] doubleValue]];
			
			dict[@"latitude"] = latitude;
			dict[@"longitude"] = longitude;
		}
		
		User *user = [User sharedUser];
		NSString *url;
		connex = [[OffexConnex alloc] init];
		connex.delegate = self;
		if (activeAlbum.albumID != nil) {
			dict[@"id"] = activeAlbum.albumID;
			url = [connex buildOffexRequestStringWithURI:[[[[[@"user/" stringByAppendingString:user.username] stringByAppendingString:@"/trip/"] stringByAppendingString:(activeAlbum.trip)[@"urlSlug"]] stringByAppendingString:@"/album/"] stringByAppendingString:activeAlbum.slug]];
		}
		else {
			url = [connex buildOffexRequestStringWithURI:[[[[@"user/" stringByAppendingString:user.username] stringByAppendingString:@"/trip/"] stringByAppendingString:(activeAlbum.trip)[@"urlSlug"]] stringByAppendingString:@"/album"]];
		}
		NSData *dataString = [connex paramaterBodyForDictionary:dict];
		[connex postOffexploringData:dataString withContentMode:@"application/x-www-form-urlencoded" toURL:url];
	}
}

- (IBAction)cancelPressed {
	[delegate albumTableViewControllerDidCancel:self];
}

- (IBAction)deleteAlbumPressed {
	
	UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:nil
														 delegate:self
												cancelButtonTitle:@"Cancel"
										   destructiveButtonTitle:@"Delete"
												otherButtonTitles:nil];
	[actions showInView:self.view];
	
	
}

#pragma mark OffexploringConnection Delegate Methods

- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	connex = nil;
	[HUD hide:YES];
	if ([results[@"request"][@"method"] isEqualToString:@"DELETE"]) {
		[delegate albumTableViewController:self didDeleteAlbum:self.activeAlbum];
	}
	else {
		Album *album = [[Album alloc] initFromDictionary:results[@"response"]];
		album.trip = activeAlbum.trip;
		[delegate albumTableViewController:self didEditAlbum:album];
	}
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	connex = nil;
	[HUD hide:YES];
	NSString *errorMessage = nil;
	NSString *errorTitle = nil;
	if ([[error userInfo][NSLocalizedDescriptionKey] isEqualToString:@"No Connection Error"]) {
		errorTitle = [NSString stringWithFormat:@"Error Sending to %@", [NSString partnerDisplayName]];
		errorMessage = [NSString stringWithFormat:@"We were unable to connect to %@. Please check your internet connection and retry.", [NSString partnerDisplayName]];
	}
	else if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"Albumname already in use"]) {
		errorTitle = @"Error Renaming Album";
		errorMessage = @"The album name you are trying to rename to is already in use.";
	}
	else {
		errorTitle = [NSString stringWithFormat:@"Error Communicating With %@, please retry", [NSString partnerDisplayName]];
		errorMessage = [error userInfo][NSLocalizedDescriptionKey];
	}
	
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:errorTitle
							  message:errorMessage
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
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
		cell.label.text = @"Name";
		cell.detail.text = changeName;
	}
	else if(indexPath.row == 1) {
		cell.label.text = @"Location";
		
		if (changeArea != nil) {
			cell.detail.text = [NSString stringWithFormat:@"%@, %@",changeArea, changeState];
		}
		else if (changeState != nil) {
			cell.detail.text = changeState;
		}
		else {
			cell.detail.text = @"";
		}
	}
	
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == 0) {
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/edit/name/" withError:nil];
		LocationTextViewController *ltvc = [[LocationTextViewController alloc]initWithNibName:nil bundle:nil];
		ltvc.delegate = self;
        if (!self.changeName) {
            self.changeName = @"";
        }
		ltvc.area = @{@"name": self.changeName};
		ltvc.title = @"Album Name";
		[self presentViewController:ltvc animated:YES completion:nil];
	}
	else if (indexPath.row == 1) {
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/edit/location/" withError:nil];
		LocationViewController *lvc = [[LocationViewController alloc]initWithNibName:nil bundle:nil];
		if (changeState != nil) {
            NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:changeState, @"name", nil];
			lvc.state = stateDictionary;
		}
		if (changeArea != nil) {
            NSDictionary *areaDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:changeArea, @"name", nil];
			lvc.area = areaDictionary;
		}
		lvc.geolocation = activeAlbum.geolocation;
		lvc.delegate = self;
		[self presentViewController:lvc animated:YES completion:nil];
	}
}

- (NSString *)labelForLocationTextViewController:(LocationTextViewController *)ltvc {
	return @"Album Name";
}

#pragma mark LocationTextViewController Delegate Methods

- (void)locationTextViewController:(LocationTextViewController *)ltvc withTitle:(NSString *)title didFinishEditingLocation:(NSDictionary *)location {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/edit/" withError:nil];
	self.changeName = location[@"name"];
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationTextViewControllerDidCancel:(LocationTextViewController *)ltvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LocationViewController Delegate Methods

- (void)locationViewController:(LocationViewController *)dvc 
			 didFinishWithState:(NSDictionary *)state 
					   withArea:(NSDictionary *)area
				withGeolocation:(NSDictionary *)geolocation {

	if (![state[@"name"] isEqualToString:@""]) {
		self.changeState = state[@"name"];
	}
	if (![area[@"name"] isEqualToString:@""]) {
		self.changeArea = area[@"name"];
	}
		
	self.changeGeolocation = geolocation;
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)locationViewControllerMustHaveCompleteLocationDetails:(LocationViewController *)lvc {
	return YES;
}

#pragma mark UIActionSheet Delegate Method
	
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		User *user = [User sharedUser];
		connex = [[OffexConnex alloc] init];
		connex.delegate = self;
		NSString *url = [connex buildOffexRequestStringWithURI:[[[[[@"user/" stringByAppendingString:user.username] stringByAppendingString:@"/trip/"] stringByAppendingString:(activeAlbum.trip)[@"urlSlug"]] stringByAppendingString:@"/album/"] stringByAppendingString:self.activeAlbum.slug]];
		[connex deleteOffexploringDataAtUrl:url];
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Deleting...";
		[HUD show:YES];
	}
}

#pragma mark MBProgressHUD Delegate Method

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
}

@end
