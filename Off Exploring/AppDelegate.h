/*
 Copyright (C) 2010 Off Exploring Ltd. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are strictly prohibited unless prior approval from Off Exploring
 Ltd has been provided.
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 @mainpage Off Exploring iPhone Application Source and Libraries.
 
 Off Exploring provides a bloging service and platform for its users to use by uploading
 various forms of content including but not limited to blog text, photos, videos, 
 journal plans. The service also provides hostelbooking services. This iPhone application
 wraps around those services.
 
 Learn more at http://www.offexploring.com
 
 This library conforms to IOS version 3.0 SDK for its earliest release and IOS 4.1 SDK
 for its latest. Support for other versions is not provided. 
 
 
 @author Ian Outterside
 @author Scott Salisbury
 
 */

#import <UIKit/UIKit.h>
#import "RootViewController.h"

/**
 @brief App Delegate for the Off Exploring iPhone app.
 
 Handles app start, setup of the root view and display. Displays login as appropriate.
 Sets itself as the UIApplicationDelegate, a LoginViewControllerDelegate (to handle dismiss
 of the login screen, and UserInfoViewController Delegate (to handle dismiss of the user info
 screen).
 */
@interface AppDelegate : NSObject <UIApplicationDelegate, UserInfoViewControllerDelegate> 
{
    /**
    	Main window
     */
    UIWindow *window;
	
	/**
		Navigation Controller wrapping up child navigation for Blogs and Albums ViewController children
	 */
	UINavigationController *navigation;
	
	/**
		App default startup View Controller. 
	 */
	RootViewController *root;
}

/**
	@brief Displays the RootViewController and passes appropriate login information:
	
	Handles setup and display of the RootViewController. Sets users username as page title and stores login details for 
	Off Exploring API requests.

	@param dictionary The login dictionary, should comprise of 2 keys, "username" and "password". Password key should be
	SHA1 encoded.
 */
- (void)displayRootViewControllerUsingOffexploringLoginDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigation;
@property (nonatomic, strong) RootViewController *root;

@end

