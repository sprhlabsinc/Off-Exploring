//
//  HostelViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 25/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelViewController.h"
#import "StringHelper.h"
#import "User.h"
#import "BlogDetailTableViewCell.h"
#import "BlogHeaderTableViewCell.h"
#import "HostelTabBarViewController.h"
#import "Photo.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "HostelRoomViewController.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark HostelViewController Implementation
@implementation HostelViewController

@synthesize delegate;
@synthesize navBar;
@synthesize tableView;
@synthesize toolBar;
@synthesize backButton;
@synthesize rootNav;
@synthesize hostel;
@synthesize hostelImage;
@synthesize tableViewWrapper;
@synthesize mapViewWrapper;
@synthesize annotations;
@synthesize mapView;

#pragma mark UIViewController Methods
- (void)dealloc {
	for (DDAnnotation *annotation in self.annotations) {
		[self.mapView removeAnnotation:annotation];
	}
	[annotations release];
	mapView.delegate = nil;
	[mapView release];
	[tableViewWrapper release];
	[mapViewWrapper release];
	[hostelImage release];
	[hostel release];
	[navBar release];
	[tableView release];
	[toolBar release];
	[backButton release];
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.annotations = [NSMutableArray arrayWithCapacity:2];
	
	tableView.backgroundColor = [UIColor clearColor];
	
	UINavigationItem *item = [self.navBar.items objectAtIndex:0];
	
	if (![delegate isKindOfClass:[RootViewController class]]) {
		self.backButton.title = @"Back";
	}
	item.leftBarButtonItem = self.backButton;
	
	[self.view addSubview:self.navBar];
	
	self.tableViewWrapper.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	
	CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:self.hostel.latitude longitude:self.hostel.longitude];
	
	DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:newLocation.coordinate addressDictionary:nil];
	annotation.title = self.hostel.name;
	
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *lastHostelLookup = [[prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]] retain];
	NSString *currencySymbol = [[lastHostelLookup objectForKey:@"currency"] objectForKey:@"symbol"];
	
	if (self.hostel.overall != 0) {
		annotation.subtitle = [NSString stringWithFormat:@"Price - %@%.2f, Rating - %.0f%%", currencySymbol,[[[self.hostel lowestPrice] objectForKey:@"price"] doubleValue], self.hostel.overall];
	}
	else {
		annotation.subtitle = [NSString stringWithFormat:@"Price - %@%.2f", currencySymbol,[[[self.hostel lowestPrice] objectForKey:@"price"] doubleValue]];
	}
	[self.annotations insertObject:annotation atIndex:0];
	[self.mapView addAnnotation:annotation];
	
	[annotation release];
	
	NSDictionary *searchLocation = [lastHostelLookup objectForKey:@"determinedDestination"];
	[lastHostelLookup release];
	if (searchLocation != nil) {
		
		newLocation = [[CLLocation alloc] initWithLatitude:[[searchLocation objectForKey:@"latitude"] doubleValue] longitude:[[searchLocation objectForKey:@"longitude"] doubleValue] ];
		DDAnnotation *searchLocationAnnotation = [[DDAnnotation alloc] initWithCoordinate:newLocation.coordinate addressDictionary:nil];
		searchLocationAnnotation.title = [NSString stringWithFormat:@"Searched For: %@",[searchLocation objectForKey:@"name"]];
		[self.annotations insertObject:searchLocationAnnotation atIndex:1];
		[self.mapView addAnnotation:searchLocationAnnotation];
		[searchLocationAnnotation release];
	}
	
	CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(DDAnnotation* annotation in self.mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:NO];
	
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
	
	self.navBar = nil;
	self.tableView = nil;
	self.toolBar = nil;
	self.backButton = nil;
	self.tableViewWrapper = nil;
	mapView.delegate = nil;
	[mapView release];
	mapView = nil;
	self.mapViewWrapper = nil;
}

#pragma mark IBActions

