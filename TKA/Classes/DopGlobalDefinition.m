//
//  DopGlobalDefinition.m
//  Dopool
//
//  Created by l lb on 13-4-1.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import "DopGlobalDefinition.h"

NSString *DOP_APP_KEY = @"W1NRxcDVPt9K";

NSString *DOP_DID = nil;

NSString *DOP_LOADING_IMG = nil;

NSString *DOP_URL_CMS_HOST = @"https://api.dopool.com";
//NSString *DOP_URL_CMS_HOST = @"http://114.112.84.135/cmsapiv2";

NSString *DOP_URL_CMS = @"https://cms.dopool.com/apiv3/api.php";
//NSString *DOP_URL_CMS = @"http://cms.doplive.com.cn/Dopool/api.php";
//NSString *DOP_URL_CMS = @"http://114.112.84.135/cmsv301/apiv3/api.php";

NSString *DOP_URL_PASSPORT = @"https://userapi.dopool.com";
//NSString *DOP_URL_PASSPORT = @"http://114.112.84.135/passport/api.php";

NSString *DOP_URL_AD = @"https://ad.dopool.com/ad/Adv/api.php";
//NSString *DOP_URL_AD = @"http://114.112.84.134/ad/Adv/api.php";

@implementation DopGlobalDefinition

+ (void)modifyURL:(DopURLAddress) urlAddress
{
    if (urlAddress == 1)
    {
        DOP_URL_CMS_HOST = @"https://api2.dopool.com";
        DOP_URL_PASSPORT = @"https://userapi2.dopool.com";
        DOP_URL_AD = @"https://ad2.dopool.com/ad/Adv/api.php";
    }
    else
    {
        DOP_URL_CMS_HOST = @"https://api.dopool.com";
        DOP_URL_PASSPORT = @"https://userapi.dopool.com";
        DOP_URL_AD = @"https://ad.dopool.com/ad/Adv/api.php";
    }
}

@end
