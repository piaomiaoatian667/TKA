//
//  NSString+Null.m
//  Dopool
//
//  Created by l lb on 13-1-29.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import "NSString+DopNull.h"
//#import "ARCMacros.h"

@implementation NSString (DopNull)

+ (BOOL)dopStringIsEmpty:(NSString *)string
{
    if(!string || [string isEqual:[NSNull null]] || ![string isKindOfClass:[NSString class]])
    {
        return YES;
    }
    
    if (0 == [string length])
    {
        return YES;
    }
    else
    {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(0 == [string length])
        {
            return YES;
        }
    }
    
    return NO;
}


+ (BOOL)dopStringIsInvalid:(NSString *)string
{
    if(!string || [string isEqual:[NSNull null]] || ![string isKindOfClass:[NSString class]])
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)dopIsValid
{
    return ![NSString dopStringIsEmpty:self];
}


- (BOOL)dopIsValidUrl
{
    if([NSString dopStringIsEmpty:self])
    {
        return NO;
    }
    
    NSURL *url = [NSURL URLWithString:self];
    if(url && url.scheme && url.host)
    {
        return YES;
    }
    
    return NO;
}


@end