- (IBAction)home {
	if ([delegate respondsToSelector:@selector(closeHostelViewController:)]) {
		[delegate closeHostelViewController:self];
	}
	else if (self.rootNav) {
		[self.rootNav.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
}

- (IBAction)search {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/search/" withError:nil];
	HostelSearchViewController *hostelSearch = [[HostelSearchViewController alloc] initWithNibName:nil bundle:nil];
	hostelSearch.hostelDelegate = self;
	[self presentViewController:hostelSearch animated:YES completion:nil];
	[hostelSearch release];
}

- (IBAction)segmentSwitch:(id)sender {
	UISegmentedControl *control = (UISegmentedControl *)sender;
	if (control.selectedSegmentIndex == 0) {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/" withError:nil];
		self.tableViewWrapper.hidden = NO;
		self.mapViewWrapper.hidden = YES;
	}
	else {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/map/" withError:nil];
		self.tableViewWrapper.hidden = YES;
		self.mapViewWrapper.hidden = NO;
	}
}

#pragma mark Other Actions

- (void)bookHostel {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/avaialability/" withError:nil];
	HostelAvailabilityViewController *havc = [[HostelAvailabilityViewController alloc] initWithNibName:nil bundle:nil];
	havc.delegate = self;
	havc.hostel = self.hostel;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:havc];
	navController.navigationBar.tintColor = [UIColor colorWithRed:233.0/255.0 green:149.0/255.0 blue:75.0/255.0 alpha:1];
	[self presentViewController:navController animated:YES completion:nil];
	[navController release];
	
	[havc release];
	
}

- (void)showPhoto {
	self.hostel.images = [self.hostel loadImages:NO];
	if ([self.hostel.images count]> 0) {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/photos/" withError:nil];
		HostelPhotoViewController *photoView = [[HostelPhotoViewController alloc] initWithNibName:nil bundle:nil];
		photoView.hostelPhotoDelegate = self;
		[self presentViewController:photoView animated:YES completion:nil];
		[photoView release];
	}
	else {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"No Photos"
								  message:@"Sorry, this hostel has no photos to display"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
}

#pragma mark HostelPhotoViewController Delegate Methods

- (NSArray *)hostelPhotoViewControllerImages:(HostelPhotoViewController *)hpvc {
	return self.hostel.images;
}

- (void)hostelPhotoViewControllerDidFinish:(HostelPhotoViewController *)hpvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MKMapView Delegate Method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	if (annotation == [self.annotations objectAtIndex:0]) {
		DDAnnotationView *annotationView = (DDAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (annotationView == nil) {
			annotationView = [[DDAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
			annotationView.moveAble = NO;
		}
		// Dragging annotation will need _mapView to convert new point to coordinate;
		annotationView.mapView = self.mapView;
		return annotationView;
	}
	else {
		MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
		annotationView.image = [UIImage imageNamed:@"UserPin.png"];
		annotationView.canShowCallout = YES;
		return annotationView;
	}
	
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (section == 1) {
		if (hostel.overall == 0) {
			return 4;
		}
		else {
			return 5;
		}
	}
	else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 81.0;
	}
	else if (indexPath.section == 2) {
		NSString *hostelDescriptionString = [NSString stringWithFormat:@"%@\n\n%@", hostel.shortdescription, hostel.longdescription];
		return [hostelDescriptionString RAD_textHeightForSystemFontOfSize:15.0] + 20.0;
	}
	else {
		return 40.0;
	}
}

// Build the header label for the page
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 2) {
		
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
		headerLabel.text = @"About the Hostel";
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.textColor = [UIColor colorWithRed: 124/255.0 green: 107/255.0 blue: 77/255.0 alpha:1.0];
		headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
		headerLabel.shadowColor = [UIColor whiteColor];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		
		[customView addSubview: headerLabel];
		
		
		return customView;
	}
	else {
		return nil;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 0 || section == 2) {
		
		UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 44.0)];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[btn setBackgroundImage:[UIImage imageNamed:@"greenButton.png"] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(bookHostel) forControlEvents:UIControlEventTouchUpInside];
		[btn setTitle:@"Book Hostel" forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		btn.frame = CGRectMake(10, 25, 300.0, 40.0);
		[customView addSubview: btn];
		
		return customView;
	}
	else {
		return nil;
	}
}

