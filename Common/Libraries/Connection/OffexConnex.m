//
//  OffexConnex.m
//  Off Exploring
//
//  Created by Off Exploring on 23/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "OffexConnex.h"
#import <CFNetwork/CFNetwork.h>
#import <CommonCrypto/CommonHMAC.h>
#import "SBJson.h"
#import "User.h"
#import "RootViewController.h"

#pragma mark -
#pragma mark OffexConnex Private Interface
/**
	@brief Private methods used to correctly encode, format and generate a CRC hash for a given value.
 
	This interface provides private methods used to build a correctly constructed POST, GET or DELETE request.
	The urlEncodeValue: method returns the paramater string escaped using kCFStringEncodingUTF8. This fixes spaces,
	and unusual characters ready for transmittion over the internet. The hashForString: method returns a CRC hash,
	using the SHA1 library, of the passed in string. This can be transmitted along with the request to validate 
	data has been received correctly.
 */
@interface OffexConnex()
/**
	Generates a SHA1 CRC hash from the given string
	@param str The string to hash
	@returns The SHA1 hash value
 */
- (NSString *)hashForString:(NSString *)str;

@property (nonatomic, strong) NSURLConnection *offexploringConnection;
@property (nonatomic, strong) NSMutableData *offexploringData;

@end

#pragma mark -
#pragma mark OffexConnex Implementation

@implementation OffexConnex

@synthesize delegate;
@synthesize offexploringConnection;
@synthesize offexploringData;
@synthesize request = __request;


#pragma mark Connection Construction Methods

- (NSString *)buildHBRequestStringWithURI:(NSString *)uri {
	NSString *requestURI = [HB_API_ADDRESS stringByAppendingString:[uri stringByAppendingString:@".json"]];
	return requestURI;
}

- (NSString *)buildOffexRequestStringWithURI:(NSString *)uri {
	User *user = [User sharedUser];
	NSString *requestURI  = [self buildAuthenticatedOffexRequestStringWithURI:uri andUsername:user.username andPassword:user.password];
	return requestURI;
}

- (NSString *)buildAuthenticatedOffexRequestStringWithURI:(NSString *)uri andUsername:(NSString *)theUsername andPassword:(NSString *)thePassword {
	NSString *requestURI;
	if (theUsername == nil || thePassword == nil) {
		requestURI = [OFFEX_API_ADDRESS stringByAppendingString:[uri stringByAppendingString:[@".json?key=" stringByAppendingString: OFFEX_API_KEY]]];
	}
	else {
		requestURI = [[[OFFEX_API_ADDRESS stringByAppendingString:[uri stringByAppendingString:[@".json?key=" stringByAppendingString: OFFEX_API_KEY]]] stringByAppendingString:[@"&username=" stringByAppendingString:theUsername]] stringByAppendingString:[@"&password=" stringByAppendingString:thePassword]];
	}
	return requestURI;
}

- (NSData *)paramaterBodyForDictionary:(NSDictionary *)dict {
	
	NSMutableString *returnString = [[NSMutableString alloc] init];
	NSArray *dictKeys = [dict allKeys];
	
	int count = 0;
	
	for (NSString *key in dictKeys) {
		[returnString appendString:key];
		[returnString appendString:@"="];
		[returnString appendString:[self urlEncodeValue:dict[key]]];
		[returnString appendString:@"&"];
		[returnString appendString:[key stringByAppendingString:@"_hash"]];
		[returnString appendString:@"="];
		[returnString appendString:[self hashForString:dict[key]]];
		
		
		if (count < ([dictKeys count] - 1)) {
			[returnString appendString:@"&"];
		}
		count++;
	}
	
	NSString *stringToReturn = returnString;
	return [stringToReturn dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSData *)parameterBodyForImage:(UIImage *)image andBoundary:(NSString *)boundary andFilename:(NSString *)filename andDictionary:(NSDictionary *)dict {
	
	NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
	
	NSMutableData *body = [NSMutableData data];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSArray *dictKeys = [dict allKeys];
	
	for (NSString *key in dictKeys) {
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, dict[key]] dataUsingEncoding:NSUTF8StringEncoding]];  
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
	}
	
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"Filedata\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[NSData dataWithData:imageData]];  
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	
	return body;
}

