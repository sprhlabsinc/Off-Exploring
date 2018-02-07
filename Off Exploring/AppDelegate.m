//
//  offexploringAppDelegate.m
//  Off Exploring
//
//  Created by Off Exploring on 19/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "OffexploringLogin.h"
#import "UserInfoViewController.h"
#import "User.h"
#import "GANTracker.h"
#import "Constants.h"
#import "OFXNavigationBar.h"
#import "ConstantsUI.h"

@implementation UINavigationController (MyApp)

-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([self.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end

#pragma mark -
#pragma mark Private Method Declarations
/**
	@brief Private methods used in setup of the app delegate.
 
	Private method declarations for the App Delegate for the Off Exploring iPhone app.
 */
@interface AppDelegate() 

/**
	@brief Provides a single point of entry for view setup for both IOS3 and IOS4 in order to support multitasking.
 
	Handles management of login. If a user is logged in then displayRootViewControllerUsingOffexploringLoginDictionary 
	is called, otherwise Login Screen is displayed.
 */
- (void)setupViewsForApplication;

@end

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

#pragma mark -
#pragma mark AppDelegate Implementaion

@implementation AppDelegate

@synthesize window;
@synthesize navigation;
@synthesize root;


#pragma mark App Startup Delegate Methods
/**
	App entry point for IOS3, called straight to setup of views
	@param application UIApplication caller
 */
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self setupViewsForApplication];
}

/**
	App entry point for IOS4, called straight to setup of views
	@param application UIApplication caller
	@param launchOption Set of lauch options
	@returns Successful launch
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption {
    
    
    //[[UINavigationBar appearance] setTintColor:myColor];
    
	[self setupViewsForApplication];
	return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	//nil at present
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	//nil at present
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//nil at present
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	//nil at present
}

- (void)applicationWillTerminate:(UIApplication *)application {
	//nil at present	
}

#pragma mark Main View Setup 
- (void)setupViewsForApplication {

	[[GANTracker sharedTracker] trackPageview:@"/" withError:nil];
    
    // Perform ui customisation
    [ConstantsUI customiseUI];
    
    // Fix for < iOS 6
    int iOSVersion = [[[UIDevice currentDevice] systemVersion] intValue];
    
    if (iOSVersion < 6) {
        [window addSubview:[navigation view]];
    }
    else {
        self.window.rootViewController = navigation;
    }
    
    OffexploringLogin *offexlogin = [[OffexploringLogin alloc] init];
	NSDictionary *dictionary = [offexlogin offexploringLoginDetails];
    
    if (!dictionary) {
        [[GANTracker sharedTracker] trackPageview:@"/user_info/" withError:nil];
		UserInfoViewController *userInfo = [[UserInfoViewController alloc] initWithNibName:nil bundle:nil];
		userInfo.delegate = self;
		[navigation presentViewController:userInfo animated:NO completion:nil];
	}
	else {
     	[self displayRootViewControllerUsingOffexploringLoginDictionary:dictionary];
	}
    
	// Override point for customization after application launch
	window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background]]];
	[window makeKeyAndVisible];
}

- (void)displayRootViewControllerUsingOffexploringLoginDictionary:(NSDictionary *)dictionary {
	User *user = [User sharedUser];
	user.username = [dictionary valueForKey:@"username"];
	user.password = [dictionary valueForKey:@"password"];
    root = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigation.navigationBar;
    [navBar setLogoHidden:NO];
	[navigation pushViewController:root animated:NO];
}

/**
	Called when user taps screen on app first open, forwards on to displaying LoginViewController
	@param userInfo UserInfoViewController object
 */
- (void)userInfoViewControllerDidDismiss:(UserInfoViewController *)userInfo {
	[navigation dismissViewControllerAnimated:YES completion:nil];
	[self displayRootViewControllerUsingOffexploringLoginDictionary:nil];
}

@end