// Set the header hight for the page
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 2) {
		return 40.0;
		
	}
	else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 0 || section == 2) {
		return 80.0;
	}
	else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"generalCell";
	
	if (indexPath.section == 2) {
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		if ([[cell.contentView subviews] count] > 0) {
			UIView *labelToClear = [[cell.contentView subviews] objectAtIndex:0];
			[labelToClear removeFromSuperview];
		}
		NSString *hostelDescriptionString = [NSString stringWithFormat:@"%@\n\n%@", hostel.shortdescription, hostel.longdescription];
		
		UILabel *cellLabel = [hostelDescriptionString RAD_newSizedCellLabelWithSystemFontOfSize:15.0];
		[cell.contentView addSubview:cellLabel];
		
		return cell;
	}
	
	else if (indexPath.section == 1) {
		
		BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogDetailTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogDetailTableViewCell class]]) {
					cell = (BlogDetailTableViewCell *)currentObject;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				}
			}
		}
		
		int rownum = indexPath.row;
		if (self.hostel.overall == 0) {
			rownum = rownum + 1;
		}
		
		if(rownum == 0) {
			cell.label.text = @"Rating";
			cell.detail.text = [NSString stringWithFormat:@"%.0f%%",hostel.overall];
		}
		else if(rownum == 1) {
			cell.label.text = @"Address";
			cell.detail.text = [NSString stringWithFormat:@"%@, %@",hostel.city, hostel.country];
		}
		else if(rownum == 2) {
			cell.label.text = @"Price";
			
			User *user = [User sharedUser];
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			NSDictionary *lastHostelLookup = [[prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]] retain];
			NSString *currencySymbol = [[lastHostelLookup objectForKey:@"currency"] objectForKey:@"symbol"];
			[lastHostelLookup release];
			NSString *lowestPrice = [[hostel lowestPrice] objectForKey:@"price"];
			NSString *pricesFrom = nil;
			if ([[[hostel lowestPrice] objectForKey:@"type"] isEqualToString:@"privateprice"]) {
				pricesFrom = [NSString stringWithFormat:@"Private from %@%@",currencySymbol, lowestPrice];
			}
			else {
				pricesFrom = [NSString stringWithFormat:@"Dorms from %@%@",currencySymbol, lowestPrice];
			}
			
			cell.detail.text = pricesFrom;
		}
		else if(rownum == 3) {
			cell.label.text = @"More Info";
			cell.detail.text = @"";
		}
		else if(rownum == 4) {
			cell.label.text = @"Distance";
			cell.detail.text = [NSString stringWithFormat:@"%.2f Miles", self.hostel.distance];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	else if (indexPath.section == 0) {
		BlogHeaderTableViewCell *cell = (BlogHeaderTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogHeaderTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogHeaderTableViewCell class]]) {
					cell = (BlogHeaderTableViewCell *)currentObject;
				}
			}
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		if (self.hostelImage == nil) {
			[cell.blogThumbButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
			
			NSArray *thumbs = [self.hostel loadImages:YES];
			
			if ([thumbs count] > 0) {
				imageLoader = [[ImageLoader alloc] init];
				imageLoader.delegate = self;
				imageLoader.foreign = YES;
				[imageLoader startDownloadForURL:[thumbs objectAtIndex:0]];
			}
			else {
				NSArray *images = [self.hostel loadImages:NO];
				
				if ([images count] > 0) {
					imageLoader = [[ImageLoader alloc] init];
					imageLoader.delegate = self;
					imageLoader.foreign = YES;
					[imageLoader startDownloadForURL:[images objectAtIndex:0]];
				}
			}
		}
		else {
			[cell.blogThumbButton setBackgroundImage:self.hostelImage forState:UIControlStateNormal];
		}
		
		
		cell.textLabel.text = hostel.name;
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		[self showPhoto];
	}
	else if (indexPath.section == 1) {
		int rownum = indexPath.row;
		if (self.hostel.overall == 0) {
			rownum = rownum + 1;
		}
		
		if(rownum == 0) {
			[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/ratings/" withError:nil];
			HostelRatingViewController *hrvc = [[HostelRatingViewController alloc] initWithNibName:nil bundle:nil];
			hrvc.delegate = self;
			hrvc.hostel = self.hostel;
			[self presentViewController:hrvc animated:YES completion:nil];
			[hrvc release];
		}
		else if(rownum == 1) {
			[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/address/" withError:nil];
			HostelAddressViewController *hrvc = [[HostelAddressViewController alloc] initWithNibName:nil bundle:nil];
			hrvc.delegate = self;
			hrvc.hostel = self.hostel;
			[self presentViewController:hrvc animated:YES completion:nil];
			[hrvc release];
		}
		else if(rownum == 2) {
			
			NSArray *rooms = [[Hostels loadRoomsFromDBForHostelid:self.hostel.hostelid] retain];
			
			HostelRoomViewController *hrvc = nil;
			[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/photos/" withError:nil];
			HostelAvailabilityViewController *rvc = [[HostelAvailabilityViewController alloc] initWithNibName:nil bundle:nil];
			rvc.delegate = self;
			rvc.hostel = self.hostel;
			
			if (rooms && [rooms count] > 0) {
				Room *aRoom = [rooms objectAtIndex:0];
				NSDate *now = [NSDate date];
				if ([aRoom.expiry earlierDate:now] == now) {
					[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/avaialability/" withError:nil];
					hrvc = [[HostelRoomViewController alloc] initWithNibName:nil bundle:nil];
					hrvc.hostel = self.hostel;
					hrvc.rooms = rooms;
					rvc.startDate = aRoom.startDate;
					rvc.endDate = aRoom.endDate;
				}
			}
			[rooms release];
			
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rvc];
			navController.navigationBar.tintColor = [UIColor colorWithRed:233.0/255.0 green:149.0/255.0 blue:75.0/255.0 alpha:1];
			if (hrvc) {
				[navController pushViewController:hrvc animated:NO];
                [hrvc release];
			}
			[self presentViewController:navController animated:YES completion:nil];
			[navController release];
			[rvc release];
			
			
		}
		else if(rownum == 3) {
			[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/information/" withError:nil];
			HostelInfoViewController *hrvc = [[HostelInfoViewController alloc] initWithNibName:nil bundle:nil];
			hrvc.delegate = self;
			hrvc.hostel = self.hostel;
			[self presentViewController:hrvc animated:YES completion:nil];
			[hrvc release];
		} 
	}
	
}

#pragma mark HostelSearchViewController Delegate Methods
- (void)hostelSearchViewController:(HostelSearchViewController *)hsvc 
		   didLoadHostelsForCountry:(NSString *)country 
						   withArea:(NSString *)area 
{
	if ([self.parentViewController isKindOfClass:[UITabBarController class]]) {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/list/" withError:nil];
		[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
	}
	else if ([self.parentViewController isKindOfClass:[HostelTabBarViewController class]]) {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/list/" withError:nil];
		HostelTabBarViewController *hostelsViewController = (HostelTabBarViewController *)self.parentViewController;
		[hostelsViewController hostelSearchViewController:hsvc didLoadHostelsForCountry:country withArea:area];
	}
	else {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/list/" withError:nil];
		HostelTabBarViewController *hostelsViewController = [[HostelTabBarViewController alloc] initWithNibName:nil bundle:nil];
		hostelsViewController.rootNav = self.rootNav;
		[hsvc presentViewController:hostelsViewController animated:YES completion:nil];
		[hostelsViewController release];
	}
}

- (void)hostelSearchViewControllerDidCancel:(HostelSearchViewController *)hsvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)cityForHostelSearchViewController:(HostelSearchViewController *)hsvc {
	
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *lastHostelLookup = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]];
	
	return [lastHostelLookup objectForKey:@"area"];
}

- (NSString *)countryForHostelSearchViewController:(HostelSearchViewController *)hsvc {
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *lastHostelLookup = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]];
	
	
	return [lastHostelLookup objectForKey:@"country"];
}

#pragma mark ImageLoader Delegate Method
- (void)imageLoader:(ImageLoader *)loader didLoadImage:(UIImage *)image forURI:(NSString *)uri {
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	BlogHeaderTableViewCell *cell = (BlogHeaderTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	self.hostelImage = image;
	[cell.blogThumbButton setBackgroundImage:self.hostelImage forState:UIControlStateNormal];
	
	imageLoader.delegate = nil;
	[imageLoader release];
	imageLoader = nil;
}

#pragma mark HostelRatingViewController Delegate Method
- (void)hostelRatingViewControllerDidFinish:(HostelRatingViewController *)hrvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark HostelAvailabilityViewController Delegate Method
- (void)hostelAvailabilityViewControllerDidFinish:(HostelAvailabilityViewController *)hrvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
