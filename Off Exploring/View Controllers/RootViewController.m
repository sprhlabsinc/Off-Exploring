//
//  RootViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "RootViewController.h"
#import "SettingsViewController.h"
#import "TripViewController.h"
#import "BlogLocationViewController.h"
#import "AlbumsTableViewController.h"
#import "User.h"
#import "Trips.h"
#import "Trip.h"
#import "OffexploringLogin.h"
#import "AboutUsViewController.h"
#import "DB.h"
#import "ItineraryItem.h"
#import "GANTracker.h"
#import "Reachability.h"
#import "MessageTextViewController.h"
#import "OFXNavigationBar.h"
#import "VideosViewController.h"
#import "OFXWebViewController.h"
#import "SearchViewController.h"
#import "Constants.h"
#import "INTULocationManager.h"

#pragma mark -
#pragma mark RootViewController Private Interface
/**
	@brief Private interface providing methods to download and store various pieces of information from Off Exploring, ready for display
 
	This private interface provides methods todownload and store various pieces of information from Off Exploring, including Trip information,
	Itinerary information, User information and Hostel information. It also handles notifications that a User has logged in
 */
@interface RootViewController () 

- (void)geocodeLocation:(CLLocationCoordinate2D)coordinate;

#pragma mark Private Method Declarations
/**
	Sets up user defaults for the app, including default currency
 */
- (void)setupDefaults;
/**
	Log the app usage and display "Rate this app" feature as appropriate
 */
- (void)logAppUsage;
/**
	Method called to load user information
 */
- (void)loadUser;
/**
	Handler for when a user logs in
	@param dictionary A dictionary of login details
 */
- (void)userDidLogin:(NSDictionary *)dictionary;
/**
	Method called to load trip information
 */
- (void)loadTrips;
/**
	Notification handler for when trips data has loaded
	@param notification The notification object
 */
- (void)tripsDataDidLoad:(NSNotification *)notification;
/**
	Method called to load users itinerary information
 */
- (void)loadItinerary;
/**
	Handler for when a users itinerary loads
	@param results The itinerary information
 */
- (void)saveItinerary:(NSDictionary *)results;

- (void)displayWebViewFromURL:(NSURL *)url withTitle:(NSString *)theTitle;

- (void)searchForLocationWithString:(NSString *)locationString coordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, strong) ImageLoader *imageLoader;
@property (nonatomic, strong) CLLocation *mostAccurateLocation;
@property (nonatomic, strong) NSString *nearMeLocationString;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, assign) BOOL nearMePressed;
@property (nonatomic, assign) BOOL withHostel;
@property (nonatomic, assign) int requestType;


@end

#pragma mark -
#pragma mark RootViewController Implementation
@implementation RootViewController

#pragma mark UIViewController Methods

- (void)dealloc {
	self.imageLoader.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.failGracefully = NO;
    self.nearMePressed = NO;
	[self setupDefaults];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	//number of times app ran
	int starts = [prefs integerForKey:@"appStarts"];
	starts = starts + 1;
	[prefs setInteger:starts forKey:@"appStarts"];
	[prefs synchronize];
	
    self.withHostel = NO;
	
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:@"UserDidLogin" object:nil];
	}
	return self;
}

- (void)viewDidLoad {
    self.navigationItem.leftBarButtonItem = self.aboutButton;
    [self updateCurrentLocationShowErrorAlert:NO];
	[super viewDidLoad];
}


- (void) updateCurrentLocationShowErrorAlert:(BOOL) showAlert {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse
                                       timeout:20.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 if (!self.mostAccurateLocation || self.mostAccurateLocation.horizontalAccuracy > currentLocation.horizontalAccuracy){
                                                     self.mostAccurateLocation = currentLocation;
                                                 }
                                                 
                                                 if (currentLocation.horizontalAccuracy <= 500) {
                                                     [self geocodeLocation:currentLocation.coordinate];
                                                 }
                                             }
                                             else {
                                                 if (self.mostAccurateLocation) {
                                                     [self geocodeLocation:self.mostAccurateLocation.coordinate];
                                                 }
                                                 else {
                                                     if (showAlert) {
                                                         UIAlertView *charAlert = [[UIAlertView alloc]
                                                                                   initWithTitle:@"Location Unavailable"
                                                                                   message:@"We were unable to determine your location at present. Sorry!"
                                                                                   delegate:nil
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil];
                                                         [charAlert show];
                                                     }
                                                     [self.HUD hide:YES];
                                                 }
                                             }
                                         }];
}

