//
//  OFXWebViewController.m
//  Off Exploring
//
//  Created by Ian Outterside on 26/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OFXWebViewController.h"

@implementation OFXWebViewController

@synthesize requestURL = _requestURL;
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil requestURL:(NSURL *)requestURL
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _requestURL = requestURL;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Change the title of the back button
    int count = [self.navigationController.viewControllers count];
    UIViewController *previousViewController = (UIViewController *)(self.navigationController.viewControllers)[count-2];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleDone target:nil action:nil];
    previousViewController.navigationItem.backBarButtonItem = item;
        
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:36.0f/255.0f green:34.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
    self.webView.backgroundColor = [UIColor colorWithRed:36.0f/255.0f green:34.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.requestURL]];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// Stop the app going outside off exploring domain
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = [[request URL] absoluteString];
	
	if ([urlString rangeOfString:@"offexploring.com"].location == NSNotFound) {
        
        // Todo - change text
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unavailable" 
                                                        message:@"You may only view Off Exploring content from inside this app" 
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
        
        [alert show];
        
		return NO;
	} 
    else {
		return YES;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = item;
    [activityIndicator startAnimating];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *errorMessage = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    switch ([error code]) {
        case NSURLErrorUnknown:
        case NSURLErrorBadURL:
        case NSURLErrorUnsupportedURL:
        case NSURLErrorCannotFindHost:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorDataLengthExceedsMaximum:
        case NSURLErrorHTTPTooManyRedirects:
        case NSURLErrorResourceUnavailable:
        case NSURLErrorRedirectToNonExistentLocation:
        case NSURLErrorBadServerResponse:
        case NSURLErrorZeroByteResource:
        case NSURLErrorCannotDecodeRawData:
        case NSURLErrorCannotDecodeContentData:
        case NSURLErrorCannotParseResponse:
        case NSURLErrorDataNotAllowed:
        case NSURLErrorRequestBodyStreamExhausted:
        case NSURLErrorServerCertificateHasBadDate:
        case NSURLErrorServerCertificateUntrusted:
        case NSURLErrorServerCertificateHasUnknownRoot:
        case NSURLErrorServerCertificateNotYetValid:
        case NSURLErrorClientCertificateRejected:
        case NSURLErrorClientCertificateRequired:
        case NSURLErrorCannotCreateFile:
        case NSURLErrorCannotOpenFile:
        case NSURLErrorCannotCloseFile:
        case NSURLErrorCannotWriteToFile:
        case NSURLErrorCannotRemoveFile:
        case NSURLErrorCannotMoveFile:
        case NSURLErrorDownloadDecodingFailedMidStream:
        case NSURLErrorDownloadDecodingFailedToComplete:
        case NSURLErrorSecureConnectionFailed:
            errorMessage = @"An unknown error occurred. Please go back.";
            break;
        case NSURLErrorTimedOut:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorNotConnectedToInternet:
        case NSURLErrorCannotLoadFromNetwork:
        case NSURLErrorInternationalRoamingOff:
            errorMessage = @"You need to be connected to the Internet to search and browse blogs";
            break;
        case NSURLErrorCancelled:
        case NSURLErrorUserCancelledAuthentication:
        case NSURLErrorUserAuthenticationRequired:
        case NSURLErrorCallIsActive:
        case NSURLErrorFileDoesNotExist:
        case NSURLErrorFileIsDirectory:
        case NSURLErrorNoPermissionsToReadFile:
        default:
            // Do nothing
            break;
    }
    
    if (errorMessage) {
        UIAlertView *charAlert = [[UIAlertView alloc]
                                  initWithTitle:@"Unable to connect to Off Exploring"
                                  message:errorMessage
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [charAlert show];
        
    }
}

@end
