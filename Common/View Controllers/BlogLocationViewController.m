//
//  BlogLocationViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 12/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "BlogLocationViewController.h"
#import "User.h"
#import "BlogEntriesViewController.h"
#import "BlogLocationTableViewCell.h"
#import "BlogViewController.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark BlogLocationViewController Private Interface
/**
	@brief Private methods to download the list of blogs and restore an autosaved blog from NSUserDefaults
 
	This interface provides private methods used to download the list of blogs from Off Exploring, as well as to restore an
	auto saved Blog from NSUserDefaults and display it to the user.
 */
@interface BlogLocationViewController()
#pragma mark Private Method Declarations
/**
	Begins downloading the list of blogs belonging to a user for the activeTrip
 */
- (void)beginLoadingBlogs;
/**
	Restores and displays an auto-saved Blog object from NSUserDefaults
 */
- (void)reloadAutoSave;

@property (nonatomic, assign) BOOL downloadedData;

@end

#pragma mark -
#pragma mark BlogLocationViewController Implementation

@implementation BlogLocationViewController

@synthesize tableView;
@synthesize activeTrip;
@synthesize addBlog;
@synthesize downloadedData;

#pragma mark UIViewController Methods

- (void)dealloc {
	NSMutableArray *delegates = activeDownloads[@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
	connex.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		activeDownloads = [[NSMutableDictionary alloc] init];
		NSMutableArray *delegates = [[NSMutableArray alloc] init];
		activeDownloads[@"delegates"] = delegates;
		self.downloadedData = NO;
	}  
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	User *user = [User sharedUser];
	if ([activeTrip.blogs.states count] <= 0 && user.globalDraft == NO) {
		self.downloadedData = NO;
		[self beginLoadingBlogs];
	}
	else if (user.globalDraft == YES) {
		NSDictionary *autoSavedBlog = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoSavedBlog"];
		if (autoSavedBlog != nil) {
			[self reloadAutoSave];
		}
		self.downloadedData = YES;
		[self.activeTrip.blogs reloadTemp];
		[self.tableView reloadData];
	}
	self.navigationItem.rightBarButtonItem = addBlog;
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
	self.addBlog = nil;
	self.tableView = nil;
	sectionIndexTitles = nil;
	[super viewDidUnload];
}

#pragma mark IBActions

- (IBAction)addBlogPressed:(id)sender {
	Blog *newBlog = [[Blog alloc] init];
	newBlog.body = @"Start typing your blog..";
	newBlog.timestamp = [[NSDate date] timeIntervalSince1970];
	newBlog.original_timestamp = [[NSDate date] timeIntervalSince1970];
	NSDictionary *parentTrip = @{@"name": activeTrip.name, @"urlSlug": activeTrip.urlSlug};
	newBlog.trip = parentTrip;
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/add/" withError:nil];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	BlogViewController *addView = [[BlogViewController alloc] initWithNibName:nil bundle:nil];
	addView.blog = newBlog;
	addView.editing = YES;
	addView.delegate = self;
	addView.allBlogs = activeTrip.blogs;
	[self presentViewController:addView animated:YES completion:nil];
}

#pragma mark Private Methods

- (void)beginLoadingBlogs {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blogsDataDidLoad:) name:@"blogsDataDidLoad" object:nil];
	User *user = [User sharedUser];
	connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	NSString *url = [connex buildOffexRequestStringWithURI:[[[[@"user/" stringByAppendingString:user.username] stringByAppendingString:@"/trip/"] stringByAppendingString:activeTrip.urlSlug] stringByAppendingString:@"/blog"]];
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)reloadAutoSave {
	BlogViewController *addView = [[BlogViewController alloc] initWithNibName:nil bundle:nil];
	addView.editing = YES;
	addView.delegate = self;
	addView.allBlogs = activeTrip.blogs;
	addView.tempTrip = @{@"name": activeTrip.name, @"urlSlug": activeTrip.urlSlug};
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self.navigationController presentViewController:addView animated:YES completion:nil];
}

#pragma mark Offexploring Connection Delegate Methods

- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	connex = nil;
	[self.activeTrip setBlogsDataFromArray:results[@"response"][@"blogs"][@"states"][@"state"]];
}

