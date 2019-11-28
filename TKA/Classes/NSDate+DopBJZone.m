//
//  NSDate+BJZone.m
//  Dopool
//
//  Created by lb l on 12-5-16.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import "NSDate+DopBJZone.h"
//#import "ARCMacros.h"

@implementation NSDate (DopBJZone)

+ (NSTimeZone *)dopBJTimeZone
{
    return [NSTimeZone timeZoneForSecondsFromGMT:SECONDS_BJ_ZONE];
}


+ (NSDate *)dopCurrentBJDate
{
    NSTimeZone *defaultTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:SECONDS_BJ_ZONE];
    [NSTimeZone setDefaultTimeZone:defaultTimeZone];
    return [NSDate date];
}


+ (id)dopBJDateWithTimeIntervalSince1970:(NSTimeInterval)secs
{
    NSTimeZone *defaultTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:SECONDS_BJ_ZONE];
    [NSTimeZone setDefaultTimeZone:defaultTimeZone];
    return [NSDate dateWithTimeIntervalSince1970:secs];
}


+ (NSString *)dopCurrentBJDate:(NSString *)format
{
    if(!format || 0 == [format length])
    {
        return nil;
    }
    
    if ([[NSTimeZone defaultTimeZone].name isEqualToString:@"GMT+0800"] == NO) {
        
        NSTimeZone *defaultTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:SECONDS_BJ_ZONE];
        [NSTimeZone setDefaultTimeZone:defaultTimeZone];
        
    }

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *currentDate = [dateFormatter stringFromDate:date];
//    SAFE_ARC_RELEASE(dateFormatter);
    
    return currentDate;
}


+ (double)dopTimeIntervalSince1970WithBJZone
{
    NSTimeZone *defaultTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:SECONDS_BJ_ZONE];
    [NSTimeZone setDefaultTimeZone:defaultTimeZone];
    
    return [[NSDate date] timeIntervalSince1970];
}


+ (double)dopTimeIntervalSince1970WithBJZone:(NSString *)strDate
{
    NSString *strformat = @"yy/MM/dd HH:mm";
    NSRange stuRange = [strDate rangeOfString:@":"];
    if(NSNotFound == stuRange.location)
    {
        return 0;
    }
    
    if(stuRange.length > 0)
    {
        stuRange = [[strDate substringFromIndex:stuRange.location + 1] rangeOfString:@":"];
        if(stuRange.location != NSNotFound)
        {
            strformat = @"yy/MM/dd HH:mm:ss";
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:strformat]; 
    [dateFormatter setTimeZone:[NSDate dopBJTimeZone]];
    NSDate *date = [dateFormatter dateFromString:strDate];
//    SAFE_ARC_RELEASE(dateFormatter);
    
    if(!date)
    {
        return 0;
    }
    
    return [date timeIntervalSince1970];
}


+ (NSDateComponents *)dopCurrentBJDateComponents
{
    NSTimeZone *defaultTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:SECONDS_BJ_ZONE];
    [NSTimeZone setDefaultTimeZone:defaultTimeZone];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    return dateComponents;
}


+ (NSDateComponents *)dopBJDateComponentsWithTimeIntervalSince1970:(NSTimeInterval)secs
{
    NSTimeZone *defaultTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:SECONDS_BJ_ZONE];
    [NSTimeZone setDefaultTimeZone:defaultTimeZone];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSince1970:secs]];
    return dateComponents;
}


+ (NSString *)dopTimestampConvertTimeStr:(double)timestamp Format:(NSString *)format
{
    NSTimeZone *defaultTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:SECONDS_BJ_ZONE];
    [NSTimeZone setDefaultTimeZone:defaultTimeZone];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    NSString *strTime = [dateFormatter stringFromDate:date];
//    SAFE_ARC_RELEASE(dateFormatter);
    
    return strTime;
}
@end
