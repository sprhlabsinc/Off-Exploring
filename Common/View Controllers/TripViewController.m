//
//  TripViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "TripViewController.h"
#import "BlogLocationViewController.h"
#import "AlbumsTableViewController.h"
#import "User.h"
#import "Trips.h"
#import "Trip.h"
#import "TripTableViewCell.h"
#import "GeneralEditViewController.h"
#import "GANTracker.h"
#import "MessageTextViewController.h"
#import "VideosViewController.h"

#pragma mark -
#pragma mark TripViewController Implementation
@implementation TripViewController

@synthesize table;
@synthesize requestType;
@synthesize trips;
@synthesize addButton;

#pragma mark UIViewController Methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.addButton;
	selectingTrip = NO;
	[self checkDraftBlogs];
}

- (void)viewWillAppear:(BOOL)animated {
	[table reloadData];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.addButton = nil;
}

- (IBAction) addTrip {
	[[GANTracker sharedTracker] trackPageview:@"/home/trips/add/" withError:nil];
	[[GANTracker sharedTracker] trackPageview:@"/home/trips/trip/edit/" withError:nil];
	Trip *newTrip = [[Trip alloc] init];
	GeneralEditViewController *edit = [[GeneralEditViewController alloc] initWithNibName:nil bundle:nil title:@"Add Trip" cells:2 editingObject:newTrip delegate:self];
	[self presentViewController:edit animated:YES completion:nil];

}

- (void)checkDraftBlogs {

	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	User *user = [User sharedUser];
	NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/Offexploring/Blog_Draft/%@", user.username]; 
	folder = [folder stringByExpandingTildeInPath];
	
	NSArray *paths = [fileManager contentsOfDirectoryAtPath:folder error:nil];
	
	for (NSString *path in paths) {
		Blog *newBlog = [NSKeyedUnarchiver unarchiveObjectWithFile:[folder stringByAppendingPathComponent:path]];
		
		if ([(newBlog.trip)[@"urlSlug"] isEqualToString:@"default"]){
			if (!noTripDrafts) {
				noTripDrafts = [[NSMutableArray alloc] initWithObjects:newBlog, nil];
			}
			else {
				[noTripDrafts addObject:newBlog];
			}
		}
	}
	
	if ([noTripDrafts count] > 0) {	
		//DEAL
		[self displayNoTripDraftsSelectorForIndex:0];
	}
}

- (void)displayNoTripDraftsSelectorForIndex:(NSUInteger)index {
	Blog *blog = noTripDrafts[index];
	
	NSString *entryText = nil;
	
	if ([noTripDrafts count] == 1) {
		entryText = [NSString stringWithFormat:@"You Have %d Draft Blog Entry", [noTripDrafts count]];
	}
	else {
		entryText = [NSString stringWithFormat:@"You Have %d Draft Blog Entries", [noTripDrafts count]];
	}
	
	selectingTrip = YES;
	selectingIndex = index;
	
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:entryText
							  message:[NSString stringWithFormat:@"Please choose which trip the %@ blog entry belongs to...",(blog.area)[@"name"]]
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
}

