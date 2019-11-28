//
//  NSDate+BJZone.h
//  Dopool
//
//  Created by lb l on 12-5-16.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

//#import <Foundation/Foundation.h>
@import Foundation;

// Define Beijing time zone.(8 * 60 * 60 = 28800)
#define SECONDS_BJ_ZONE  (28800)

@interface NSDate (DopBJZone)

+ (NSTimeZone *)dopBJTimeZone;
+ (NSDate *)dopCurrentBJDate;
+ (id)dopBJDateWithTimeIntervalSince1970:(NSTimeInterval)secs;
+ (NSString *)dopCurrentBJDate:(NSString *)format;
+ (double)dopTimeIntervalSince1970WithBJZone;
+ (double)dopTimeIntervalSince1970WithBJZone:(NSString *)strDate;
+ (NSDateComponents *)dopCurrentBJDateComponents;
+ (NSDateComponents *)dopBJDateComponentsWithTimeIntervalSince1970:(NSTimeInterval)secs;
+ (NSString *)dopTimestampConvertTimeStr:(double)timestamp Format:(NSString *)format;

@end
