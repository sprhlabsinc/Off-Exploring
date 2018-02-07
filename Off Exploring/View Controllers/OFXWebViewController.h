//
//  OFXWebViewController.h
//  Off Exploring
//
//  Created by Ian Outterside on 26/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OFXWebViewController : UIViewController <UIWebViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil requestURL:(NSURL *)requestURL;

@property (nonatomic, strong) NSURL *requestURL;
@property (strong, nonatomic) IBOutlet UIWebView *webView;


@end
