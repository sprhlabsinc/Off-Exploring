//
//  BlogEntriesViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 08/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "BlogEntriesViewController.h"
#import "BlogEntryTableViewCell.h"
#import "Blog.h"
#import "User.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark BlogEntriesViewController Private Interface
/**
 @brief Private store of a recently pressed NSIndexPath that the user wishes to delete
 
 This interface provides a private wrapper to an NSIndexPath that is created and stored when a user uses the swipe to delete
 feature on UITableView.  The store holds the swiped NSIndexPath so taht a user may confirm the action before a Blog is actually
 deleted from Off Exploring.
 */
@interface BlogEntriesViewController()

@property (nonatomic, strong) NSIndexPath *deleteID;

@end

#pragma mark -
#pragma mark BlogEntriesViewController Implementation
@implementation BlogEntriesViewController

@synthesize tableView;
@synthesize activeBlogs;
@synthesize state;
@synthesize area;
@synthesize parentTrip;
@synthesize addButton;
@synthesize allBlogs;
@synthesize deleteID;

#pragma mark UIViewController Methods
- (void)dealloc {
	if (HUD) {
		HUD.delegate = nil;
	}
	if (connex != nil) {
		connex.delegate = nil;
	}
	connex = nil;
	NSArray *delegates = activeDownloads[@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		activeDownloads = [[NSMutableDictionary alloc] init];
		NSMutableArray *delegates = [[NSMutableArray alloc] init];
		activeDownloads[@"delegates"] = delegates;
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = addButton;
	tappedTag = -1;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
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
	[super viewDidUnload];
}

#pragma mark IBActions

- (IBAction)addBlogPressed:(id)sender {
	Blog *newBlog = [[Blog alloc] init];
	newBlog.body = @"Start typing your blog..";
	newBlog.timestamp = [[NSDate date] timeIntervalSince1970];
	newBlog.original_timestamp = [[NSDate date] timeIntervalSince1970];
	newBlog.trip = self.parentTrip;
	newBlog.state = self.state;
	newBlog.area = self.area;
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/add/" withError:nil];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	BlogViewController *addView = [[BlogViewController alloc] initWithNibName:nil bundle:nil];
	addView.blog = newBlog;
	addView.editing = YES;
	addView.delegate = self;
	addView.allBlogs = self.allBlogs;
	[self.navigationController presentViewController:addView animated:YES completion:nil];
}

- (void)draftMenu:(id)sender {
	UIButton *pressedButton = (UIButton *)sender;
	tappedTag = pressedButton.tag;
	UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:@"Would you like to publish or edit this draft?"
														 delegate:self
												cancelButtonTitle:@"Cancel"
										   destructiveButtonTitle:nil
												otherButtonTitles:@"Publish", @"Edit", nil];
	[actions showInView:self.view];
		
}