- (void)viewWillAppear:(BOOL)animated {
    User *user = [User sharedUser]; 
	
    if (user.username) {
        // Settings is disabled, user was not previously logged in
        if (!self.navigationItem.rightBarButtonItem) {
            self.navigationItem.rightBarButtonItem = self.settingsButton;
            
            // Need to check this
            self.website.hidden = NO;
            [self.website setTitle:[@"http://www.offexploring.com/" stringByAppendingString:user.username] forState:UIControlStateNormal];
        }
        
        self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString backgroundHome]]];
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        self.website.hidden = YES;
        self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString backgroundHomeLogo]]];
    }
    
	[[GANTracker sharedTracker] trackPageview:@"/home/" withError:nil];
	
    OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
    [navBar setLogoHidden:NO];
    
	self.requestType = 0;
	[self logAppUsage];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog (@"***Memory Warning***");
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.website = nil;
	self.settingsButton = nil;
	self.aboutButton = nil;
	
	self.viewBlogs = nil;
	self.viewAlbums = nil;
	self.navigationController.view.backgroundColor = nil;
	
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark IBActions

- (IBAction)viewSettingsOrSearch {
	[[GANTracker sharedTracker] trackPageview:@"/home/settings/" withError:nil];
	SettingsViewController *settings = [[SettingsViewController alloc] init];
	settings.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	settings.root = self;
	[self.navigationController presentViewController:settings animated:YES completion:nil];
}

- (IBAction)viewAboutPage {
	[[GANTracker sharedTracker] trackPageview:@"/home/about_us/" withError:nil];
	AboutUsViewController *aboutPage = [[AboutUsViewController alloc] initWithNibName:nil bundle:nil];
    OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
    [navBar setLogoHidden:YES];
    [self.navigationController pushViewController:aboutPage animated:YES];
}

- (IBAction)viewBlogs:(id)selector {
	self.requestType = 10;
	[self loadTrips];
}

- (IBAction)viewPhotos:(id)selector {
	self.requestType = 20;
	[self loadTrips];
}

- (IBAction)viewWebsite {
	User *user = [User sharedUser];
	[[GANTracker sharedTracker] trackPageview:@"/home/user_site/" withError:nil];
	NSURL *url = nil;
	url = [NSURL URLWithString:[@"http://www.offexploring.com/" stringByAppendingString:user.username]];
	[[UIApplication sharedApplication] openURL:url];	
}

- (IBAction)messagesButtonPressed:(id)sender {
    // Uncomment for live
    self.requestType = 30;
	[self loadTrips];
}

- (IBAction)videosButtonPressed:(id)sender {
    self.requestType = 40;
    [self loadTrips];
}

