//
//  AlbumsTableViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "AlbumsTableViewController.h"
#import "BlogLocationTableViewCell.h"
#import "LocalImagePickerViewController.h"
#import "User.h"
#import "Album.h"
#import "AlbumTableViewController.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark AlbumsTableViewController Private Interface
/**
	@brief Private methods used to download remote Off Exploring API list of albums.
 
	This interface provides a private method used to download the list of albums a user has, for a perticular trip
	from the Off Exploring API. The request is made to /user/_username_/trip/_tripslug_/album.  
 */
@interface AlbumsTableViewController()
#pragma mark Private Method Declarations

/**
	Downloads the list of albums a user has from the Off Exploring API. Registers iself as a lister for a completed
	parsing notification
 */
- (void)beginLoadingAlbums;

@property (nonatomic, assign) BOOL downloadedData;

@end

#pragma mark -
#pragma mark AlbumsTableViewController Implementation

@implementation AlbumsTableViewController

@synthesize tableView;
@synthesize activeTrip;
@synthesize addButton;
@synthesize downloadedData;

#pragma mark UIViewController Methods

- (void)dealloc {
	NSMutableArray *delegates = activeDownloads[@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
	connex.delegate = nil;
}


/**
	Designated initialisor, overridden to setup objects to maintain pointers to ImageLoader delegates
	@param nibNameOrNil The nib to load
	@param nibBundleOrNil The bundle to load
	@returns The AlbumsTableViewController object
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        activeDownloads = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
	Additional setup after loading the view. Downloads the list of a users albums
 */
- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = addButton;
	if ([activeTrip.albums.albums count] <= 0) {
		self.downloadedData = NO;
		[self beginLoadingAlbums];
	}	
}

- (void)viewWillAppear:(BOOL)animated {
	[activeDownloads removeAllObjects];
	NSMutableArray *delegates = [[NSMutableArray alloc] init];
	activeDownloads[@"delegates"] = delegates;
	[self.tableView reloadData];
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
	self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark IBActions

- (IBAction)addAlbum {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/add/" withError:nil];
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/edit/" withError:nil];
	AlbumTableViewController *albumView = [[AlbumTableViewController alloc] initWithNibName:nil bundle:nil];
	Album *album = [[Album alloc] init];
	album.trip = @{@"name": activeTrip.name, @"urlSlug": activeTrip.urlSlug};
	
	albumView.activeAlbum = album;
	albumView.delegate = self;
	
    
	[self presentViewController:albumView animated:YES completion:nil];
	
}

#pragma mark Private Method

- (void)beginLoadingAlbums {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsDataDidLoad:) name:@"albumsDataDidLoad" object:nil];
	connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	User *user = [User sharedUser];
	NSString *url = [connex buildOffexRequestStringWithURI:[[[[@"user/" stringByAppendingString:user.username] stringByAppendingString:@"/trip/"] stringByAppendingString:activeTrip.urlSlug] stringByAppendingString:@"/album"]];
	[connex beginLoadingOffexploringDataFromURL:url];
}

#pragma mark OffexploringConnection Delegate Methods

/**
	Sends the album list data off to the trip object to parse and store the list of albums
	@param offex The OffexConnex object used to load the data
	@param results The results from teh query
 */
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	connex = nil;
	[self.activeTrip setAlbumsDataFromArray:results[@"response"][@"albums"][@"album"]];
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	connex = nil;
	[self.activeTrip setAlbumsDataFromArray:nil];
}

#pragma mark Notification Listener

/**
	Upon album parsing complete, system fires an albumsDataDidLoad notification, which is picked up here 
	to signal a table redraw with the new array of ablums
	@param notification The notification object
 */
- (void)albumsDataDidLoad:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"albumsDataDidLoad" object:nil];
	self.downloadedData = YES;
	[self.tableView reloadData];
}

