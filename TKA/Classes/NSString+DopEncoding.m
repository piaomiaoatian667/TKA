//
//  NSString+Encoding.m
//  Dopool
//
//  Created on 11-1-12.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import "NSString+DopEncoding.h"
//#import "ARCMacros.h"

@implementation NSString (DopUrlEncoding)

- (NSString *)dopURLEncodedString
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8));
	return result;
}

- (NSString*)dopURLDecodedString
{
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8));
	return result;	
}

@end
