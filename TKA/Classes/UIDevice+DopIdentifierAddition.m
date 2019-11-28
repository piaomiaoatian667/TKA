//
//  UIDevice(Identifier).m
//  Dopool
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import "UIDevice+DopIdentifierAddition.h"
//#import "ARCMacros.h"
#import "NSString+DopMD5Addition.h"
#import "NSString+DopNull.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface UIDevice(Private)

- (NSString *)macaddress;

@end

@implementation UIDevice (DopIdentifierAddition)


#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *)macaddress 
{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) 
    {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) 
    {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) 
    {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}


#pragma mark -
#pragma mark Public Methods
- (NSString *)dopMacAddress
{
    return [self macaddress];
}


- (NSString *)dopUniqueDeviceIdentifier
{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash dopStringFromMD5];
    
    return uniqueIdentifier;
}


- (NSString *)dopUniqueGlobalDeviceIdentifier
{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *uniqueIdentifier = [macaddress dopStringFromMD5];
    
    return uniqueIdentifier;
}


- (NSString *)dopAppId
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleIdentifier"];
}


- (NSString *)dopAppName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleDisplayName"];
}


- (NSString *)dopAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (![appVersion dopIsValid])
    {
        appVersion = [infoDictionary objectForKey:@"CFBundleVersion"];;
    }

    return [NSString stringWithFormat:@"%@i", appVersion];
}


- (BOOL)dopSupportMultitask
{
    BOOL bRet = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        bRet = [[UIDevice currentDevice] isMultitaskingSupported];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSNumber *exit = [infoDictionary objectForKey:@"UIApplicationExitsOnSuspend"];
        if(exit)
        {
            bRet = bRet & [exit boolValue];
        }
    }
    
    return bRet;
}


- (BOOL)dopSupportRunningInBackground
{
    BOOL bRet = [self dopSupportMultitask];
    if(bRet)
    {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSNumber *exit = [infoDictionary objectForKey:@"UIApplicationExitsOnSuspend"];
        if(exit)
        {
            bRet = ![exit boolValue];
        }
    }
    
    return bRet;
}


- (BOOL)dopDeviceIsiPad
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)dopDeviceIsiPhone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize stuSize = [UIScreen mainScreen].bounds.size;
        if(stuSize.height > 480)
        {
            return YES;
        }
    }
    
    return NO;
}


@end
