//
//  Message.m
//  Off Exploring
//
//  Created by Ian Outterside on 07/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import "OFXMessage.h"

@interface OFXMessage()
- (NSString *)flattenHTML:(NSString *)html;
@end

@implementation OFXMessage

@synthesize messageId;
@synthesize body;
@synthesize timestamp;
@synthesize guestname;
@synthesize email;
@synthesize trip;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        NSString *string = [[NSString alloc] initWithString:dictionary[@"guestname"]];
        self.guestname = string;
        
        string =  [[NSString alloc] initWithString:dictionary[@"email"]];
        self.email = string;
        
        string =  [[NSString alloc] initWithString:dictionary[@"body"]];
        self.body = [self flattenHTML:string];
        
        NSNumber *number = [[NSNumber alloc] initWithInt:[dictionary[@"id"] intValue]];
        self.messageId =  number;
        
        self.timestamp = [dictionary[@"timestamp"] doubleValue];
    }
    
    return self;
}

- (NSString *)flattenHTML:(NSString *)html {
	
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
											   withString:@""];
		
    } // while //
    return html;	
}


@end
