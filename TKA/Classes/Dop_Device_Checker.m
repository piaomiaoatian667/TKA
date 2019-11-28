//
//  KV_Device_Checker.m
//  KV_ADsdk
//
//  Created by vampire on 4/23/14.
//  Copyright (c) 2014 vampire. All rights reserved.
//

#import "Dop_Device_Checker.h"
#import <SystemConfiguration/CaptiveNetwork.h> 
@interface Dop_Device_Checker()
@end
@implementation Dop_Device_Checker
@synthesize k_Detail,k_Screen,k_System_model,k_System_version,k_User_name,k_UUid;

-(id)init
{
    self=[super init];
    if (self) {
        k_Screen=[Dop_Device_Checker GetDevice_Screen];
        k_System_version=[Dop_Device_Checker GetDevice_System_version];
        k_System_model=[Dop_Device_Checker GetDevice_System_model];
        k_User_name=[Dop_Device_Checker GetDevice_User_name];
        k_Detail=[Dop_Device_Checker GetDevice_Detail];
        k_UUid=[Dop_Device_Checker GetDevice_UUID];
    }
    return self;
}
+(NSString*)GetDevice_UUID
{
    NSString *uuid=[[UIDevice currentDevice].identifierForVendor UUIDString];
    if (uuid) {
        return uuid;
    }else{
        return @"uuid error";
    }
}
+(NSString*)GetDevice_Screen
{
    NSString *screen_type;
    int weigth=[[UIScreen mainScreen] bounds].size.width;
    int height=[[UIScreen mainScreen] bounds].size.height;
    if (weigth==320 && height==480) {
        screen_type=@"320*480";
        return screen_type;
    }else{
        screen_type=@"no device detected";
        return screen_type;
    }
}

+(NSString*)GetDevice_User_name
{
    NSString *user_name;
    user_name=[[UIDevice currentDevice] name];
    if (user_name!=nil) {
        return user_name;
    }else{
        return @"no name";
    }
}

+(NSString*)GetDevice_System_version
{
    NSString *system_version;
    system_version=[[UIDevice currentDevice] systemVersion];
    if (system_version) {
        return system_version;
    }else{
        return @"error";
    }
}

+(NSString *)GetDevice_System_model
{
    NSString *model;
    model=[[UIDevice currentDevice]model];
    if (model) {
        return model;
    }else
    {
        return @"error";
    }
}

+(NSString *)GetDevice_Detail
{
    NSString *screen=[self GetDevice_Screen];
    NSString *model=[self GetDevice_System_model];
    if ([screen isEqualToString:@"320*480"] && [model isEqualToString:@"iPhone"]) {
        return @"iphone_4s";
    }else{
        return @"error";
    }
}

+(NSString *)Fetch_SSID
{
    NSString *ssID = @"Not Found";
    NSString *macIP = @"Not Found";
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary *)CFBridgingRelease(myDict);
            ssID = [dict objectForKey:@"SSID"];
            macIP = [dict objectForKey:@"BSSID"];
        }
    }
    
    return macIP;
}

@end
