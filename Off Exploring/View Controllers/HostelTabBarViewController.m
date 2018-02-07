//
//  HostelTabBarViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 12/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelTabBarViewController.h"
#import "HostelSearchViewController.h"
#import "HostelListViewController.h"
#import "HostelMapViewController.h"
#import "User.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark HostelTabBarViewController Implementation
@implementation HostelTabBarViewController

@synthesize rootNav;
@synthesize hlvc;
@synthesize hmvc;
@synthesize tabBarWrapper;
@synthesize tabBar;

#pragma mark UIViewController Methods
- (void)dealloc {
	[tabBar release];
	[tabBarWrapper release];
	[hlvc release];
	[hmvc release];
	[super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
	
	if (!hlvc) {
		hlvc = [[HostelListViewController alloc] initWithNibName:nil bundle:nil];
	}
	if (!hmvc) {
		hmvc = [[HostelMapViewController alloc] initWithNibName:nil bundle:nil];
	}
	
	hlvc.parentTabController = self;
	hmvc.parentTabController = self;
	hlvc.view.frame = CGRectMake(0, 44, 320, 368);
	[self.view addSubview:hlvc.view];
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
	self.tabBarWrapper = nil;
}

#pragma mark IBActions
- (IBAction)homePressed {
	[self.rootNav dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchPressed {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/search/" withError:nil];
	HostelSearchViewController *hostelSearch = [[HostelSearchViewController alloc] initWithNibName:nil bundle:nil];
	hostelSearch.hostelDelegate = self;
	[self presentViewController:hostelSearch animated:YES completion:nil];
	[hostelSearch release];

}

#pragma mark UITabBar Delegate Method

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if ([item.title isEqualToString:@"Hostels"]) {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/list/" withError:nil];
		[hmvc.view removeFromSuperview];
		hlvc.view.frame = CGRectMake(0, 44, 320, 368);
		[self.view addSubview:hlvc.view];
	}
	else {
		[[GANTracker sharedTracker] trackPageview:@"/home/hostels/map/" withError:nil];
		[hlvc.view removeFromSuperview];
		hmvc.view.frame = CGRectMake(0, 44, 320, 368);
		[self.view addSubview:hmvc.view];
		[hmvc viewWillAppear:NO];
		[hmvc zoomIn:YES];
	}
}

#pragma mark HostelSearchViewController Delegate Methods
- (void)hostelSearchViewController:(HostelSearchViewController *)hsvc 
		   didLoadHostelsForCountry:(NSString *)country 
						   withArea:(NSString *)area {
		
	[hlvc reloadView];
	[hmvc viewWillAppear:NO];
	[hmvc zoomIn:YES];
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/list/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hostelSearchViewControllerDidCancel:(HostelSearchViewController *)hsvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/list/" withError:nil];
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

@end
