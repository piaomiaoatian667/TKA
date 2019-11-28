//
//  DopUDID.m
//  Dopool
//
//  Created by zzg on 13-3-26.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "DopUDID.h"
//#import "DebugMacros.h"
//#import "ARCMacros.h"
#import "NSString+DopMD5Addition.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@import UIKit;
//#import <UIKit/UIPasteboard.h>
//#import <UIKit/UIKit.h>
#else
#import <AppKit/NSPasteboard.h>
#endif

static NSString *kDopUDIDSessionCache = nil;
static NSString * const kDopUDIDDescription = @"DopUDID_with_iOS6_Support";
static NSString * const kDopUDIDKey = @"DopUDID";
static NSString * const kDopUDIDSlotKey = @"DopUDID_slot";
static NSString * const kDopUDIDAppUIDKey = @"DopUDID_appUID";
static NSString * const kDopUDIDTSKey = @"DopUDID_createdTS";
static NSString * const kDopUDIDOOTSKey = @"DopUDID_optOutTS";
static NSString * const kDopUDIDDomain = @"com.dopool";
static NSString * const kDopUDIDSlotPBPrefix = @"com.dopool.www";
static int const kOpenUDIDRedundancySlots = 100;

@interface DopUDID (Private)

+ (void)setDict:(id)dict forPasteboard:(id)pboard;
+ (NSMutableDictionary *)getDictFromPasteboard:(id)pboard;
+ (NSString *)generateFreshOpenUDID;
+ (void)setOptOut:(BOOL)optOutValue;

@end

@implementation DopUDID


#pragma mark -
#pragma mark Public Function
+ (NSString *)getUDID
{
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}


#pragma mark -
#pragma mark Private Function
+ (void)setDict:(id)dict forPasteboard:(id)pboard
{
    #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forPasteboardType:[kDopUDIDDomain dopStringFromMD5]];
    #else
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forType:[kDopUDIDDomain stringFromMD5]];
    #endif
}


+ (NSMutableDictionary *)getDictFromPasteboard:(id)pboard
{
    #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    id item = [pboard dataForPasteboardType:[kDopUDIDDomain dopStringFromMD5]];
    #else
	id item = [pboard dataForType:[kDopUDIDDomain stringFromMD5]];
    #endif
    if (item)
    {
        @try
        {
            item = [NSKeyedUnarchiver unarchiveObjectWithData:item];
        }
        @catch(NSException *e)
        {
//            NSLog(@"Unable to unarchive item %@ on pasteboard!", [pboard name]);
            item = nil;
        }
    }
    
    if(item && [item isKindOfClass:[NSDictionary class]])
    {
        return [NSMutableDictionary dictionaryWithDictionary:item];
    }
    
    return nil;
}


+ (NSString *)generateFreshOpenUDID
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"useOpenID"];
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring, CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    CFRelease(uuid);
    CFRelease(cfstring);
    
    // Generate 40 hex string.
    NSString *openUDID = [NSString stringWithFormat:
                          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                          result[0], result[1], result[2], result[3],
                          result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11],
                          result[12], result[13], result[14], result[15],
                          (unsigned long)(arc4random() % NSUIntegerMax)];
    
    return openUDID;
}


