//
//  HostelListViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 13/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelListViewController.h"
#import "DB.h"
#import "Hostels.h"
#import "Hostel.h"
#import "HostelTableViewCell.h"
#import "User.h"
#import "HostelViewController.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark HostelListViewController Implementation
@implementation HostelListViewController

@synthesize hostels;
@synthesize tableView;
@synthesize parentTabController;

#pragma mark UIViewController Methods
- (void)dealloc {
	
	[activeDownloads release];
	[hostelImages release];
	[hostels release];
	[tableView release];
    [super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	downloadingHostels = NO;
	
	if (!activeDownloads) {
		activeDownloads = [[NSMutableDictionary alloc] init];
		NSMutableArray *delegates = [[NSMutableArray alloc] init];
		[activeDownloads setObject:delegates forKey:@"delegates"];
		[delegates release];
	}
	
	self.hostels = [Hostels loadHostelsFromDBorderedBy:HOSTELS_ORDER_DEFAULT];
	
	hostelImages = [[NSMutableDictionary alloc] initWithCapacity:[self.hostels count]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.hostels = nil;
	[hostelImages release];
	NSMutableArray *delegates = [activeDownloads objectForKey:@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
	[activeDownloads release];
	activeDownloads = nil;
	hostelImages = nil;
}

#pragma mark TableView Reload
- (void)reloadView {
	NSMutableArray *delegates = [activeDownloads objectForKey:@"delegates"];
	for (ImageLoader *obj in delegates) {
		obj.delegate = nil;
	}
	[hostelImages release];
	[activeDownloads release];
	
	activeDownloads = [[NSMutableDictionary alloc] init];
	delegates = [[NSMutableArray alloc] init];
	[activeDownloads setObject:delegates forKey:@"delegates"];
	[delegates release];
	
	self.hostels = [Hostels loadHostelsFromDBorderedBy:HOSTELS_ORDER_DEFAULT];
	
	hostelImages = [[NSMutableDictionary alloc] initWithCapacity:[self.hostels count]];
	
	[self.tableView reloadData];
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *lastHostelLookup = [[prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]] retain];
	double currentDistance = [[lastHostelLookup objectForKey:@"range"] doubleValue];
	[lastHostelLookup release];
	if (currentDistance < 20) {
		return [hostels count] + 1;
	}
	else {
		return [hostels count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"hostelCell";
	
	if ([hostels count] == indexPath.row) {
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadingCell"];
		}
		
		for (UIView *aView in cell.contentView.subviews) {
			[aView removeFromSuperview];
		}
		
		if (downloadingHostels) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[activity startAnimating];
			activity.frame = CGRectMake(19, 20, 20, 20);
			[cell.contentView addSubview:activity];
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(52, 20, 100, 20)];
			label.text = @"Loading More Hostels...";
			label.textColor = [UIColor colorWithRed: 64/255.0 green: 64/255.0 blue: 64/255.0 alpha:1.0];
			label.font = [UIFont boldSystemFontOfSize: 16.0];
			[cell.contentView addSubview:label];
			cell.textLabel.text = @"";
		}
		else {
			User *user = [User sharedUser];
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			NSDictionary *lastHostelLookup = [[prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]] retain];
			double currentDistance = [[lastHostelLookup objectForKey:@"range"] doubleValue];
			[lastHostelLookup release];
			if (currentDistance < 20) { 
				cell.textLabel.text = @"Find More ....";
			}
			else {
				cell.textLabel.text = @"";
			}
			
			cell.textLabel.textColor = [UIColor lightGrayColor];
		}
		return cell;
	}
	else {
		
		HostelTableViewCell *cell = (HostelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[HostelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.frame = CGRectMake(0.0, 0.0, 320.0, 60);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	
		Hostel *hostel = [self.hostels objectAtIndex:indexPath.row];
		
		if (![hostelImages objectForKey:hostel.name]) {
			[cell setHostelImage:nil];
			NSArray *thumbURIs = [hostel loadImages:YES];
			NSString *remotePath = nil;
			if ([thumbURIs count] > 0) {
				remotePath = [thumbURIs objectAtIndex:0];
			}
			else {
				thumbURIs = [hostel loadImages:NO];
				if ([thumbURIs count] > 0) {
					remotePath = [thumbURIs objectAtIndex:0];
				}
			}
			
			if (remotePath) {
				if ([activeDownloads objectForKey:remotePath] == nil && self.tableView.dragging == NO && self.tableView.decelerating == NO) {
					[activeDownloads setObject:indexPath forKey:remotePath];
					ImageLoader *imageLoader = [[ImageLoader alloc] init];
					NSMutableArray *dels = [activeDownloads objectForKey:@"delegates"];
					[dels addObject:imageLoader];
					imageLoader.delegate = self;
					imageLoader.foreign = YES;
					[imageLoader startDownloadForURL:remotePath];
					[imageLoader release];
				}
			}
			else {
				[hostelImages setObject:[UIImage imageNamed:@"notfoundimage.png"] forKey:hostel.name];
				[cell setHostelImage:[hostelImages objectForKey:hostel.name]];
			}
		}
		else {
			[cell setHostelImage:[hostelImages objectForKey:hostel.name]];
		}
		
		[cell setHostel:hostel];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([hostels count] == indexPath.row) {
		User *user = [User sharedUser];
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		NSDictionary *lastHostelLookup = [[prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]] retain];
		double currentDistance = [[lastHostelLookup objectForKey:@"range"] doubleValue];
		
		if ([[lastHostelLookup objectForKey:@"resultCount"] intValue] == 5) {
			hostelLoad = [[Hostels alloc] init];
			hostelLoad.delegate = self;
			
			int page = [[lastHostelLookup objectForKey:@"page"] intValue];
			page = page +1;
			
			[hostelLoad loadHostelsForArea:[lastHostelLookup objectForKey:@"area"] country:[lastHostelLookup objectForKey:@"country"] latitide:[NSNumber numberWithDouble:[[[lastHostelLookup objectForKey:@"determinedDestination"] objectForKey:@"latitude"] doubleValue]] longitude:[NSNumber numberWithDouble:[[[lastHostelLookup objectForKey:@"determinedDestination"] objectForKey:@"longitude"] doubleValue]] within:[NSNumber numberWithDouble:currentDistance] page:[NSNumber numberWithInt:page] orderedBy:[NSNumber numberWithInt:HOSTELS_ORDER_DEFAULT]];
			downloadingHostels = YES;
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[activity startAnimating];
			activity.frame = CGRectMake(19, 20, 20, 20);
			[cell.contentView addSubview:activity];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(52, 20, 100, 20)];
			label.text = @"Loading More Hostels...";
			label.textColor = [UIColor colorWithRed: 64/255.0 green: 64/255.0 blue: 64/255.0 alpha:1.0];
			label.font = [UIFont boldSystemFontOfSize: 16.0];
			[cell.contentView addSubview:label];
			
			cell.textLabel.text = @"";
			
			[cell setNeedsDisplay];
		
		}
		else if (currentDistance < 20) {
			currentDistance = currentDistance *2;
			hostelLoad = [[Hostels alloc] init];
			hostelLoad.delegate = self;
			[hostelLoad loadHostelsForArea:[lastHostelLookup objectForKey:@"area"] country:[lastHostelLookup objectForKey:@"country"] latitide:[NSNumber numberWithDouble:[[[lastHostelLookup objectForKey:@"determinedDestination"] objectForKey:@"latitude"] doubleValue]] longitude:[NSNumber numberWithDouble:[[[lastHostelLookup objectForKey:@"determinedDestination"] objectForKey:@"longitude"] doubleValue]] within:[NSNumber numberWithDouble:currentDistance] page:[lastHostelLookup objectForKey:@"page"] orderedBy:[NSNumber numberWithInt:HOSTELS_ORDER_DEFAULT]];
			
			
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[activity startAnimating];
			activity.frame = CGRectMake(19, 20, 20, 20);
			[cell.contentView addSubview:activity];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(52, 20, 100, 20)];
			label.text = @"Loading More Hostels...";
			label.textColor = [UIColor colorWithRed: 64/255.0 green: 64/255.0 blue: 64/255.0 alpha:1.0];
			label.font = [UIFont boldSystemFontOfSize: 16.0];
			[cell.contentView addSubview:label];
			
			cell.textLabel.text = @"";
			
			[cell setNeedsDisplay];
		}
		else {
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"No More Hostels"
									  message:@"There are no more hostels near this location!"
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
			[charAlert show];
			
		}
		
		
		[lastHostelLookup release];
	}
	else {
		Hostel *hostel = [self.hostels objectAtIndex:indexPath.row];
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/" withError:nil];
		HostelViewController *hostelView = [[HostelViewController alloc] initWithNibName:nil bundle:nil];
		hostelView.hostel = hostel;
		hostelView.delegate = self;
		hostelView.rootNav = self.parentTabController.rootNav;
		[self.parentTabController presentViewController:hostelView animated:YES completion:nil];
		[hostelView release];
	}
}

