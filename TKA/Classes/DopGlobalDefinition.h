//
//  DopGlobalDefinition.h
//  Dopool
//
//  Created by Dopool on 13-4-1.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

//#import <Foundation/Foundation.h>
@import Foundation;

typedef enum {
    DopAPI1 = 0,
    DopAPI2 = 1,
} DopURLAddress;

#define STR_UNITE(x,y)  [(x) stringByAppendingString:(y)]

// Define cms host url
extern NSString *DOP_APP_KEY;

// Define cms host url
extern NSString *DOP_DID;

// Define loading image 
extern NSString *DOP_LOADING_IMG;

// Define cms host url
extern NSString *DOP_URL_CMS_HOST;

// Define cms url
extern NSString *DOP_URL_CMS;

// Define passport URL
extern NSString *DOP_URL_PASSPORT;

// Define ad url
extern NSString *DOP_URL_AD;

// Define http User-Agent
#define DOP_USER_AGENT      @"DopUserAgent"


@interface DopGlobalDefinition : NSObject

+ (void)modifyURL:(DopURLAddress) urlAddress;

@end
