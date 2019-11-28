//
//  NSString+MD5Addition.m
//  Dopool
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import "NSString+DopMD5Addition.h"
#import <CommonCrypto/CommonDigest.h>
//#import "ARCMacros.h"

@implementation NSString (DopMD5Addition)

- (NSString *) dopStringFromMD5
{
    
    if(!self || 0 == [self length])
    {
        return nil;
    }
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (unsigned int)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) 
    {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
//    return SAFE_ARC_AUTORELEASE(outputString);
    return outputString;
}


@end