+ (NSString *)getOpenId:(NSError **)error
{
    if (kDopUDIDSessionCache != nil)
    {
        if (error != nil)
        {
            *error = [NSError errorWithDomain:kDopUDIDDomain
                                         code:kDopUDIDErrorNone
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"DopUDID in cache from first call", @"description", nil]];
        }
        
        // Return oudid in merroy.
        return kDopUDIDSessionCache;
    }
    
    // Check whether oudid exists in standardUserDefaults.
  	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appUID = [defaults objectForKey:[kDopUDIDAppUIDKey dopStringFromMD5]];
    if(!appUID)
    {
        // Generate the temp oudid.
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        appUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        CFRelease(uuid);
//        SAFE_ARC_AUTORELEASE(appUID);
    }
    
    NSString *openUDID = nil;
    NSString *myRedundancySlotPBid = nil;
    NSDate *optedOutDate = nil;
    BOOL optedOut = NO;
    BOOL saveLocalDictToDefaults = NO;
    BOOL isCompromised = NO;
    
    // Check whether the oudid info exists in standardUserDefaults.
    id localDict = [defaults objectForKey:[kDopUDIDKey dopStringFromMD5]];
    if ([localDict isKindOfClass:[NSDictionary class]])
    {
        localDict = [NSMutableDictionary dictionaryWithDictionary:localDict];
        openUDID = [localDict objectForKey:[kDopUDIDKey dopStringFromMD5]];
        myRedundancySlotPBid = [localDict objectForKey:[kDopUDIDSlotKey dopStringFromMD5]];
        optedOutDate = [localDict objectForKey:[kDopUDIDOOTSKey dopStringFromMD5]];
        optedOut = optedOutDate ? YES : NO;
    }
    
    NSString *availableSlotPBid = nil;
    NSMutableDictionary *frequencyDict = [NSMutableDictionary dictionaryWithCapacity:kOpenUDIDRedundancySlots];
    for (int n = 0; n < kOpenUDIDRedundancySlots; n++)
    {
        // Find the available pasteboard that is unused or worry content.
        NSString *slotPBid = [NSString stringWithFormat:@"%@%d",[kDopUDIDSlotPBPrefix dopStringFromMD5], n];
        #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIPasteboard *slotPB = [UIPasteboard pasteboardWithName:slotPBid create:NO];
        #else
        NSPasteboard *slotPB = [NSPasteboard pasteboardWithName:slotPBid];
        #endif
        
        if (!slotPB)
        {
            // The pasteboard is unused.
            if (!availableSlotPBid)
            {
                // Find the first unused pasteboard.
                availableSlotPBid = slotPBid;
            }
        }
        else
        {
            NSDictionary *dict = [self getDictFromPasteboard:slotPB];
            NSString *oudid = [dict objectForKey:[kDopUDIDKey dopStringFromMD5]];
            if (!oudid)
            {
                // The content of pasteboard is worry.
                if (!availableSlotPBid)
                {
                    // Find the first pasteboard whose content is worry.
                    availableSlotPBid = slotPBid;
                }
            }
            else
            {
                // Save the used frequency.
                int count = [[frequencyDict valueForKey:oudid] intValue];
                [frequencyDict setObject:[NSNumber numberWithInt:++count] forKey:oudid];
            }

            NSString *gid = [dict objectForKey:[kDopUDIDAppUIDKey dopStringFromMD5]];
            if (gid != nil && [gid isEqualToString:appUID])
            {
                // Find the real redundancy pasteboard and save it.
                myRedundancySlotPBid = slotPBid;
                if (optedOut)
                {
                    optedOutDate = [dict objectForKey:[kDopUDIDOOTSKey dopStringFromMD5]];
                    optedOut = optedOutDate ? YES : NO;
                }
            }
        }
    }
    
    // Sort oudid by frequency used, and find the most reliable oudid.
    NSArray *arrayOfUDIDs = [frequencyDict keysSortedByValueUsingSelector:@selector(compare:)];
    NSString *mostReliableOpenUDID = nil;
    if(arrayOfUDIDs && [arrayOfUDIDs count] > 0)
    {
        mostReliableOpenUDID = [arrayOfUDIDs lastObject];
    }

    if (!openUDID)
    {
        if (!mostReliableOpenUDID)
        {
            openUDID = [self generateFreshOpenUDID];
        }
        else
        {
            openUDID = mostReliableOpenUDID;
        }

        if (!localDict)
        {
            // Save the oudid info in the local.
            localDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [localDict setObject:openUDID forKey:[kDopUDIDKey dopStringFromMD5]];
            [localDict setObject:appUID forKey:[kDopUDIDAppUIDKey dopStringFromMD5]];
            [localDict setObject:[NSDate date] forKey:[kDopUDIDTSKey dopStringFromMD5]];
            if (optedOut)
            {
                [localDict setObject:optedOutDate forKey:[kDopUDIDTSKey dopStringFromMD5]];
            }
                
            saveLocalDictToDefaults = YES;
        }
    }
    else
    {
        if (mostReliableOpenUDID && ![mostReliableOpenUDID isEqualToString:openUDID])
        {
            isCompromised = YES;
        }
    }
    
    if (availableSlotPBid && (!myRedundancySlotPBid || [availableSlotPBid isEqualToString:myRedundancySlotPBid]))
    {
        #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIPasteboard *slotPB = [UIPasteboard pasteboardWithName:availableSlotPBid create:YES];
        // Persistent data.
        [slotPB setPersistent:YES];
        #else
        NSPasteboard *slotPB = [NSPasteboard pasteboardWithName:availableSlotPBid];
        #endif
        
        if (localDict)
        {
            [localDict setObject:availableSlotPBid forKey:[kDopUDIDSlotKey dopStringFromMD5]];
            saveLocalDictToDefaults = YES;
        }
        
        if (openUDID && localDict)
        {
            // Save the oudid info in the posteboard.
            [self setDict:localDict forPasteboard:slotPB];
        }
    }
    
    if (localDict && saveLocalDictToDefaults)
    {
        // Save the oudid info in the standardUserDefaults, becase pasteboard Changed.
        [defaults setObject:localDict forKey:[kDopUDIDKey dopStringFromMD5]];
    }

    if (optedOut)
    {
        if (error != nil)
        {
            *error = [NSError errorWithDomain:kDopUDIDDomain
                                         code:kDopUDIDErrorOptedOut
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Application with unique id %@ is opted-out from OpenUDID as of %@",appUID,optedOutDate],@"description", nil]];
        }
        
        kDopUDIDSessionCache = [NSString stringWithFormat:@"%040x", 0];
//        SAFE_ARC_RETAIN(kDopUDIDSessionCache);
        return kDopUDIDSessionCache;
    }
    
    if (error != nil)
    {
        if (isCompromised)
        {
            *error = [NSError errorWithDomain:kDopUDIDDomain
                                         code:kDopUDIDErrorCompromised
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Found a discrepancy between stored OpenUDID (reliable) and redundant copies; one of the apps on the device is most likely corrupting the OpenUDID protocol",@"description", nil]];
        }
        else
        {
            *error = [NSError errorWithDomain:kDopUDIDDomain
                                         code:kDopUDIDErrorNone
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"OpenUDID succesfully retrieved",@"description", nil]];
        }
    }
    
//    kDopUDIDSessionCache = SAFE_ARC_RETAIN(openUDID);
    kDopUDIDSessionCache=openUDID;
    return kDopUDIDSessionCache;
}


+ (void)setOptOut:(BOOL)optOutValue
{
    [self getUDID];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    id dict = [defaults objectForKey:[kDopUDIDKey dopStringFromMD5]];
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    else
    {
        dict = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    
    if (optOutValue)
    {
        [dict setObject:[NSDate date] forKey:[kDopUDIDOOTSKey dopStringFromMD5]];
    }
    else
    {
        [dict removeObjectForKey:[kDopUDIDOOTSKey dopStringFromMD5]];
    }
    [defaults setObject:dict forKey:[kDopUDIDKey dopStringFromMD5]];
    
    // Reset memory cache 
    kDopUDIDSessionCache = nil;
}


@end
