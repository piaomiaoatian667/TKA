//
//  CCCheckUDID.m
//  Dopool
//
//  Created by zzg on 13-4-7.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import "DopCheckUDID.h"
#import "DopUDID.h"
//#import "ARCMacros.h"
//#import "DebugMacros.h"
#import "DopTrack.h"
#define SYS_VER_GREATER_OR_EQUAL(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= (version))

@interface DopCheckUDID()

+ (void)changeDopUDID:(NSString *)strDopUDID forUUID:(NSString *)strUUID;

@end

@implementation DopCheckUDID




#pragma mark - 
#pragma mark Public Function
+ (void)checkUDID
{
    if(!SYS_VER_GREATER_OR_EQUAL(6.0))
    {
        return;
    }

    BOOL bUseOpenId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useOpenID"] boolValue];
    if (!bUseOpenId)
    {
        return;
    }
    
    NSString *openUDID = [DopUDID getOpenId:nil];
    NSString *deviceUUID = [[UIDevice currentDevice].identifierForVendor UUIDString];
    [self changeDopUDID:openUDID forUUID:deviceUUID];
}


#pragma mark - 
#pragma mark Private Function
+ (void)changeDopUDID:(NSString *)strDopUDID forUUID:(NSString *)strUUID
{
    if ((!strDopUDID && [strDopUDID length] < 1) || (!strUUID && [strUUID length] < 1))
    {
        return;
    }

    NSMutableDictionary *dicChangeValue = [[NSMutableDictionary alloc] initWithObjectsAndKeys:strDopUDID,@"pastUDID",strUUID,@"nowUDID", nil];
    [DopTrack event:@"UDIDChanged" attributes:dicChangeValue];
}


@end