#pragma mark Connection Methods

- (void)beginLoadingOffexploringDataFromURL:(NSString *)urlString {
	NSURLRequest *offexURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
	self.offexploringConnection = [[NSURLConnection alloc] initWithRequest:offexURLRequest delegate:self];
    self.request = offexURLRequest;
    NSAssert(self.offexploringConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)postOffexploringData:(NSData *)dataString withContentMode:(NSString *)contentMode toURL:(NSString *)urlString {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	
	//NSString *contentType = @"application/x-www-form-urlencoded";
	[request addValue:contentMode forHTTPHeaderField: @"Content-Type"];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:dataString];
	
	// Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// create the connection with the request and start loading the data
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	self.offexploringConnection = connection;
    self.request = request;
}

- (void)deleteOffexploringDataAtUrl:(NSString *)urlString {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"DELETE"];
	
	// Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// create the connection with the request and start loading the data
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	self.offexploringConnection = connection;
    self.request = request;
}

#pragma mark Private Methods

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8));
	
	return result;
}

- (NSString *)hashForString:(NSString *)str {
	
	const char *s = [str cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
	/// This is the destination
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	// This one function does an unkeyed SHA1 hash of your hash data
	CC_SHA1(keyData.bytes, keyData.length, digest);
	// Now convert to NSData structure to make it usable again
	NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
	// description converts to hex but puts <> around it and spaces every 4 bytes
	NSString *hash = [out description];
	hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
	
	return hash;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.offexploringData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [offexploringData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"No Connection Error", @"Error message displayed when not connected to the Internet.")};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        if ([delegate respondsToSelector:@selector(offexploringConnection:didFireError:)]) {
			[delegate offexploringConnection:self didFireError:noConnectionError];
		}
    } else {
        // otherwise handle the error generically
		if ([delegate respondsToSelector:@selector(offexploringConnection:didFireError:)]) {
			[delegate offexploringConnection:self didFireError:error];
		}
    }
    self.offexploringConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.offexploringConnection = nil;
	
	NSString *jsonString = [[NSString alloc] initWithData:offexploringData encoding:NSUTF8StringEncoding];
	NSDictionary *results = [jsonString JSONValue];
	NSDictionary *status = results[@"status"];
	int statusCode = [status[@"status"] intValue];
	int successCode = 200;
	if (statusCode == successCode) {
		[delegate offexploringConnection:self resultSet:results];
	}
	// Site in maintainence mode.
	else if (statusCode == 400  && [status[@"errormessage"] isEqualToString:@"site_read_only_enabled"]) {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"System upgrade in progress.\n You can save drafts but not publish content to your blog at the moment. Please try again later. Sorry for the inconvenience.", @"Maintenance Mode Enabled"), @"results": results};
        NSError *maintenanceMode = [NSError errorWithDomain:NSCocoaErrorDomain code:-10000 userInfo:userInfo];
		if ([delegate respondsToSelector:@selector(offexploringConnection:didFireError:)]) {
			[delegate offexploringConnection:self didFireError:maintenanceMode];
		}
	}
	else if (statusCode == 401 && [status[@"errormessage"] isEqualToString:@"Incorrect Partner Request"] && [delegate isKindOfClass:[RootViewController class]]) {
		RootViewController *theDelegate = (RootViewController *)delegate;
		theDelegate.failGracefully = YES;
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Request Error", @"An error has occurred, please retry connection"), @"results": results};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:-10000 userInfo:userInfo];
		if ([delegate respondsToSelector:@selector(offexploringConnection:didFireError:)]) {
			[delegate offexploringConnection:self didFireError:noConnectionError];
		}
	}
	else {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Request Error", @"An error has occurred, please retry connection"), @"results": results};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:-10000 userInfo:userInfo];
		if ([delegate respondsToSelector:@selector(offexploringConnection:didFireError:)]) {
			[delegate offexploringConnection:self didFireError:noConnectionError];
		}
	}
}

@end