#pragma mark UITableView Delegate and UITableView Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if ([self.activeTrip.albums.albums count] > 0) {
		return [self.activeTrip.albums.albums count];
	}
	else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.activeTrip.albums.albums count] > 0) {
		BlogLocationTableViewCell *cell = (BlogLocationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogLocationTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogLocationTableViewCell class]]) {
					cell = (BlogLocationTableViewCell *)currentObject;
				}
			}
		}
		
		Album *album = (self.activeTrip.albums.albums)[indexPath.row];
		
		NSString *pngPath = [album getThumbImageFilePath];
		
		cell.title.text = album.name;
		cell.contentCount.text = [NSString stringWithFormat:@"(%d)", album.photoCount];
		cell.coverImage.image = [UIImage imageWithContentsOfFile:pngPath];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		return cell;
	}
	else if (self.downloadedData == YES) {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
														reuseIdentifier:nil];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		cell.imageView.image = [UIImage imageNamed:@"exclamation.png"];
		cell.textLabel.text = @"No Albums Yet!";
		cell.detailTextLabel.text = @"You do not have any Albums yet.";
		
		return cell;
	}
	else {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
														reuseIdentifier:nil];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activity startAnimating];
		activity.frame = CGRectMake(19, 20, 20, 20);
		[cell.contentView addSubview:activity];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(52, 20, 100, 20)];
		label.text = @"Loading...";
		label.textColor = [UIColor colorWithRed: 64/255.0 green: 64/255.0 blue: 64/255.0 alpha:1.0];
		label.font = [UIFont boldSystemFontOfSize: 16.0];
		[cell.contentView addSubview:label];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.activeTrip.albums.albums count] > 0) {
		BlogLocationTableViewCell *theCell = (BlogLocationTableViewCell *)cell;
		
		if (theCell.coverImage.image == nil) {	
			theCell.coverImage.image = [UIImage imageNamed:@"placeholder.png"];
			Album *album = (self.activeTrip.albums.albums)[indexPath.row];
			NSString *remotePath = [album getThumbImageFullRemotePath];
			
			if (activeDownloads[remotePath] == nil && self.tableView.dragging == NO && self.tableView.decelerating == NO) {
				activeDownloads[remotePath] = indexPath;
				ImageLoader *imageLoader = [[ImageLoader alloc] init];
				imageLoader.delegate = self;
				NSMutableArray *dels = activeDownloads[@"delegates"];
				[dels addObject:imageLoader];
				[imageLoader startDownloadForURL:remotePath];
			}
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.activeTrip.albums.albums count] > 0) {
		[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/photos/" withError:nil];
		LocalImagePickerViewController *imagePicker = [[LocalImagePickerViewController alloc] initWithNibName:nil bundle:nil];
		Album *album = (self.activeTrip.albums.albums)[indexPath.row];
		imagePicker.activeAlbum = album;
		imagePicker.title = album.name;
		[self.navigationController pushViewController:imagePicker animated:YES];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/album/edit/" withError:nil];
	AlbumTableViewController *albumView = [[AlbumTableViewController alloc] initWithNibName:nil bundle:nil];
	Album *album = (self.activeTrip.albums.albums)[indexPath.row];
	
	albumView.activeAlbum = album;
	albumView.delegate = self;
	
	[self presentViewController:albumView animated:YES completion:nil];
	
}

#pragma mark Image Loading 

- (void)loadImagesForOnscreenRows
{
    if ([self.activeTrip.albums.albums count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
			Album *album = (self.activeTrip.albums.albums)[indexPath.row];
			NSString *pngPath = [album getThumbImageFilePath];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:pngPath] == NO) {
				
				NSString *remotePath = [album getThumbImageFullRemotePath];
				
				if (activeDownloads[remotePath] == nil) {
					activeDownloads[remotePath] = indexPath;
					ImageLoader *imageLoader = [[ImageLoader alloc] init];
					imageLoader.delegate = self;
					NSMutableArray *dels = activeDownloads[@"delegates"];
					[dels addObject:imageLoader];
					[imageLoader startDownloadForURL:remotePath];
				}
			}
        }
    }
}

#pragma mark ImageLoader Delegate Method

- (void)imageLoader:(ImageLoader *)loader didLoadImage:(UIImage *)image forURI:(NSString *)uri {
	loader.delegate = nil;
	NSMutableArray *delegates = activeDownloads[@"delegates"];
	int count = 0;
	for (ImageLoader *obj in delegates) {
		if ([loader isEqual:obj]) {
			[delegates removeObjectAtIndex:count];
			delegates = nil;
			break;
		}
		count = count +1;
	}
	
	NSIndexPath *indexPath = activeDownloads[uri];
	Album *album = (self.activeTrip.albums.albums)[indexPath.row];
	
	BlogLocationTableViewCell *cell = (BlogLocationTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	
	if (![uri isEqualToString:@"/journal/images/placeholder.png"]) {
		NSString *pngPath = [album getThumbImageFilePath];
		[UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
		cell.coverImage.image = [UIImage imageWithContentsOfFile:pngPath];
	}
	else {
		cell.coverImage.image = image;
	}
}

#pragma mark UIScrollView Delegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark AlbumTableViewController Delegate Methods

- (void)albumTableViewControllerDidCancel:(AlbumTableViewController *)atvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)albumTableViewController:(AlbumTableViewController *)atvc didEditAlbum:(Album *)album {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/" withError:nil];
	[self.activeTrip.albums insertAlbum:album];
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)albumTableViewController:(AlbumTableViewController *)atvc didDeleteAlbum:(Album *)album {
	[[GANTracker sharedTracker] trackPageview:@"/home/albums/" withError:nil];
	[self.activeTrip.albums deleteAlbum:album];
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)titleForAlbumTableViewController:(AlbumTableViewController *)atvc editingAlbum:(Album *)album {
	if (album.albumID != nil) {
		return @"Edit Album";
	}
	else {
		return @"Add Album";
	}
}

- (BOOL)deleteButtonShouldDisplayForAlbumTalbeViewController:(AlbumTableViewController *)atvc editingAlbum:(Album *)album {
	if (album.albumID != nil) {
		return YES;
	}
	else {
		return NO;
	}
}

@end