#pragma mark UITableView Delegate and Data Source Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 61.0;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [self.trips.tripsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TripTableViewCell *cell = (TripTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"customCell"];
	
	if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"TripTableViewCell" owner:nil options:nil];
		for (id currentObject in nibObjects) {
			if ([currentObject isKindOfClass:[TripTableViewCell class]]) {
				cell = (TripTableViewCell *)currentObject;
			}
		}
	}
	
	Trip *trip = (self.trips.tripsArray)[indexPath.row];
	
	cell.title.text = trip.name;
	cell.description.text = trip.description;
	if (self.requestType == 10) {
		[cell.coverImage setImage:trip.blogCoverImageFile];
		cell.contentCount.text = [NSString stringWithFormat:@"(%d)",trip.blogCount];
	}
	else {
		[cell.coverImage setImage:trip.albumCoverImageFile];
		cell.contentCount.text = [NSString stringWithFormat:@"(%d)",trip.albumCount];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Trip *theTrip = (self.trips.tripsArray)[indexPath.row];
	
	if (selectingTrip == NO) {
		if (self.requestType == 10) {
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/" withError:nil];
			BlogLocationViewController *locationView = [[BlogLocationViewController alloc] initWithNibName:nil bundle:nil];
			locationView.title = @"Locations";
			locationView.activeTrip = theTrip;
			[self.navigationController pushViewController:locationView animated:YES];
		}
		else if (self.requestType == 20) {
			[[GANTracker sharedTracker] trackPageview:@"/home/albums/" withError:nil];
			AlbumsTableViewController *albumView = [[AlbumsTableViewController alloc] initWithNibName:nil bundle:nil];
			albumView.title = @"Photo Albums";
			albumView.activeTrip = theTrip;
			[self.navigationController pushViewController:albumView animated:YES];
		}
        else if (self.requestType == 30) {
            [[GANTracker sharedTracker] trackPageview:@"/home/messages/" withError:nil];
            MessageTextViewController *controller = [[MessageTextViewController alloc] initWithNibName:nil bundle:nil];
            [controller loadMessagesForTrip:theTrip];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
            [[GANTracker sharedTracker] trackPageview:@"/home/videos/" withError:nil];
            VideosViewController *controller = [[VideosViewController alloc] initWithNibName:nil bundle:nil];
            controller.activeTrip = theTrip;
            [self.navigationController pushViewController:controller animated:YES];
        }
	}
	else {
		selectingTrip = NO;
		Blog *setBlog = noTripDrafts[selectingIndex];
		setBlog.trip = @{@"name": theTrip.name, @"urlSlug": theTrip.urlSlug};
		
		User *user = [User sharedUser];
		NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/Offexploring/Blog_Draft/%@", user.username]; 
		folder = [folder stringByExpandingTildeInPath];
		
		NSString *prepath = [[NSString alloc] initWithFormat:@"%d.blog",setBlog.original_timestamp]; 
		NSString *filePath = [folder stringByAppendingPathComponent:prepath];
		[NSKeyedArchiver archiveRootObject:setBlog toFile:filePath];
		[noTripDrafts removeObjectAtIndex:selectingIndex];
		
		if ([noTripDrafts count] > 0) {
			[self displayNoTripDraftsSelectorForIndex:0];
		}
		else {
			noTripDrafts = nil;
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/" withError:nil];
			BlogLocationViewController *locationView = [[BlogLocationViewController alloc] initWithNibName:nil bundle:nil];
			locationView.title = @"Locations";
			locationView.activeTrip = theTrip;
			[self.navigationController pushViewController:locationView animated:YES];
		}
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	Trip *theTrip = (self.trips.tripsArray)[indexPath.row];
	[[GANTracker sharedTracker] trackPageview:@"/home/trips/trip/edit/" withError:nil];
	GeneralEditViewController *edit = [[GeneralEditViewController alloc] initWithNibName:nil bundle:nil title:@"Edit Trip" cells:2 editingObject:theTrip delegate:self];
	[self presentViewController:edit animated:YES completion:nil];
}

#pragma mark GeneralEditViewController Delegate Methods

- (void)generalEditViewController:(GeneralEditViewController *)gevc didEditObject:(id)anObject{
	Trip *trip = (Trip *)anObject;
	OffexConnex *connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	
	User *user = [User sharedUser];
	NSDictionary *dict = @{@"tripname": trip.name, @"description": trip.description}; 
	NSString *url = nil;
	
	if (!trip.urlSlug) {
		url = [connex buildOffexRequestStringWithURI:[[@"user/" stringByAppendingString:user.username] stringByAppendingString:@"/trip"]];
	}
	else {
		url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@",user.username, trip.urlSlug]];
	}
	
	NSData *dataString = [connex paramaterBodyForDictionary:dict];
	[connex postOffexploringData:dataString withContentMode:@"application/x-www-form-urlencoded" toURL:url];
	
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Saving...";
	[HUD show:YES];
}

- (void)generalEditViewController:(GeneralEditViewController *)gevc didDeleteObject:(id)anObject{
	Trip *trip = (Trip *)anObject;
	deleteingTrip = trip;
	User *user = [User sharedUser];
	OffexConnex *connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	
	NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@",user.username, trip.urlSlug]];
	[connex deleteOffexploringDataAtUrl:url];
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Deleting...";
	[HUD show:YES];
}

- (void)generalEditViewControllerDidCancel:(GeneralEditViewController *)gevc{
	[[GANTracker sharedTracker] trackPageview:@"/home/trips/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)generalEditViewController:(GeneralEditViewController *)gevc canSaveEditingObject:(id)anObject {
	Trip *trip = (Trip *)anObject;
	
	if ([trip.name isEqualToString:@""] || !trip.name) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"Trip name must be set!"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
		return NO;
	}
	else if([trip.description isEqualToString:@""] || !trip.description) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"Trip description must be set!"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
		return NO;
	}
	else {
		return YES;
	}
}

- (NSString *)labelForEditingObject:(id)editingObject forCellAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.row == 0) {
		return @"Name";
	}
	else {
		return @"Description";
	}
}

- (NSString *)keyForEditingObject:(id)editingObject forCellAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.row == 0) {
		return @"name";
	}
	else {
		return @"description";
	}
}

- (GeneralEditViewControllerPropertyEditingStyle)styleForEditingObject:(id)editingObject forCellAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.row == 0) {
		return GeneralEditViewControllerPropertyEditingStyleSingle;
	}
	else {
		return GeneralEditViewControllerPropertyEditingStyleBlock;
	}
}

- (BOOL)deleteButtonShouldDisplayForGeneralEditViewController:(GeneralEditViewController *)gevc editingObject:(id)anObject {
	Trip *trip = (Trip *)anObject;
	
	if (!trip.urlSlug) {
		return NO;
	}
	else {
		return YES;
	}
}


#pragma mark offexploringConnection Delegate Methods
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	
	[HUD hide:YES];
	if ([results[@"request"][@"method"] isEqualToString:@"DELETE"]) {
		
		if ([results[@"response"][@"success"] isEqualToString:@"false"]) {
			NSString *message = @"Trips cannot be deleted when they have Blogs, Photos or Videos in them";
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:[NSString stringWithFormat:@"Error Deleting from %@", [NSString partnerDisplayName]]
									  message:message
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
			[charAlert show];
			
		}
		else {
			[self.trips deleteTrip:deleteingTrip];
			deleteingTrip = nil;
			[self.table reloadData];
			[[GANTracker sharedTracker] trackPageview:@"/home/trips/" withError:nil];
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
	else {
		Trip *trip = [[Trip alloc] initFromDictionary:results[@"response"][@"trips"][@"trip"][0]];
		[self.trips insertTrip:trip];
		[self.table reloadData];
		[[GANTracker sharedTracker] trackPageview:@"/home/trips/" withError:nil];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	
	[HUD hide:YES];
	
	NSString *message = [error localizedDescription];
	
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:[NSString stringWithFormat:@"Error Sending to %@", [NSString partnerDisplayName]]
							  message:message
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
}

#pragma mark MBProgressHUD Delegate Method 
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
	HUD.delegate = nil;
    [HUD removeFromSuperview];
	HUD = nil;
}

@end