- (IBAction)latestBlogsButtonPressed:(id)sender {
    [self displayWebViewFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.offexploring.com/search/browse"]] withTitle:nil];
}

- (IBAction)nearMeBlogsButtonPressed:(id)sender {
    
    NSString *errorMsgTitle = @"Location Services Disabled";
    if ([INTULocationManager locationServicesState] != INTULocationServicesStateDisabled && [INTULocationManager locationServicesState] != INTULocationServicesStateAvailable) {
        errorMsgTitle = @"App Specific Location Services Disabled";
    }
    
    if([INTULocationManager locationServicesState] != INTULocationServicesStateAvailable) {
        UIAlertView *charAlert = [[UIAlertView alloc]
                                  initWithTitle:errorMsgTitle
                                  message:@"Location Services must be enabled to view blogs near you"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [charAlert show];
        return;
    }

    self.nearMePressed = YES;
    
    if (self.nearMeLocationString) {
        [self searchForLocationWithString:self.nearMeLocationString coordinate:self.mostAccurateLocation.coordinate];
    }
    else {
        if (self.mostAccurateLocation && self.mostAccurateLocation.horizontalAccuracy <= 500) {
            [self geocodeLocation:self.mostAccurateLocation.coordinate];
        }
        else {
            [self updateCurrentLocationShowErrorAlert:YES];
        }
        
        self.HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.HUD];
        self.HUD.delegate = self;
        self.HUD.labelText = @"Getting your location...";
        [self.HUD show:YES];
    }
}

- (void)searchForLocationWithString:(NSString *)locationString coordinate:(CLLocationCoordinate2D)coordinate {
    
    self.nearMePressed = NO;
    OffexConnex *connex = [[OffexConnex alloc] init];
    NSString *escapedText = [connex urlEncodeValue:locationString];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.offexploring.com/search/place/%@?lat=%@&lng=%@", escapedText, @(coordinate.latitude), @(coordinate.longitude)]];
    
    [self displayWebViewFromURL:url withTitle:nil];
}

/*#pragma mark MKReverseGeocoder Delegate Methods

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)newPlacemark {
    
    NSString *locationString = nil;
    [HUD hide:YES];
    
    
    if ((newPlacemark.addressDictionary)[@"City"] && (![(newPlacemark.addressDictionary)[@"City"] isEqualToString:(newPlacemark.addressDictionary)[@"State"]])) {
        
        // City string
        locationString = (newPlacemark.addressDictionary)[@"City"];
    }
    else if ((newPlacemark.addressDictionary)[@"State"]) {
        
        // State string
        locationString = (newPlacemark.addressDictionary)[@"State"];
    }
    else if((newPlacemark.addressDictionary)[@"Country"]) {
        
        // State string
        locationString = (newPlacemark.addressDictionary)[@"Country"];
    }
    else if ((newPlacemark.addressDictionary)[@"FormattedAddressLines"]) {
        locationString = [(newPlacemark.addressDictionary)[@"FormattedAddressLines"] componentsJoinedByString: @", "];
    }
    
    self.nearMeLocationString = locationString;
    
    if (self.nearMePressed) {
        if (self.nearMeLocationString) {
            [self searchForLocationWithString:self.nearMeLocationString coordinate:newPlacemark.coordinate];
        }
        else {
            UIAlertView *charAlert = [[UIAlertView alloc]
                                      initWithTitle:@"Location Unavailable"
                                      message:@"We were unable to determine your location at present. Sorry!"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [charAlert show];
            
        }
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    
    if ([error code] == -1011 && [[error localizedDescription] isEqualToString:@"The operation couldn’t be completed. (NSURLErrorDomain error -1011.)"]) {
        
        
        [self geocodeLocation:geocoder.coordinate];
    }
    else {
        [HUD hide:YES];
        
        UIAlertView *charAlert = [[UIAlertView alloc]
                                  initWithTitle:@"Location Unavailable"
                                  message:@"We were unable to determine your location at present. Sorry!"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [charAlert show];
        
    }
}
*/

- (void)geocodeLocation:(CLLocationCoordinate2D)coordinate {
    
    /*MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
    [geocoder setDelegate:self];
    [geocoder start];*/
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error) {
            
            if ([error code] == -1011 && [[error localizedDescription] isEqualToString:@"The operation couldn’t be completed. (NSURLErrorDomain error -1011.)"]) {
                [self geocodeLocation:location.coordinate];
            }
            else {
                [self.HUD hide:YES];
                
                UIAlertView *charAlert = [[UIAlertView alloc]
                                          initWithTitle:@"Location Unavailable"
                                          message:@"We were unable to determine your location at present. Sorry!"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [charAlert show];
                
            }
        }
        else if ([placemarks count]) {
            
            CLPlacemark *newPlacemark = [placemarks objectAtIndex:0];
            
            NSString *locationString = nil;
            
            if ((newPlacemark.addressDictionary)[@"City"] && (![(newPlacemark.addressDictionary)[@"City"] isEqualToString:(newPlacemark.addressDictionary)[@"State"]])) {
                
                // City string
                locationString = (newPlacemark.addressDictionary)[@"City"];
            }
            else if ((newPlacemark.addressDictionary)[@"State"]) {
                
                // State string
                locationString = (newPlacemark.addressDictionary)[@"State"];
            }
            else if((newPlacemark.addressDictionary)[@"Country"]) {
                
                // State string
                locationString = (newPlacemark.addressDictionary)[@"Country"];
            }
            else if ((newPlacemark.addressDictionary)[@"FormattedAddressLines"]) {
                locationString = [(newPlacemark.addressDictionary)[@"FormattedAddressLines"] componentsJoinedByString: @", "];
            }
            
            self.nearMeLocationString = locationString;
            
            [self.HUD hide:YES];
            
            if (self.nearMePressed) {
                if (self.nearMeLocationString) {
                    [self searchForLocationWithString:self.nearMeLocationString coordinate:newPlacemark.location.coordinate];
                }
                else {
                    UIAlertView *charAlert = [[UIAlertView alloc]
                                              initWithTitle:@"Location Unavailable"
                                              message:@"We were unable to determine your location at present. Sorry!"
                                              delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
                    [charAlert show];
                    
                }
            }
        }
    }];
    
    
}