#pragma mark UITableView Delegate and Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([activeBlogs count] == 0) {
		[self.navigationController popViewControllerAnimated:YES];
	}
	return [activeBlogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BlogEntryTableViewCell *cell = (BlogEntryTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
	if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogEntryTableViewCell" owner:nil options:nil];
		for (id currentObject in nibObjects) {
			if ([currentObject isKindOfClass:[BlogEntryTableViewCell class]]) {
				cell = (BlogEntryTableViewCell *)currentObject;
			}
		}
	}
	
	cell.coverImage.image = nil;
    
	for (UIView *aView in cell.contentView.subviews) {
		if ([aView isKindOfClass:[UIButton class]]) {
			[aView removeFromSuperview];
		}
	}
	
	Blog *blog = activeBlogs[indexPath.row];
	
	NSTimeInterval timestamp = blog.timestamp;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
	cell.date.text = [dateFormatter stringFromDate:date];
	if ([[NSFileManager defaultManager] fileExistsAtPath:[blog getThumbImageFilePath]] == YES) {
		cell.coverImage.image = [UIImage imageWithContentsOfFile:[blog getThumbImageFilePath]];
	}
	else if ([[NSFileManager defaultManager] fileExistsAtPath:[blog getImageFilePath]] == YES) {
		cell.coverImage.image = [UIImage imageWithContentsOfFile:[blog getImageFilePath]];
	}
	
	if (blog.draft == YES) {
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(279, 16, 27, 28);
		button.tag = indexPath.row;
		[button setBackgroundImage:[UIImage imageNamed:@"draft.png"] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(draftMenu:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:button];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BlogEntryTableViewCell *theCell = (BlogEntryTableViewCell *)cell;
	if (theCell.coverImage.image == nil) {	
		theCell.coverImage.image = [UIImage imageNamed:@"placeholder.png"];
		Blog *aBlog = activeBlogs[indexPath.row];
		
		if (aBlog.thumbURI != nil) {
			
			NSString *remotePath = [aBlog getThumbImageFullRemotePath];
			
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
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/" withError:nil];
	
	Blog *aBlog = activeBlogs[indexPath.row];
	BlogViewController *blogViewController = [[BlogViewController alloc] initWithNibName:nil bundle:nil];
	blogViewController.blog = aBlog;
	blogViewController.allBlogs = allBlogs;
	blogViewController.title = @"View Blog";
	[self.navigationController pushViewController:blogViewController animated:YES];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Blog *aBlog = activeBlogs[indexPath.row];
	
	if (aBlog.draft == YES) {
		[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/delete/draft/" withError:nil];
		[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/" withError:nil];
		[self.allBlogs deleteBlog:aBlog];
		NSArray *indexPaths = @[indexPath];
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
	}
	else {
		[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/delete/" withError:nil];
		[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/" withError:nil];
		User *user = [User sharedUser];
		connex = [[OffexConnex alloc] init];
		connex.delegate = self;
		NSString *url = [connex buildOffexRequestStringWithURI:[[[[[@"user/" stringByAppendingString:user.username] 
																   stringByAppendingString:@"/trip/"] 
																  stringByAppendingString:(aBlog.trip)[@"urlSlug"]] 
																 stringByAppendingString:@"/blog/"] 
																stringByAppendingString:aBlog.blogid]];
		[connex deleteOffexploringDataAtUrl:url];
		self.deleteID = indexPath;
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Deleting...";
		[HUD show:YES];
	}
}

#pragma mark UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (tappedTag != -1 && buttonIndex != 2) {
		Blog *aBlog = activeBlogs[tappedTag];
		[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
		BlogViewController *editView = [[BlogViewController alloc] initWithNibName:nil bundle:nil];
		editView.blog = aBlog;
		editView.allBlogs = allBlogs;
		editView.editing = YES;
		editView.delegate = self;
		if (buttonIndex == 0) {
			editView.autoPost = YES;
		}
		[self.navigationController presentViewController:editView animated:YES completion:nil];
	}
	tappedTag = -1;
}

#pragma mark OffexploringConnection Delegate Methods

- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	if ([results[@"request"][@"method"] isEqualToString:@"DELETE"]) {
		[HUD hide:YES];
		Blog *aBlog = activeBlogs[deleteID.row];
		if ([results[@"response"][@"success"] isEqualToString:@"true"]){
			[self.allBlogs deleteBlog:aBlog];
			NSArray *indexPaths = @[deleteID];
			[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
		}
		else {
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:[NSString stringWithFormat:@"%@ Error", [NSString partnerDisplayName]]
									  message:[NSString stringWithFormat:@"An error has occured deleting from %@. Please retry.", [NSString partnerDisplayName]]
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
			[charAlert show];
			
		}
	}
	connex = nil;
}

#pragma mark ImageLoader Methods

- (void)loadImagesForOnscreenRows
{
    if ([self.activeBlogs count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
			Blog *aBlog = activeBlogs[indexPath.row];
			
			if (aBlog.thumbURI != nil) {
                
				NSString *pngPath = [aBlog getThumbImageFilePath];
				
				if ([[NSFileManager defaultManager] fileExistsAtPath:pngPath] == NO) {
					
					NSString *remotePath = [aBlog getThumbImageFullRemotePath];
					
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
}

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
	
	count = 0;
	for (Blog *aBlog in activeBlogs) {
		if ([aBlog.thumbURI isEqualToString:uri]){
			NSString *pngPath = [aBlog getThumbImageFilePath];
			[UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
			BlogEntryTableViewCell *cell = (BlogEntryTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			cell.coverImage.image = image;
		}
		count++;
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

#pragma mark BlogViewController Delegate Methods

- (void)blogViewController:(BlogViewController *)bvc didFinishEditingBlog:(Blog *)blog {
	[self.allBlogs addBlog:blog];
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blogViewControllerDidDiscardChanges:(BlogViewController *)bvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blogViewControllerDidDeleteBlog:(BlogViewController *)bvc {
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MBProgressHUD Delegate Method 

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}
@end
