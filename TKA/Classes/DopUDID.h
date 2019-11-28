//
//  DopUDID.h
//  Dopool
//
//  Created by zzg on 13-3-26.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

//#import <Foundation/Foundation.h>
@import Foundation;
#define kDopUDIDErrorNone          0
#define kDopUDIDErrorOptedOut      1
#define kDopUDIDErrorCompromised   2

@interface DopUDID : NSObject

+ (NSString *)getUDID;
+ (NSString *)getOpenId:(NSError **)error;

@end