- (IBAction)searchBlogsButtonPressed:(id)sender {
    
    SearchViewController *searchController = [[SearchViewController alloc] initWithNibName:nil bundle:nil];
    OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
    [navBar setLogoHidden:NO];
    [self.navigationController pushViewController:searchController animated:YES];
    
}

#pragma mark Private Methods
- (void)logAppUsage {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	BOOL showResults = NO;
	User *user = [User sharedUser];
	
	if ([TARGET_PARTNER isEqualToString:@"offexploring"]) {
		if (!user.itinerary) {
			[self loadItinerary];
		}
		
		showResults = [prefs boolForKey:@"showRateMeDialog"];
	}
	
	double startDate = [prefs doubleForKey:@"appFirstDate"];
	
	if (startDate == 0) {
		double startDate = [[NSDate date] timeIntervalSince1970];
		[prefs setDouble:startDate forKey:@"appFirstDate"];
		[prefs setBool:YES forKey:@"showRateMeDialog"];
		[prefs synchronize];
	}
	else if (showResults == YES && [TARGET_PARTNER isEqualToString:@"offexploring"]) {
		NSTimeInterval todaysDiff = [[NSDate date] timeIntervalSince1970];
		NSTimeInterval dateDiff = todaysDiff - startDate;
		int days = dateDiff / 86400;
		
		if (days > 5) {
			//show dialogue;
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"Help Spread the Word"
									  message:@"If you like this app, please help us by rating it in the App Store. Thanks."
									  delegate:self
									  cancelButtonTitle:@"No Thanks"
									  otherButtonTitles:@"Rate It Now", @"Remind Me Later", nil];
			[charAlert show];
			
		}
	}
}

- (void)setupDefaults {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if (![prefs objectForKey:@"currency"]) {
		
		NSString *defCur = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
		NSString *defCurName = nil;
		NSString *defCurSymbol = nil;
		
		if ([defCur isEqualToString:@"GBP"]) {
			defCurName = @"United Kingdom, Pounds";
			defCurSymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
		}
		else if ([defCur isEqualToString:@"CAD"]) {
			defCurName = @"Canada, Dollars";
			defCurSymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
		}
		else if ([defCur isEqualToString:@"AUD"]) {
			defCurName = @"Australia, Dollars";
			defCurSymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
		}
		else if ([defCur isEqualToString:@"EUR"]) {
			defCurName = @"Euro Member Countries, Euro";
			defCurSymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
		}
		else {
			defCur = @"USD";
			defCurName = @"United States, Dollars";
			defCurSymbol = @"$";
		}
		
		NSDictionary *currency = @{@"code": defCur, @"name": defCurName, @"symbol": defCurSymbol};
		
		[prefs setObject:currency forKey:@"currency"];
		[prefs synchronize];
	}
}

- (void)loadUser {
	User *user = [User sharedUser];
	OffexConnex *connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	NSString *url = [connex buildOffexRequestStringWithURI:[@"user/" stringByAppendingString:user.username]];
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)userDidLogin:(NSDictionary *)dictionary {
	[[GANTracker sharedTracker] trackPageview:@"/home/" withError:nil];
	User *user = [User sharedUser];
	user.username = [dictionary valueForKey:@"username"];
    //[Crittercism setUsername:user.username];
	user.password = [dictionary valueForKey:@"password"];
	[self.website setTitle:[@"http://www.offexploring.com/" stringByAppendingString:user.username] forState:UIControlStateNormal];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadTrips {
    
    User *user = [User sharedUser];
	
    if (user.username) {
        self.HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.HUD];
        self.HUD.delegate = self;
        self.HUD.labelText = @"Loading...";
        [self.HUD show:YES];
        OffexConnex *connex = [[OffexConnex alloc] init];
        connex.delegate = self;
        NSString *url = [connex buildOffexRequestStringWithURI:[[@"user/" stringByAppendingString:user.username] stringByAppendingString:@"/trip"]];
        [connex beginLoadingOffexploringDataFromURL:url];
    }
    else {
        LoginViewController *logout = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        logout.delegate = self;
        [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:logout animated:YES completion:nil];
    }
}

