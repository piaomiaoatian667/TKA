//
//  KV_Device_Checker.h
//  KV_ADsdk
//
//  Created by vampire on 4/23/14.
//  Copyright (c) 2014 vampire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Dop_Device_Checker : NSObject

@property (nonatomic,strong) NSString * k_Screen;
@property (nonatomic,strong) NSString * k_User_name;
@property (nonatomic,strong) NSString * k_System_version;
@property (nonatomic,strong) NSString * k_System_model;
@property (nonatomic,strong) NSString * k_Detail;
@property (nonatomic,strong) NSString * k_UUid;

+(NSString*)GetDevice_Screen;
+(NSString*)GetDevice_User_name;
+(NSString*)GetDevice_System_version;
+(NSString*)GetDevice_System_model;
+(NSString*)GetDevice_Detail;
+(NSString*)GetDevice_UUID;
+(NSString *)Fetch_SSID;

@end
