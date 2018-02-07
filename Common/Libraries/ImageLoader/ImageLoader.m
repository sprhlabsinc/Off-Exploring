//
//  ImageLoader.m
//  Off Exploring
//
//  Created by Off Exploring on 12/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "ImageLoader.h"

NSString * const OFFEX_IMAGE_ADDRESS = @"http://www.offexploring.com";
//NSString * const OFFEX_IMAGE_ADDRESS = @"http://api.offexploring.com/holding/";
//NSString * const S3_IMAGE_ADDRESS = @"http://offexploring.s3.amazonaws.com";
NSString * const S3_IMAGE_ADDRESS = @"http://media.offexploring.co.uk";

#pragma mark -
#pragma mark ImageLoader Private Interface
/**
	@brief Private method used to correctly format a remote request string to Amazon S3 or Off Exploring.
 
	This interface allows for the correct generation of a remote request string to Amazon S3 or Off Exploring, including
	appropriate character escapes.
 */
@interface ImageLoader()
#pragma mark Private Method Declarations
/**
	Returns a formatted and escaped remote image request string to the given uri
	@param uri The uri of the image being requested
	@returns The formatted string
 */
- (NSString *) buildOffexImageRequestStringWithURI:(NSString *)uri;

@property (nonatomic, strong) NSString *originalURI;
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, assign) BOOL offexLoad;

@end

#pragma mark -
#pragma mark ImageLoader Implementation

@implementation ImageLoader

@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize requestURI;
@synthesize originalURI;
@synthesize offexLoad;
@synthesize foreign;

- (void)dealloc
{
	delegate = nil;
    [imageConnection cancel];
}

#pragma mark Connection Methods

- (id)initWithURL:(NSString *)url isForeign:(BOOL)remote delegate:(id<ImageLoaderDelegate>)theDelegate {

	if (self = [super init]) {
	
		self.delegate = theDelegate;
		self.foreign = remote;
		
		[self startDownloadForURL:url];
	
	}
	return self;
}

- (void)startDownloadForURL:(NSString *)uri
{
	if (!self.foreign) {
		self.foreign = NO;
	}
	if (!self.offexLoad) {
		self.offexLoad = NO;
	}
	self.originalURI = uri;
	if (self.foreign == YES) {
		self.requestURI = uri;
	}
	else {
		self.requestURI = [self buildOffexImageRequestStringWithURI:uri];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.activeDownload = [NSMutableData data];
	
	// alloc+init and start an NSURLConnection; release on completion/failure
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestURI]] delegate:self];

	self.imageConnection = conn;
	
}

#pragma mark Cancellation Method
- (void)cancelDownload
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
	delegate = nil;
}

#pragma mark Private Methods
- (NSString *) buildOffexImageRequestStringWithURI:(NSString *)uri {
	NSString *theURI = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)uri, NULL, CFSTR(":?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8));
	NSString *returnURI = nil;
	if (offexLoad == YES) {
		returnURI = [OFFEX_IMAGE_ADDRESS stringByAppendingString:theURI];
	}
	else {
		returnURI = [S3_IMAGE_ADDRESS stringByAppendingString:theURI];
	}
	return returnURI;
}

#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
	
	self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
	
	if (foreign == NO) {
		if (image == nil && self.offexLoad == NO) {
			self.offexLoad = YES;
			[self startDownloadForURL:self.originalURI];
		}
		else if(image == nil && self.offexLoad == YES) {
			image = [UIImage imageNamed:@"notfoundimage.png"];
			[delegate imageLoader:self didLoadImage:image forURI:self.originalURI];
		}
		else {
			[delegate imageLoader:self didLoadImage:image forURI:self.originalURI];
		}
	}
	else {
		if(image == nil) {
			image = [UIImage imageNamed:@"notfoundimage.png"];
		}
		if ([delegate respondsToSelector:@selector(imageLoader:didLoadImage:forURI:)]) {
			[delegate imageLoader:self didLoadImage:image forURI:self.originalURI];
		}
	}
}

@end