- (void)blogsDataDidLoad:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"blogsDataDidLoad" object:nil];
	NSDictionary *autoSavedBlog = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoSavedBlog"];
	if (autoSavedBlog != nil) {
		[self reloadAutoSave];
	}
	self.downloadedData = YES;
	[self.activeTrip.blogs reloadTemp];
	if ([activeTrip.blogs.states count] >= 12) {
		NSMutableSet *setOfSectionIndexTitles = [[NSMutableSet alloc] init];
		
		NSDictionary *aState;
		
		for (aState in activeTrip.blogs.states) {
			NSString *indexTitle = aState[@"name"];
			NSString *firstLetter = [indexTitle substringToIndex:1]; 
			[setOfSectionIndexTitles addObject:firstLetter];
		}
		NSArray *unsortedTitles = [[NSArray alloc] initWithArray:[setOfSectionIndexTitles allObjects]];
		sectionIndexTitles = [unsortedTitles sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	}
	[self.tableView reloadData];
}

#pragma mark UITableView Delegate And Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([activeTrip.blogs.states count] > 0) {
		return [activeTrip.blogs.states count];
	}
	else  {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if ([activeTrip.blogs.states count] > 0) {
		NSDictionary *state = (activeTrip.blogs.states)[section];
		NSArray *areas = state[@"areas"];
		return [areas count];
	}
	else {
		return 1;
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSDictionary *aState;
	int arrayindex = 0;
	for (aState in activeTrip.blogs.states) {
		NSString *indexTitle = aState[@"name"];
		NSString *firstLetter = [indexTitle substringToIndex:1]; 
		if ([firstLetter isEqualToString:title]) {
			return arrayindex;
		}
		arrayindex = arrayindex +1;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 22.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if ([activeTrip.blogs.states count] > 0) {
		NSDictionary *state = (activeTrip.blogs.states)[section];	
		UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 22.0)];
		header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"divider.png"]];
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, 300, 20)];
		headerLabel.text = state[@"name"];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.font = [UIFont boldSystemFontOfSize: 13];
		headerLabel.textColor = [UIColor headerLabelTextColorPlainStyle];
		headerLabel.shadowColor = [UIColor headerLabelShadowColorPlainStyle];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		[header addSubview: headerLabel];
		return header;
	}
	else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([activeTrip.blogs.states count] > 0) {
	
		BlogLocationTableViewCell *cell = (BlogLocationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogLocationTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogLocationTableViewCell class]]) {
					cell = (BlogLocationTableViewCell *)currentObject;
				}
			}
		}
		cell.coverImage.image = nil;
		for (UIView *aView in cell.contentView.subviews) {
			if ([aView isKindOfClass:[UIButton class]]) {
				[aView removeFromSuperview];
			}
		}
		
		NSDictionary *state = (activeTrip.blogs.states)[indexPath.section];
		NSArray *areas = state[@"areas"];
		NSDictionary *area = areas[indexPath.row];
		Blog *aBlog = area[@"blogs"][0];
		
		cell.title.text = area[@"area"][@"name"];
		cell.contentCount.text = [NSString stringWithFormat:@"(%d)",[area[@"blogs"] count]];
		
		BOOL hasDraft = NO;
		for (Blog *checkBlog in area[@"blogs"]) {
			if (checkBlog.draft == YES) {
				hasDraft = YES;
			}
		}
		
		if (hasDraft == YES) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			if ([activeTrip.blogs.states count] >= 12) {
				button.frame = CGRectMake(220, 16, 27, 28);
			}
			else {
				button.frame = CGRectMake(248, 16, 27, 28);
			}
			[button setBackgroundImage:[UIImage imageNamed:@"draft.png"] forState:UIControlStateNormal];
			[cell.contentView addSubview:button];
		}
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[aBlog getThumbImageFilePath]] == YES) {
			cell.coverImage.image = [UIImage imageWithContentsOfFile:[aBlog getThumbImageFilePath]];
		}
		else if ([[NSFileManager defaultManager] fileExistsAtPath:[aBlog getImageFilePath]] == YES) {
			cell.coverImage.image = [UIImage imageWithContentsOfFile:[aBlog getImageFilePath]];
		}
		
		return cell;
	}
	else if (self.downloadedData == YES) {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
														reuseIdentifier:nil];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		cell.imageView.image = [UIImage imageNamed:@"exclamation.png"];
		cell.textLabel.text = @"No Posts Yet!";
		
		User *user = [User sharedUser];
		if (user.globalDraft == YES) {
			cell.detailTextLabel.text = @"You don't have any saved blog drafts";
		}
		else {
			cell.detailTextLabel.text = @"You do not have any blog posts yet.";
		}
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
	if ([activeTrip.blogs.states count] > 0) {
		BlogLocationTableViewCell *theCell = (BlogLocationTableViewCell *)cell;
		
		if (theCell.coverImage.image == nil) {	
			theCell.coverImage.image = [UIImage imageNamed:@"placeholder.png"];
			
			NSDictionary *state = (activeTrip.blogs.states)[indexPath.section];
			NSArray *areas = state[@"areas"];
			NSDictionary *area = areas[indexPath.row];
			Blog *aBlog = area[@"blogs"][0];
			
			if (aBlog.thumbURI != nil) {
				
				NSString *remotePath = [aBlog getThumbImageFullRemotePath];
				
				if (activeDownloads[remotePath] == nil && self.tableView.dragging == NO && self.tableView.decelerating == NO) {
					activeDownloads[remotePath] = indexPath;
					ImageLoader *imageLoader = [[ImageLoader alloc] init];
					NSMutableArray *dels = activeDownloads[@"delegates"];
					[dels addObject:imageLoader];
					imageLoader.delegate = self;
					[imageLoader startDownloadForURL:remotePath];
				}
			}
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([activeTrip.blogs.states count] > 0) {
	
		NSArray *listOfAreas = (activeTrip.blogs.states)[indexPath.section][@"areas"];
		NSMutableArray *listOfBlogs = listOfAreas[indexPath.row][@"blogs"];
		
		NSDictionary *state = @{@"name": (activeTrip.blogs.states)[indexPath.section][@"name"],@"slug": (activeTrip.blogs.states)[indexPath.section][@"urlSlug"]};
		NSDictionary *area =  @{@"name": listOfAreas[indexPath.row][@"area"][@"name"], @"urlSlug": listOfAreas[indexPath.row][@"area"][@"urlSlug"]};
		
		[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/" withError:nil];
		BlogEntriesViewController *entryView = [[BlogEntriesViewController alloc] initWithNibName:nil bundle:nil];
		entryView.title = area[@"name"];
		entryView.activeBlogs = listOfBlogs;
		entryView.state = state;
		entryView.area = area;
		entryView.allBlogs = activeTrip.blogs;
		entryView.parentTrip = @{@"name": activeTrip.name, @"urlSlug": activeTrip.urlSlug};
		
		[self.navigationController pushViewController:entryView animated:YES];
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark ImageLoader Methods

- (void)loadImagesForOnscreenRows
{
    if ([self.activeTrip.blogs.states count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
			NSDictionary *state = (activeTrip.blogs.states)[indexPath.section];
			NSArray *areas = state[@"areas"];
			NSDictionary *area = areas[indexPath.row];
			Blog *aBlog = area[@"blogs"][0];
			
			if (aBlog.thumbURI != nil) {
			
				NSString *pngPath = [aBlog getThumbImageFilePath];
				
				if ([[NSFileManager defaultManager] fileExistsAtPath:pngPath] == NO) {
					
					NSString *remotePath = [aBlog getThumbImageFullRemotePath];
					
					if (activeDownloads[remotePath] == nil) {
						activeDownloads[remotePath] = indexPath;
						ImageLoader *imageLoader = [[ImageLoader alloc] init];
						NSMutableArray *dels = activeDownloads[@"delegates"];
						[dels addObject:imageLoader];
						imageLoader.delegate = self;
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
	
	NSIndexPath *indexPath = activeDownloads[uri];
	NSDictionary *state = (activeTrip.blogs.states)[indexPath.section];
	NSArray *areas = state[@"areas"];
	NSDictionary *area = areas[indexPath.row];
	Blog *aBlog = area[@"blogs"][0];
	
	NSString *pngPath = [aBlog getThumbImageFilePath];
	[UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
	
	BlogLocationTableViewCell *cell = (BlogLocationTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	cell.coverImage.image = [UIImage imageWithContentsOfFile:pngPath];
}

#pragma mark UIScrollView Delegate Methods 
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && self.tableView != nil)
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
	[self.activeTrip.blogs addBlog:blog];
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blogViewControllerDidDiscardChanges:(BlogViewController *)bvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blogViewControllerDidDeleteBlog:(BlogViewController *)bvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/" withError:nil];
	[self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