#pragma mark ImageLoader Methods
- (void)imageLoader:(ImageLoader *)loader didLoadImage:(UIImage *)image forURI:(NSString *)uri {
	
	loader.delegate = nil;
	NSMutableArray *delegates = [activeDownloads objectForKey:@"delegates"];
	int count = 0;
	for (ImageLoader *obj in delegates) {
		if ([loader isEqual:obj]) {
			[delegates removeObjectAtIndex:count];
			delegates = nil;
			break;
		}
		count = count +1;
	}
	
	NSIndexPath *indexPath = [activeDownloads objectForKey:uri];
	
	Hostel *hostel = [self.hostels objectAtIndex:indexPath.row];
	[hostelImages setObject:image forKey:hostel.name];
	
	HostelTableViewCell *cell = (HostelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell setHostelImage:image];
}

- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths)
	{
		if ([hostels count] != indexPath.row) {
			Hostel *hostel = [self.hostels objectAtIndex:indexPath.row];
			
			if (![hostelImages objectForKey:hostel.name]) {
				NSArray *thumbURIs = [hostel loadImages:YES];
				
				if ([thumbURIs count] > 0) {
					
					NSString *remotePath = [thumbURIs objectAtIndex:0];
					
					if (remotePath != nil) {
						
						if ([activeDownloads objectForKey:remotePath] == nil) {
							[activeDownloads setObject:indexPath forKey:remotePath];
							ImageLoader *imageLoader = [[ImageLoader alloc] init];
							NSMutableArray *dels = [activeDownloads objectForKey:@"delegates"];
							[dels addObject:imageLoader];
							imageLoader.delegate = self;
							imageLoader.foreign = YES;
							[imageLoader startDownloadForURL:remotePath];
							[imageLoader release];
						}
					}
				}
			}
			else {
				HostelTableViewCell *cell = (HostelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
				[cell setHostelImage:[hostelImages objectForKey:hostel.name]];
			}
		}
	}
    
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

#pragma mark hostelLoader Delegate Methods
- (void)hostelLoader:(Hostels *)hostelLoader didLoadHostelsforCity:(NSString *)city country:(NSString *)country latitude:(double)latitude longitude:(double)longitude range:(double)range page:(int)page {
	[hostelLoad release];
	self.hostels = [Hostels loadHostelsFromDBorderedBy:HOSTELS_ORDER_DEFAULT];
	downloadingHostels = NO;
	[self.tableView reloadData];
}

- (void)hostelLoader:(Hostels *)hostelLoader failedToLoadHostelsforCity:(NSString *)city country:(NSString *)country latitude:(double)latitude longitude:(double)longitude range:(double)range page:(int)page {
	if (range < 20) {
		double currentDistance = range * 2;
		[hostelLoad loadHostelsForArea:city country:country latitide:[NSNumber numberWithDouble:latitude] longitude:[NSNumber numberWithDouble:longitude] within:[NSNumber numberWithDouble:currentDistance]  page:[NSNumber numberWithInt:page] orderedBy:[NSNumber numberWithInt:HOSTELS_ORDER_DEFAULT]];
	}
	else {
		[hostelLoad release];
		downloadingHostels = NO;
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"No More Hostels"
								  message:@"There are no more hostels near this location!"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
}

- (void)noConnectionforHostelLoader:(Hostels *)hostelLoader {
	[hostelLoad release];
	downloadingHostels = NO;
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"Unable to Search For Hostels"
							  message:@"We were unable to connect to Off Exploring to search for hostels. Please try again!"
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
	
}

#pragma mark HostelViewController Delegate Methods
- (void)hostel:(Hostel *)hostel withRoom:(Room *)room wasBookedFor:(NSNumber *)people dismissingHostelViewController:(HostelViewController *)hvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/list/" withError:nil];
	[self dismissViewControllerAnimated:NO completion:nil];
	[self.parentTabController.rootNav hostel:hostel withRoom:room wasBookedFor:people dismissingHostelViewController:hvc];
}

- (void)closeHostelViewController:(HostelViewController *)hvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/list/" withError:nil];
	[hvc dismissViewControllerAnimated:YES completion:nil];
}

@end