- (void)tripsDataDidLoad:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TripsDataDidLoad" object:nil];
	[self.HUD hide:YES];
	
	User *user = [User sharedUser];
	user.globalDraft = NO;
	
	Trips *trips = [notification object];
	Trip *firstTrip = (trips.tripsArray)[0];
	
	if ([firstTrip.urlSlug isEqualToString:@"default"]) {
		if (self.requestType == 10) {
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/" withError:nil];
			BlogLocationViewController *locationView = [[BlogLocationViewController alloc] initWithNibName:nil bundle:nil];
			locationView.title = @"Locations";
			locationView.activeTrip = firstTrip;
            OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
            [navBar setLogoHidden:YES];
            [self.navigationController pushViewController:locationView animated:YES];
		}
		else if (self.requestType == 20) {
			[[GANTracker sharedTracker] trackPageview:@"/home/albums/" withError:nil];
			AlbumsTableViewController *albumView = [[AlbumsTableViewController alloc] initWithNibName:nil bundle:nil];
			albumView.title = @"Photo Albums";
			albumView.activeTrip = firstTrip;
            OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
            [navBar setLogoHidden:YES];
            [self.navigationController pushViewController:albumView animated:YES];
		}
        else if (self.requestType == 30) {
            [[GANTracker sharedTracker] trackPageview:@"/home/messages/" withError:nil];
            MessageTextViewController *controller = [[MessageTextViewController alloc] initWithNibName:nil bundle:nil];
            [controller loadMessagesForTrip:firstTrip];
            OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
            [navBar setLogoHidden:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (self.requestType == 40) {
            [[GANTracker sharedTracker] trackPageview:@"/home/videos/" withError:nil];
            VideosViewController *controller = [[VideosViewController alloc] initWithNibName:nil bundle:nil];
            controller.activeTrip = firstTrip;
            OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
            [navBar setLogoHidden:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
        }
	}
	else {
		[[GANTracker sharedTracker] trackPageview:@"/home/trips/" withError:nil];
		TripViewController *tripView = [[TripViewController alloc] initWithNibName:nil bundle:nil];
		tripView.title = @"Trips";
		tripView.requestType = self.requestType;
		tripView.trips = trips;
        OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
        [navBar setLogoHidden:YES];
        [self.navigationController pushViewController:tripView animated:YES];
	}
}

- (void)loadItinerary {
	User *user = [User sharedUser];
	[user loadItineraryFromDB];
	if (!user.itinerary) {
		[[DB sharedDB] emptyItineraryDBForUsername:user.username];
		OffexConnex *connex = [[OffexConnex alloc] init];
		connex.delegate = self;
		NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/itinerary",user.username]];
		[connex beginLoadingOffexploringDataFromURL:url];
	}
}

- (void)saveItinerary:(NSDictionary *)results {
	User *user = [User sharedUser];
	DB *db = [DB sharedDB];
	sqlite3_stmt *init_statement = nil;
	
	const char *sql = "INSERT INTO user_itinerary (id, username, timestamp, state, area, latitude, longitude, trip_id, expiry) VALUES (?,?,?,?,?,?,?,?,?)";
	
	if (sqlite3_prepare_v2(db.database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
		//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
	}
	
	if (results[@"response"][@"itinerary"][@"item"] != [NSNull null]) {
		
		for (NSDictionary *item in results[@"response"][@"itinerary"][@"item"]) {
			int trip_id;
			
			if (item[@"trip"] == [NSNull null]) {
				trip_id = -1;
			}
			else {
				trip_id = [item[@"trip"] intValue];
			}
			
			NSTimeInterval expiry = ([NSDate timeIntervalSinceReferenceDate] + 3600);
			
			sqlite3_bind_int(init_statement, 1, [item[@"id"] intValue]);
			sqlite3_bind_text(init_statement, 2,[user.username UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(init_statement, 3, [item[@"timestamp"] intValue]);
			sqlite3_bind_text(init_statement, 4,[item[@"state"] UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(init_statement, 5,[item[@"area"] UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_double(init_statement, 6, [item[@"location"][@"latitude"] doubleValue]);
			sqlite3_bind_double(init_statement, 7, [item[@"location"][@"longitude"] doubleValue]);
			sqlite3_bind_int(init_statement, 8, trip_id);
			sqlite3_bind_int(init_statement, 9, expiry);
			
			
			sqlite3_step(init_statement);
			sqlite3_reset(init_statement);
		}
	}
}

#pragma mark LoginViewController Delegate Method
- (void)loginViewController:(LoginViewController *)login didLoginWithUsername:(NSString *)username andPassword:(NSString *)password {
	NSDictionary *dictionary = @{@"username": username, @"password": password};
	[self userDidLogin:dictionary];	
}

- (void)loginViewControllerDidCancel:(LoginViewController *)login {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark offexploringConnection Delegate Methods
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
	User *user = [User sharedUser];
	
	if (results[@"response"][@"itinerary"]) {
		if ([TARGET_PARTNER isEqualToString:@"offexploring"]) {
			[self saveItinerary:results];
			NSDate *now = [NSDate date];
			[[NSUserDefaults standardUserDefaults] setDouble:[now timeIntervalSince1970] forKey:@"lastItineraryLookup"];
			[user loadItineraryFromDB];
		}
	}
	else if (results[@"response"][@"username"] != nil) {
		[user setFromDictionary:results[@"response"]];
	}
	else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripsDataDidLoad:) name:@"TripsDataDidLoad" object:nil];
		Trips *tripsData = [[Trips alloc] init];
		[tripsData setFromArray:results[@"response"][@"trips"][@"trip"]];
	}
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TripsDataDidLoad" object:nil];
	[self.HUD hide:YES];
	
	if (self.failGracefully == YES) {
		if (self.modalViewController == nil || ![self.modalViewController isKindOfClass:[LoginViewController class]]) {
			
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"Sorry"
									  message:@"This is not a valid Off Exploring account. Please log in with a valid one."
									  delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
			[charAlert show];
			
			
			
			[self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
			LoginViewController *logout = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
			logout.delegate = self;
			[self presentViewController:logout animated:YES completion:nil];
			
		}
	}
	else if (self.requestType == 10) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Unable to Connect"
								  message:@"You can continue to edit your blog, and save a draft, but changes cannot be published until you are connected to the Internet"
								  delegate:self
								  cancelButtonTitle:@"Cancel"
								  otherButtonTitles:@"Proceed", nil];
		[charAlert show];
		
	}
	else if (self.requestType == 20) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Unable to Connect"
								  message:@"You cannot view or edit photos until you are connected to the Internet"
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
    else if (self.requestType == 30) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Unable to Connect"
								  message:@"You cannot view or post messages until you are connected to the Internet"
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
    }
    else if (self.requestType == 40) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Unable to Connect"
								  message:@"You cannot view or post videos until you are connected to the Internet"
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
    }
}


#pragma mark UIAlertView Delegate Method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	if ([alertView.title isEqualToString:@"Help Spread the Word"]) {
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		BOOL showResults = [prefs boolForKey:@"showRateMeDialog"];
		
		if (buttonIndex == 0 || buttonIndex == 1) {
			showResults = NO;
			[prefs setBool:showResults forKey:@"showRateMeDialog"];
			[prefs synchronize];
			
			if (buttonIndex == 1) {
				[[GANTracker sharedTracker] trackPageview:@"/home/rate_app/" withError:nil];
				NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/gb/app/off-exploring/id373984511"];
				[[UIApplication sharedApplication] openURL:url];
			}
		}
	}
	else {
		if (buttonIndex == 1) {
			if (self.requestType == 10) {
				User *user = [User sharedUser];
				user.globalDraft = YES;
				
				Trip *draftTrip = [[Trip alloc]initFromDictionary:nil];
				draftTrip.name = @"Draft";	
				draftTrip.urlSlug = @"default";	
				[draftTrip setBlogsDataFromArray:nil];
				[[GANTracker sharedTracker] trackPageview:@"/home/blogs/" withError:nil];
				BlogLocationViewController *locationView = [[BlogLocationViewController alloc] initWithNibName:nil bundle:nil];
				locationView.title = @"Locations";
				locationView.activeTrip = draftTrip;
                OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
                [navBar setLogoHidden:YES];
				[self.navigationController pushViewController:locationView animated:YES];
			}
		}
	}
}

#pragma mark MBProgressHUD Delegate Method 
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
	self.HUD.delegate = nil;
    [self.HUD removeFromSuperview];
	self.HUD = nil;
}

- (void)displayWebViewFromURL:(NSURL *)url withTitle:(NSString *)theTitle {
    
    OFXWebViewController *controller = [[OFXWebViewController alloc] initWithNibName:nil bundle:nil requestURL:url];
    
    if (!theTitle) {
        OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
        [navBar setLogoHidden:NO];
    }
    else {
        controller.title = theTitle;
        OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
        [navBar setLogoHidden:YES];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
