//
//  KVTrack.m
//  real_app1
//
//  Created by vampire on 3/27/14.
//  Copyright (c) 2014 vampire. All rights reserved.
//

#import "DopTrack.h"
#import "DopTrackConst.h"
#import "NSString+DopNull.h"
#import "DopoolReachability.h"
#import "DopBase64.h"
#import "NSData+DopGZipAdditions.h"
#import "NSDate+DopBJZone.h"
#import "UIDevice+DopIdentifierAddition.h"
#import "DopUDID.h"
#import "DopTrackLib.h"
#import "DopGlobalDefinition.h"
#import "NSString+DopEncoding.h"
#import "DopCheckUDID.h"
#import "Dop_Device_Checker.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#define LOGPAGE_SEC (0)
#define LOGPAGE_END (1)
#define SEND_KEEPALIVE_INTERVAL (8 * 60 * 60)
#define ReachabilityChangedNotification @"ReachabilityChangedNotification"
#define SYS_VER_GREATER_OR_EQUAL(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= (version))
@interface TrackUrlConnection : NSURLConnection
{
    NSString        *m_Input;
    NSMutableData   *m_NetData;
    NSArray         *m_Results;
}

@property (nonatomic, strong) NSString        *m_Input;
@property (nonatomic, strong) NSMutableData   *m_NetData;
@property (nonatomic, strong) NSArray         *m_Results;

@end


@interface DopTrack() <NSURLSessionDelegate>
{
    @private
    NSTimer *m_Timer;
}

//+ (KVTrack *)defaultDopTracker;
+ (void)logPageView:(NSString *)pageName seconds:(int)seconds iLogPageType:(int)iLogPageType;
+ (void)beginEventOrPage:(NSString *)eventIdOrPageView;
+ (void)event:(NSString *)eventId paraDic:(NSDictionary *)paraDic;
+ (void)event:(NSString *)eventId durations:(float)second paraDic:(NSDictionary *)paraDic;
+ (BOOL)checkSendData:(ReportPolicy)reportPolicy;
- (void)postServer:(NSString *)jsonStr ifDelegate:(BOOL)bDelegate ifRunLoopRun:(BOOL)bRunLoopRun;
- (void)postDic:(NSDictionary *)trackerDic ifDelegate:(BOOL)bDelegate;
- (void)saveDic:(NSDictionary *)trackerDic;
- (NSString *)addOSInfo:(NSDictionary *)trackerDic;
- (NSDictionary *)getOSInfo;
+ (void)startSendThread;
- (void)sendTrackerData:(NSNumber *)maxNumber;
- (void)reachabilityChanged:(NSNotification *)notification;
- (void)trackExitApp;
- (void)delayTrackingExitApp;
- (void)stopRunLoop;
- (void)checkUDID;
- (void)startKeepalive;
- (void)sendKeepalive;
@end

static double dAppStartTime = 0.0;
static NSMutableDictionary *trackerDic = nil;
static NSString *SessionId = nil;
static NSString *Referer = nil;
static NSString *Appkey = nil;
static NSString *InstallDate = nil;
static long int OrderNum = 1;
static long int iDoid = 0;
static NSDictionary *OSInfoDic = nil;
static DopTrack *defaultDopTracker = nil;
static int iReportPolicy = BATCH;//batch
static NSString *MarketId = nil;
static NSThread *sendThread = nil;
static NSMutableArray *trackerList = nil;
static int networkStatus = NotReachable;
static BOOL bThreadStart = NO;
static BOOL bReachabilityChangedNotification = NO;


@implementation DopTrack

- (void)setDefaultTrackURLStr{
    
//    self.trackURLStr = @"http://analytics3.dopool.com/index.php?m=Api&a=saveAction&e=iphone&data=";
//    self.trackURLStr = @"http://223.100.130.230/cms_sdk/html/app.gif?m=Api&a=saveAction&e=android&data=";
    self.trackURLStr = @"https://ana4.dopool.com/app.gif?m=Api&a=saveAction&e=iphone&data=";
    
}

- (void)setInnerTrackURLStr{
    
   self.trackURLStr = @"www.baidu.com";
    
}

- (void)setUploadAddressWithURLStr:(NSString *)urlStr{
    
    self.trackURLStr = urlStr;
    
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:ReachabilityChangedNotification
                                                   object:nil];
        
        bReachabilityChangedNotification = YES;
    }
    
    return self;
}

+ (void)startWithAppkey:(NSString *)appKey
{
    [DopTrack startWithAppkey:appKey reportPolicy:BATCH marketId:nil];
}

- (void)startWithAppkey:(NSString *)appKey reportPolicy:(ReportPolicy)rp marketId:(NSString *)mid{
    
    if(![appKey dopIsValid])
    {
        NSLog(@"[ERROR] App key is invalid.");
        return;
    }
    
    defaultDopTracker = [DopTrack defaultDopTracker];
    
    iReportPolicy = rp;
    
    if(Appkey)
    {
        
    }
    Appkey = [[NSString alloc] initWithFormat:@"%@", appKey];/*ios_*/
    
    if(MarketId)
    {
        
    }
    MarketId = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@",mid]];
    
    srandom((int)time(0));
    int iRandom = random() % 100000;
    SessionId = [NSString stringWithFormat:@"%d%f",iRandom,[NSDate dopTimeIntervalSince1970WithBJZone]];
    
    dAppStartTime = [NSDate dopTimeIntervalSince1970WithBJZone];
    OrderNum = 1;
    NSString *playId = [NSString stringWithFormat:@"%ld", OrderNum++];
    
    iDoid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"track_doid"] intValue];
    if (0 == iDoid)
    {
        iDoid = 1;
    }
    else
    {
        iDoid++;
    }
    
    NSString *doId = [NSString stringWithFormat:@"%ld", iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    if(Referer)
    {
        
    }
    Referer = @"none";
    
    if (!trackerDic)
    {
        trackerDic = [[NSMutableDictionary alloc] init];
    }
    
    NSDictionary *dic = nil;
    NSString *startTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *preVsion = [[NSUserDefaults standardUserDefaults] objectForKey:@"track_prevsion"];
    if (!preVsion || 0 == [preVsion length])
    {
        preVsion = @"none";
    }
    
    NSString *curVsion = [[UIDevice currentDevice] dopAppVersion];
    if ([curVsion isEqualToString:preVsion])
    {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"applicationstart", @"action_type", startTime, @"startdt", Referer, @"referer", nil];
    }
    else
    {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"applicationstart", @"action_type", startTime, @"startdt", Referer, @"referer", preVsion, @"previousversion", nil];
        
        [[NSUserDefaults standardUserDefaults] setValue:curVsion forKey:@"track_prevsion"];
    }
    
    [defaultDopTracker startKeepalive];
    
    // Track launch app.
    if ([DopTrack checkSendData:REALTIME])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
    
    [defaultDopTracker performSelector:@selector(checkUDID) withObject:nil afterDelay:10];
    
    // Send the last data tracked.
    if ([DopTrack checkSendData:REALTIME])
    {
        trackerList = [[NSMutableArray alloc] initWithCapacity:0];
        // 30 - 0.5
        [self performSelector:@selector(startSendThread) withObject:self afterDelay:0.5];
    }
    // 禁用退出
//    [[NSNotificationCenter defaultCenter] addObserver:[DopTrack defaultDopTracker]
//                                             selector:@selector(trackExitApp)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:[UIApplication sharedApplication]];
    
}

+ (void)startWithAppkey:(NSString *)appKey reportPolicy:(ReportPolicy)rp marketId:(NSString *)mid
{
    [self startWithAppkey:appKey reportPolicy:rp marketId:mid];
    
    /*
    if(![appKey isValid])
    {
        NSLog(@"[ERROR] App key is invalid.");
        return;
    }
    
    defaultDopTracker = [KVTrack defaultDopTracker];
    
    iReportPolicy = rp;
    
    if(Appkey)
    {
        
    }
    Appkey = [[NSString alloc] initWithFormat:@"iphone_%@", appKey];
    
    if(MarketId)
    {
        
    }
    MarketId = [[NSString alloc] initWithString:([mid isValid] ? mid : @"App Store")];
    
    srandom((int)time(0));
    int iRandom = random() % 100000;
    SessionId = [NSString stringWithFormat:@"%d%f",iRandom,[NSDate timeIntervalSince1970WithBJZone]];
    
    dAppStartTime = [NSDate timeIntervalSince1970WithBJZone];
    OrderNum = 1;
    NSString *playId = [NSString stringWithFormat:@"%ld", OrderNum++];
    
    iDoid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"track_doid"] intValue];
    if (0 == iDoid)
    {
        iDoid = 1;
    }
    else
    {
        iDoid++;
    }
    
    NSString *doId = [NSString stringWithFormat:@"%ld", iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    if(Referer)
    {

    }
    Referer = @"none";
    
    if (!trackerDic)
    {
        trackerDic = [[NSMutableDictionary alloc] init];
    }
    
    NSDictionary *dic = nil;
    NSString *startTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *preVsion = [[NSUserDefaults standardUserDefaults] objectForKey:@"track_prevsion"];
    if (!preVsion || 0 == [preVsion length])
    {
        preVsion = @"none";
    }
    
    NSString *curVsion = [[UIDevice currentDevice] appVersion];
    if ([curVsion isEqualToString:preVsion])
    {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"applicationstart", @"action_type", startTime, @"startdt", Referer, @"referer", nil];
    }
    else
    {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"applicationstart", @"action_type", startTime, @"startdt", Referer, @"referer", preVsion, @"previousversion", nil];
        
        [[NSUserDefaults standardUserDefaults] setValue:curVsion forKey:@"track_prevsion"];
    }
    
    [defaultDopTracker startKeepalive];
    
    // Track launch app.
    if ([KVTrack checkSendData:REALTIME])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
    
    [defaultDopTracker performSelector:@selector(checkUDID) withObject:nil afterDelay:10];
    
    // Send the last data tracked.
    if ([KVTrack checkSendData:REALTIME])
    {
        trackerList = [[NSMutableArray alloc] initWithCapacity:0];
//        [self performSelector:@selector(startSendThread) withObject:nil afterDelay:30];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:[KVTrack defaultDopTracker]
                                             selector:@selector(trackExitApp)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
     */
}

//+ (void)exitApp{
//    
//    [self exitApp];
//    
//}

- (void)exitApp
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:[DopTrack defaultDopTracker]
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:[UIApplication sharedApplication]];
    
    NSString *startTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    double dDuration = [NSDate dopTimeIntervalSince1970WithBJZone] - dAppStartTime;
    NSString *length = [NSString stringWithFormat:@"%f", dDuration];
    
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"exit", @"action_type", startTime, @"startdt", length, @"length", Referer, @"referer", nil];
    
    if([trackerList count] > 0)
    {
        // Save remaining data into DB.
        DopTrackLib *objLib = [[DopTrackLib alloc] init];
        [objLib insertTrackerList:trackerList];

    }
    
    if (!OSInfoDic)
    {
        OSInfoDic = [[NSDictionary alloc] initWithDictionary:[defaultDopTracker getOSInfo]];
    }
    
    NSMutableDictionary *trackerInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    [trackerInfo addEntriesFromDictionary:OSInfoDic];
    
//    NSString *jsonStr = [[DopJSONSerializer serializer] serializeDictionary:trackerInfo];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:trackerInfo
                                                       options:0
                                                         error:&error];
    NSString *jsonStr = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    //
    
    BOOL bRet = YES;
    NSHTTPURLResponse *response = nil;
	
//	do {
//        NSString *linkUrl = [NSString stringWithFormat:@"%@",self.trackURLStr];
//        NSURL *programUrl = [NSURL URLWithString:linkUrl];
//        if(!programUrl)
//        {
//            bRet = NO;
//            break;
//        }
//
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:programUrl
//																  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//															  timeoutInterval:30];
//        if(nil == urlRequest)
//        {
//            bRet = NO;
//            break;
//        }
//
//        NSString *userAgent = [[NSUserDefaults standardUserDefaults] objectForKey:DOP_USER_AGENT];
//        if(userAgent)
//        {
//            [urlRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
//        }
//
//        [urlRequest setHTTPMethod:@"POST"];
//
//        // Compress data.
//        NSData *sourceData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSData *compressedData = [NSData dopCompressedDataWithData:sourceData];
//
//        // Base64 encode.
//        [DopBase64 initialize];
//        NSString *encodeData = [DopBase64 encode:compressedData];
//        encodeData = [encodeData dopURLEncodedString];
//
//        NSString *trackerStr = [NSString stringWithFormat:DOP_TRACKER_STR, encodeData];
//
//        [urlRequest setHTTPBody:[trackerStr dataUsingEncoding:NSUTF8StringEncoding]];
//        NSError *error;
//        NSData *ret = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
//
//        NSLog(@"%@ 11111111111111111111111111111",ret);
//        if(!ret)
//        {
//            bRet = NO;
//        }
//    }while(NO);
    
    int iStatesCode = 0;
    
    if (response)
    {
        iStatesCode =  (int)[response statusCode];
    }
    
    if(!bRet || (200 != iStatesCode && 502 != iStatesCode))
    {
        [defaultDopTracker saveDic:dic];
    }
    
 
}


+ (void)logPageView:(NSString *)pageName seconds:(int)seconds;
{
    if ([NSString dopStringIsEmpty:pageName])
    {
        return;
    }
    
    [DopTrack logPageView:pageName seconds:seconds iLogPageType:LOGPAGE_SEC];
}


+ (void)beginLogPageView:(NSString *)pageName
{
    if ([NSString dopStringIsEmpty:pageName])
    {
        return;
    }
    
    [DopTrack beginEventOrPage:pageName];
}


+ (void)endLogPageView:(NSString *)pageName
{
    if ([NSString dopStringIsEmpty:pageName])
    {
        return;
    }
    
    [DopTrack logPageView:pageName seconds:0 iLogPageType:LOGPAGE_END];
}


+ (void)event:(NSString *)eventId
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    [DopTrack event:eventId paraDic:nil];
}


+ (void)event:(NSString *)eventId label:(NSString *)label
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    if (!label || 0 == [label length])
    {
        label = eventId;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:label, @"label", nil];
    
    [DopTrack event:eventId paraDic:dic];
}


+ (void)event:(NSString *)eventId acc:(NSInteger)accumulation
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    NSString *accStr = [NSString stringWithFormat:@"%ld", (long)accumulation];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:accStr, @"accumulation", nil];
    
    [DopTrack event:eventId paraDic:dic];
}


+ (void)event:(NSString *)eventId label:(NSString *)label acc:(NSInteger)accumulation
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    if (!label || 0 == [label length])
    {
        label = eventId;
    }
    NSString *accStr = [NSString stringWithFormat:@"%ld", (long)accumulation];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:label, @"label", accStr, @"accumulation", nil];
    
    [DopTrack event:eventId paraDic:dic];
}


+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
   
//    NSString *jsonAttrStr = [[DopJSONSerializer serializer] serializeDictionary:attributes];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:attributes
                                                       options:0
                                                         error:&error];
    NSString *jsonAttrStr = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:jsonAttrStr, @"attribute", nil];
    
    [DopTrack event:eventId paraDic:dic];
}


+ (void)beginEvent:(NSString *)eventId
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    [DopTrack beginEventOrPage:eventId];
}


+ (void)endEvent:(NSString *)eventId
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    NSNumber *startTimeNumber = [trackerDic objectForKey:eventId];
    double dstartTime = [startTimeNumber doubleValue];
    if (!startTimeNumber)
    {
        dstartTime = [NSDate dopTimeIntervalSince1970WithBJZone];
    }
    NSString *startTime = [NSDate dopTimestampConvertTimeStr:dstartTime Format:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    NSString *stopTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    double dDuration = [NSDate dopTimeIntervalSince1970WithBJZone] - dstartTime;
    
    NSString *length = [NSString stringWithFormat:@"%f", dDuration];
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    if(!Referer)
    {
        Referer = @"none";
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"custom_event", @"action_type", startTime, @"startdt", stopTime, @"stopdt", length, @"length", eventId, @"eventid", Referer, @"referer", nil];
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
    
    [trackerDic removeObjectForKey:eventId];
    
    if(Referer)
    {
        
    }
    Referer = [[NSString alloc] initWithFormat:@"%@", eventId];
}


+ (void)beginEvent:(NSString *)eventId label:(NSString *)label;
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    NSString *eventIdLabel = [NSString stringWithFormat:@"%@%@",eventId,label];
    
    [DopTrack beginEventOrPage:eventIdLabel];
}


+ (void)endEvent:(NSString *)eventId label:(NSString *)label;
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    NSString *eventIdLabel = [NSString stringWithFormat:@"%@%@",eventId,label];
    
    NSNumber *startTimeNumber = [trackerDic objectForKey:eventIdLabel];
    double dstartTime = [startTimeNumber doubleValue];
    if (!dstartTime)
    {
        dstartTime = [NSDate dopTimeIntervalSince1970WithBJZone];
    }
    NSString *startTime = [NSDate dopTimestampConvertTimeStr:dstartTime Format:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    NSString *stopTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    double dDuration = [NSDate dopTimeIntervalSince1970WithBJZone] - dstartTime;
    
    NSString *length = [NSString stringWithFormat:@"%f", dDuration];
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    if (!label)
    {
        label = eventId;
    }
    
    if(!Referer)
    {
        Referer = @"none";
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"custom_event", @"action_type", startTime, @"startdt", stopTime, @"stopdt", length, @"length", eventId, @"eventid", label, @"label", Referer, @"referer", nil];
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
    
    [trackerDic removeObjectForKey:eventId];
    
    if(Referer)
    {
    
    }
    Referer = [[NSString alloc] initWithFormat:@"%@", eventId];
}


+ (void)beginEvent:(NSString *)eventId primarykey :(NSString *)keyName attributes:(NSDictionary *)attributes
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    [DopTrack event:eventId attributes:attributes];
    
    NSString *eventIdKeyName = [NSString stringWithFormat:@"%@%@", eventId, keyName];
    [DopTrack beginEventOrPage:eventIdKeyName];
    
    NSString *dicAttr = [NSString stringWithFormat:@"dic%@%@", eventId, keyName];
//    NSString *dicStr = [[DopJSONSerializer serializer] serializeDictionary:attributes];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:attributes
                                                       options:0
                                                         error:&error];
    NSString *dicStr = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    if (!trackerDic)
    {
        trackerDic = [[NSMutableDictionary alloc] init];
    }
    [trackerDic setValue:dicStr forKey:dicAttr];
}


+ (void)endEvent:(NSString *)eventId primarykey:(NSString *)keyName
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    NSString *eventIdKeyName = [NSString stringWithFormat:@"%@%@", eventId, keyName];
    NSNumber *startTimeNumber = [trackerDic objectForKey:eventIdKeyName];
    double dstartTime = [startTimeNumber doubleValue];
    if (!dstartTime)
    {
        dstartTime = [NSDate dopTimeIntervalSince1970WithBJZone];
    }
    NSString *startTime = [NSDate dopTimestampConvertTimeStr:dstartTime Format:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    NSString *stopTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    double dDuration = [NSDate dopTimeIntervalSince1970WithBJZone] - dstartTime;
    
    NSString *length = [NSString stringWithFormat:@"%f", dDuration];
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    NSString *dicAttr = [NSString stringWithFormat:@"dic%@%@", eventId, keyName];
    NSString *attrStr = [trackerDic objectForKey:dicAttr];
    
    if(!Referer)
    {
        Referer = @"none";
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"custom_event", @"action_type", startTime, @"startdt", stopTime, @"stopdt", length, @"length", eventId, @"eventid", attrStr, @"attribute", Referer, @"referer", nil];
    
    [trackerDic removeObjectForKey:eventId];
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
    
    if(Referer)
    {
    
    }
    Referer = [[NSString alloc] initWithFormat:@"%@", eventId];
}


+ (void)event:(NSString *)eventId durations:(int)second
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    [DopTrack event:eventId durations:second paraDic:nil];
}


+ (void)event:(NSString *)eventId label:(NSString *)label durations:(int)second
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    if (!label || 0 == [label length])
    {
        label = eventId;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:label, @"label", nil];
    
    [DopTrack event:eventId durations:second paraDic:dic];
}


+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes durations:(float)second;
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
//    NSString *jsonAttrStr = [[DopJSONSerializer serializer] serializeDictionary:attributes];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:attributes
                                                       options:0
                                                         error:&error];
    NSString *jsonAttrStr = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:jsonAttrStr, @"attribute", nil];
    
    [DopTrack event:eventId durations:second paraDic:dic];
}


+ (void)checkUpdate
{
    NSString *startTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"update", @"action_type", startTime, @"startdt", nil];
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
}


+ (void)checkUpdate:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSString *)otherTitle
{
    NSString *startTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"update", @"action_type", startTime, @"startdt", title, @"title", cancelTitle, @"canceltitle", otherTitle, @"othertitle",nil];
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
}


+ (void)reportError:(NSString *)exceptionMessage
{
    NSString *startTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"crashInfo", @"action_type", startTime, @"startdt", exceptionMessage, @"exceptionMessage", nil];
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
}


+ (void)reportErrorWithConnection:(NSURLConnection *)connection errorInfo:(NSDictionary *)errorInfo
{
    NSMutableDictionary *trackInfo = [NSMutableDictionary dictionaryWithDictionary:errorInfo];
    
    // Available iOS 5.0
    if (SYS_VER_GREATER_OR_EQUAL(5.0))
    {
        NSMutableURLRequest *request = (NSMutableURLRequest *)connection.originalRequest;
        [trackInfo setValue:[[request URL] absoluteString] forKey:@"url"];
        
        NSData *body = [request HTTPBody];
        if(body)
        {
            [DopBase64 initialize];
            NSData *decodeData = [DopBase64 decode:[body bytes] length:[body length]];
            if(decodeData)
            {
//                NSDictionary *interface = [[DopJSONDeserializer deserializer] deserializeAsDictionary:decodeData error:nil];
                NSError *error = nil;
                NSDictionary *interface = [NSJSONSerialization JSONObjectWithData:decodeData options:NSJSONReadingMutableContainers error:&error];
                
                if(interface && [interface count])
                {
                    [trackInfo setValue:interface forKey:@"interface"];
                }
            }
            else
            {
//                NSDictionary *interface = [[DopJSONDeserializer deserializer] deserializeAsDictionary:body error:nil];
                NSError *error = nil;
                NSDictionary *interface = [NSJSONSerialization JSONObjectWithData:decodeData options:NSJSONReadingMutableContainers error:&error];
                if(interface && [interface count])
                {
                    [trackInfo setValue:interface forKey:@"interface"];
                }
            }
        }
    }
    
//    NSString *strErrorMsg = [[DopJSONSerializer serializer] serializeDictionary:trackInfo];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:trackInfo
                                                       options:0
                                                         error:&error];
    
        
    NSString *strErrorMsg = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    if(![NSString dopStringIsEmpty:strErrorMsg])
    {
        [DopTrack reportError:strErrorMsg];
    }
}


+ (void)saveDicToLib:(NSDictionary *)trackerDic
{
    defaultDopTracker = [DopTrack defaultDopTracker];
    [defaultDopTracker saveDic:trackerDic];
}

#pragma mark -
#pragma mark Class Private Function
+ (DopTrack *)defaultDopTracker
{
    if(!defaultDopTracker)
    {
        defaultDopTracker = [[DopTrack alloc] init];
    }
    
    return defaultDopTracker;
}

- (void)postServer:(NSString *)jsonStr ifDelegate:(BOOL)bDelegate ifRunLoopRun:(BOOL)bRunLoopRun
{
    TrackUrlConnection *urlConnection = nil;
    
    if (jsonStr == nil) {
        
        return;
    }
    
    NSString *linkUrl = [NSString stringWithFormat:@"%@",self.trackURLStr];
    NSURL *programUrl = [NSURL URLWithString:linkUrl];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:programUrl
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60];
    
    NSString *userAgent = [[NSUserDefaults standardUserDefaults] objectForKey:DOP_USER_AGENT];
    if(userAgent)
    {
        [urlRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    [urlRequest setHTTPMethod:@"POST"];
    NSData *sourceData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *compressedData = [NSData dopCompressedDataWithData:sourceData];
    [DopBase64 initialize];
    NSString *encodeData = [DopBase64 encode:compressedData];
    encodeData = [encodeData dopURLEncodedString];
    NSString *trackerStr = [NSString stringWithFormat:DOP_TRACKER_STR, encodeData];
    [urlRequest setHTTPBody:[trackerStr dataUsingEncoding:NSUTF8StringEncoding]];
    if (bDelegate)
    {
        
        urlConnection=[[TrackUrlConnection alloc]initWithRequest:urlRequest delegate:self startImmediately:YES];
    }
    else
    {
        
        urlConnection=[[TrackUrlConnection alloc]initWithRequest:urlRequest delegate:nil startImmediately:YES];
    }
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];//请求头
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error) {
                //没有错误，返回正确；
                NSLog(@"Track Success!");
            }else{
                //出现错误；
            }
            
        }];
        
        
        [dataTask resume];
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
        });
        
    });
    
   
}


- (NSString *)addOSInfo:(NSDictionary *)trackerDic
{
    /*
    if (!OSInfoDic)
    {
        OSInfoDic = [[NSDictionary alloc] initWithDictionary:[defaultDopTracker getOSInfo]];
    }
     */
    //每次报的时候info可能不一样，所以每次都重新取
    OSInfoDic = [[NSDictionary alloc] initWithDictionary:[defaultDopTracker getOSInfo]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:trackerDic];
    
    [dic addEntriesFromDictionary:OSInfoDic];
    
//    NSString *jsonStr = [[DopJSONSerializer serializer] serializeDictionary:dic];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:&error];
        
    NSString *jsonStr = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    return jsonStr;
}

- (void)postDic:(NSDictionary *)trackerDic ifDelegate:(BOOL)bDelegate
{
    NSString *jsonStr = [defaultDopTracker addOSInfo:trackerDic];
    [defaultDopTracker postServer:jsonStr ifDelegate:bDelegate ifRunLoopRun:NO];
}

- (void)saveDic:(NSDictionary *)trackerDic
{
    /*
    if (!OSInfoDic)
    {
        OSInfoDic = [[NSDictionary alloc] initWithDictionary:[defaultDopTracker getOSInfo]];
    }
     */
    //每次报的时候info可能不一样，所以每次都重新取
    OSInfoDic = [[NSDictionary alloc] initWithDictionary:[defaultDopTracker getOSInfo]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:trackerDic];
    
    [dic addEntriesFromDictionary:OSInfoDic];
    
//    NSString *jsonStr = [[DopJSONSerializer serializer] serializeDictionary:dic];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    double trackerTime = [NSDate dopTimeIntervalSince1970WithBJZone];
    DopTrackLib *objLib = [[DopTrackLib alloc] init];
    [objLib insertTrackerData:trackerTime trackData:jsonStr];
//    SAFE_ARC_RELEASE(objLib);
}


- (NSDictionary *)getOSInfo
{
    // App Version
    NSString *appVersion = [[UIDevice currentDevice] dopAppVersion];
    if(!appVersion || 0 == [appVersion length])
    {
        appVersion = @"none";
    }
    
    // Device Id
    NSString *deviceId = [DopUDID getUDID];
    if(!deviceId || 0 == [deviceId length])
    {
        deviceId = @"none";
    }
    
    // Device Manufacturer
    NSString *manufacturer = @"Apple";
    
    // Device Type
    NSString *deviceType = [UIDevice currentDevice].model;
    deviceType = [deviceType dopURLEncodedString];
    
    // OS Name
    NSString *osName = [UIDevice currentDevice].systemName;
    osName = [osName dopURLEncodedString];
    
    // OS Version
    NSString *osVersion = [UIDevice currentDevice].systemVersion;
    osVersion = [osVersion dopURLEncodedString];
    
    // Device Resoluton
    NSString *resolution = @"320x480";
    if(NSOrderedDescending == [osVersion compare:@"3.2" options:NSCaseInsensitiveSearch])
    {
        CGSize stuSize = [[UIScreen mainScreen].currentMode size];
        resolution = [NSString stringWithFormat:@"%.0fx%.0f", stuSize.width, stuSize.height];
    }
    
    // Network Type
    NSString *networkType = @"none";
    networkType = [self getNetworkTypeFromStatusBar];
    
    NetworkStatus netStatus = [[DopoolReachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    /*
    switch (netStatus)
    {
        case ReachableViaWWAN:
            networkType =@"3G";
//        case ReachableVia2G:
//            networkType = @"2G";
//            break;
//        case ReachableVia3G:
//            networkType = @"3G";
//            break;
        case ReachableViaWiFi:
            networkType= @"wifi";
            break;
        default:
            networkType = @"none";
            break;
    }
    */
    
    // Device mac address.
    NSString *mac = [[UIDevice currentDevice] dopMacAddress];
    if(!mac || 0 == [mac length])
    {
        mac = @"none";
    }
    
    // Access Point
    NSString *accessPoint = @"none";
    if (netStatus==ReachableViaWiFi) {
        accessPoint=[Dop_Device_Checker Fetch_SSID];
    }
    
    // Language
//    NSString *language = @"CN";
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *language = languages[0];
    
    // IMEI
    NSString *imei = @"none";
    
    if (!Appkey || 0 == [Appkey length])
    {
        Appkey = @"none";
    }
    
    InstallDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"track_installDate"];
    if (!InstallDate)
    {
        InstallDate = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
        [[NSUserDefaults standardUserDefaults] setValue:InstallDate forKey:@"track_installDate"];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:MarketId, @"marketid", appVersion, @"app_v", deviceId, @"userid", osName, @"operation_system", osVersion, @"os_version", manufacturer, @"Manufacturer", deviceType, @"device_type", resolution, @"resolution", networkType, @"network", accessPoint, @"access_point", mac, @"mac", language, @"l", imei, @"imei", Appkey, @"appkey", InstallDate, @"ftime", nil];
    
    return dic;
}


+ (void)logPageView:(NSString *)pageName seconds:(int)seconds iLogPageType:(int)iLogPageType
{
    if ([NSString dopStringIsEmpty:pageName] || iLogPageType > 2)
    {
        return;
    }
    
    double dstartTime = 0.0;
    if (iLogPageType == LOGPAGE_END)
    {
        NSNumber *startTimeNumber = [trackerDic objectForKey:pageName];
        dstartTime = [startTimeNumber doubleValue];
    }
    
    if (!dstartTime)
    {
        dstartTime = [NSDate dopTimeIntervalSince1970WithBJZone];
    }
    
    NSString *startTime = [NSDate dopTimestampConvertTimeStr:dstartTime Format:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    NSString *stopTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    double dDuration = [NSDate dopTimeIntervalSince1970WithBJZone] - dstartTime;
    
    NSString *length = nil;
    if (iLogPageType == LOGPAGE_SEC)
    {
        length = [NSString stringWithFormat:@"%d", seconds];
    }
    else
    {
        length = [NSString stringWithFormat:@"%f", dDuration];
    }
    
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    if(!Referer)
    {
        Referer = @"none";
    }
    NSDictionary *dic = nil;
    if (iLogPageType == LOGPAGE_SEC)
    {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", stopTime, @"stopdt", length, @"length", Referer, @"referer", pageName, @"view", nil];
    }
    else
    {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", startTime, @"startdt", stopTime, @"stopdt", length, @"length", Referer, @"referer", pageName, @"view", nil];
    }
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
    
    if(Referer)
    {
//        SAFE_ARC_RELEASE(Referer);
    }
    Referer = [[NSString alloc] initWithFormat:@"%@", pageName];
    
    if(iLogPageType == LOGPAGE_END)
    {
        [trackerDic removeObjectForKey:pageName];
    }
}


+ (void)beginEventOrPage:(NSString *)eventIdOrPageView
{
    if ([NSString dopStringIsEmpty:eventIdOrPageView])
    {
        return;
    }
    
    NSNumber *startTime = [NSNumber numberWithDouble:[NSDate dopTimeIntervalSince1970WithBJZone]];
    
    if (!trackerDic)
    {
        trackerDic = [[NSMutableDictionary alloc] init];
    }
    [trackerDic setValue:startTime forKey:eventIdOrPageView];
}


+ (void)event:(NSString *)eventId paraDic:(NSDictionary *)paraDic
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    NSString *startTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    if(!Referer)
    {
        Referer = @"none";
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"custom_event", @"action_type", startTime, @"startdt", eventId, @"eventid", Referer, @"referer", nil];
    if(paraDic && [paraDic count] > 0)
    {
        [dic addEntriesFromDictionary:paraDic];
    }
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
    
    if(Referer)
    {
//        SAFE_ARC_RELEASE(Referer);
    }
    Referer = [[NSString alloc] initWithFormat:@"%@", eventId];
}


+ (void)event:(NSString *)eventId durations:(float)second paraDic:(NSDictionary *)paraDic
{
    if ([NSString dopStringIsEmpty:eventId])
    {
        return;
    }
    
    NSString *startTime = [NSDate dopCurrentBJDate:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *length = [NSString stringWithFormat:@"%f", second];
    NSString *playId = [NSString stringWithFormat:@"%ld",OrderNum++];
    NSString *doId = [NSString stringWithFormat:@"%ld",iDoid++];
    [[NSUserDefaults standardUserDefaults] setValue:doId forKey:@"track_doid"];
    
    if(!Referer)
    {
        Referer = @"none";
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:SessionId, @"Login_ID", playId, @"play_id", doId, @"doid", @"custom_event", @"action_type", startTime, @"startdt", length, @"length", eventId, @"eventid", Referer, @"referer",nil];
    
    [dic addEntriesFromDictionary:paraDic];
    
    if ([DopTrack checkSendData:iReportPolicy])
    {
        [defaultDopTracker postDic:dic ifDelegate:YES];
    }
    else
    {
        [defaultDopTracker saveDic:dic];
    }
    
    if(Referer)
    {
//        SAFE_ARC_RELEASE(Referer);
    }
    Referer = [[NSString alloc] initWithFormat:@"%@", eventId];
}


+ (BOOL)checkSendData:(ReportPolicy)reportPolicy
{
    networkStatus = [[DopoolReachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(NotReachable == networkStatus)
    {
        return NO;
    }
    
    BOOL bRet = NO;
    switch (reportPolicy)
    {
        case REALTIME:
            bRet = YES;
            break;
            
        case BATCH:
            bRet = NO;
            break;
            
        case SENDWIFIONLY:
            if(ReachableViaWiFi == networkStatus)
            {
                bRet = YES;
            }
            break;
            
        default:
            // Other cases as BATCH processing.
            bRet = NO;
            break;
    }
    
    return bRet;
}

- (void)startSendThread
{
     if(sendThread)
     {
     [sendThread cancel];
     //        SAFE_ARC_RELEASE(sendThread);
     }
     
     bThreadStart = YES;
     NSNumber *maxNumber = [NSNumber numberWithDouble:dAppStartTime];
     sendThread = [[NSThread alloc] initWithTarget:[DopTrack defaultDopTracker]
     selector:@selector(sendTrackerData:)
     object:maxNumber];
     [sendThread start];
}

+ (void)startSendThread
{
    if(sendThread)
    {
        [sendThread cancel];
//        SAFE_ARC_RELEASE(sendThread);
    }
    
    bThreadStart = YES;
    NSNumber *maxNumber = [NSNumber numberWithDouble:dAppStartTime];
    sendThread = [[NSThread alloc] initWithTarget:[DopTrack defaultDopTracker]
                                         selector:@selector(sendTrackerData:)
                                           object:maxNumber];
    [sendThread start];
}

- (void)sendTrackerData:(NSNumber *)maxNumber
{
//    SAFE_ARC_AUTORELEASE_POOL_START()
    
    if (0 < [trackerList count])
    {
        while (0 < [trackerList count])
        {
            NSDictionary *oneTracker = [trackerList objectAtIndex:0];
            [self postServer:[oneTracker objectForKey:@"info"] ifDelegate:YES ifRunLoopRun:YES];
            [trackerList removeObject:oneTracker];
        }
    }
    
    double dMaxTrackerTime = 0;
    double trackerTime = [maxNumber doubleValue];
    
    DopTrackLib *objLib = [[DopTrackLib alloc] init];
    [objLib getTracker:trackerList curTrackerTime:trackerTime];
    if ([trackerList count] > 0)
    {
        NSDictionary *lastTracker = [trackerList lastObject];
        dMaxTrackerTime = [[lastTracker objectForKey:@"key"] doubleValue] + 1;
        [objLib deleteTrackerDataBeforeTime:dMaxTrackerTime];
    }
    
    while ([trackerList count] > 0)
    {
        while ([trackerList count] > 0)
        {
            NSDictionary *oneTracker = [trackerList objectAtIndex:0];
            [self postServer:[oneTracker objectForKey:@"info"] ifDelegate:YES ifRunLoopRun:YES];
            [trackerList removeObject:oneTracker];
        }
        
        [objLib getTracker:trackerList curTrackerTime:trackerTime];
        if (0 < [trackerList count])
        {
            NSDictionary *lastTracker = [trackerList lastObject];
            dMaxTrackerTime = [[lastTracker objectForKey:@"key"] doubleValue] + 1;
            [objLib deleteTrackerDataBeforeTime:dMaxTrackerTime];
        }
    }
    
//    SAFE_ARC_RELEASE(objLib);
    
    if (bReachabilityChangedNotification)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ReachabilityChangedNotification
                                                      object:nil];
        
        bReachabilityChangedNotification = NO;
    }
    
    [self performSelector:@selector(stopRunLoop) withObject:nil afterDelay:60];
    
//    SAFE_ARC_AUTORELEASE_POOL_END()
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    networkStatus = [[DopoolReachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (networkStatus != NotReachable && !bThreadStart)
    {
        [DopTrack startSendThread];
        return;
    }
    
    if (bThreadStart)
    {
        bThreadStart = NO;
        if(sendThread)
        {
            [sendThread cancel];
//            SAFE_ARC_RELEASE(sendThread);
            
            [self performSelector:@selector(stopRunLoop) withObject:nil afterDelay:60];
        }
    }
}


- (void)trackExitApp
{
    if(sendThread)
    {
        bThreadStart = NO;
        
        [sendThread cancel];
//        SAFE_ARC_RELEASE(sendThread);
        
        [self stopRunLoop];
    }
    
    if([[UIDevice currentDevice] dopSupportRunningInBackground])
    {
        [self performSelector:@selector(delayTrackingExitApp) withObject:nil afterDelay:0.5];
    }
    else
    {
//        禁用退出
//        [[DopTrack defaultDopTracker] exitApp];
    }
}

- (void)delayTrackingExitApp
{
//    禁用退出
//    [[DopTrack defaultDopTracker] exitApp];
}

- (void)stopRunLoop
{
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)checkUDID
{
    [DopCheckUDID checkUDID];
}

- (void)startKeepalive
{
    if(m_Timer)
    {
        [m_Timer invalidate];
//        SAFE_ARC_RELEASE(m_Timer);
    }
    
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
	m_Timer = [[NSTimer alloc] initWithFireDate:fireDate
                                       interval:SEND_KEEPALIVE_INTERVAL
                                         target:self
                                       selector:@selector(sendKeepalive)
                                       userInfo:nil
                                        repeats:YES];
	
	NSRunLoop *mainLoop = [NSRunLoop currentRunLoop];
	[mainLoop addTimer:m_Timer forMode:NSDefaultRunLoopMode];
}

- (void)sendKeepalive
{
    [DopTrack event:@"pushengine_keepalive"];
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpUrl = (NSHTTPURLResponse *)response;
    TrackUrlConnection *urlConnection = (TrackUrlConnection *)connection;
    int iStatusCode = (int)[httpUrl statusCode];
    if (200 != iStatusCode && 502 != iStatusCode)
    {
        double trackerTime = [NSDate dopTimeIntervalSince1970WithBJZone];
        DopTrackLib *objLib = [[DopTrackLib alloc] init];
        [objLib insertTrackerData:trackerTime trackData:urlConnection.m_Input];
//        SAFE_ARC_RELEASE(objLib);
    }
    
    /*
    if (iStatusCode == 502) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TrackStartNotification object:nil];
        
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TrackFailedNotification object:nil];
        
    }
    */
    
    //DOP_LOG(@"[DEBUG] status code %d", iStatusCode);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    CFRunLoopStop(CFRunLoopGetCurrent());
    TrackUrlConnection *urlConnection = (TrackUrlConnection *)connection;
    double trackerTime = [NSDate dopTimeIntervalSince1970WithBJZone];
    DopTrackLib *objLib = [[DopTrackLib alloc] init];
    [objLib insertTrackerData:trackerTime trackData:urlConnection.m_Input];
//    SAFE_ARC_RELEASE(objLib);
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:TrackFailedNotification object:nil];
    
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    //    NSLog(@"didReceiveChallenge %@", challenge.protectionSpace);
//    NSLog(@"调用了最外层");
    // 1.判断服务器返回的证书类型, 是否是服务器信任
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        NSLog(@"调用了里面这一层是服务器信任的证书");
        /*
         NSURLSessionAuthChallengeUseCredential = 0,                     使用证书
         NSURLSessionAuthChallengePerformDefaultHandling = 1,            忽略证书(默认的处理方式)
         NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2,     忽略书证, 并取消这次请求
         NSURLSessionAuthChallengeRejectProtectionSpace = 3,            拒绝当前这一次, 下一次再询问
         */
        //        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential , card);
    }
}
- (NSString *)getNetworkTypeFromStatusBar{
    
    NSString *strNetworkInfo = @"No Network";
    struct sockaddr_storage zeroAddress;
    bzero(&zeroAddress,sizeof(zeroAddress));
    
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL,(struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    //获得连接的标志
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability,&flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if(!didRetrieveFlags){ return strNetworkInfo;}
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable)!=0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired)!=0);
    if(!isReachable || needsConnection) {return strNetworkInfo;}
    // 网络类型判断
    
    
    if((flags & kSCNetworkReachabilityFlagsConnectionRequired)== 0){strNetworkInfo = @"WIFI";}
    
    
    if(((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0) { if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){strNetworkInfo = @"WIFI";}}
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) ==kSCNetworkReachabilityFlagsIsWWAN) {if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;if (currentRadioAccessTechnology) {if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {strNetworkInfo =@"4G";} else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {strNetworkInfo =@"2G";} else {strNetworkInfo =@"3G";}}} else {if((flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable) {if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {strNetworkInfo =@"2G";} else {strNetworkInfo = @"3G";}}}}}
    
    // if ([strNetworkInfo isEqualToString: @"No Network"]) {strNetworkInfo = @"WWAN";}
    
    return strNetworkInfo;
}

@end


#pragma mark -
#pragma mark TrackUrlConnection

@implementation TrackUrlConnection

@synthesize m_Input;
@synthesize m_NetData;
@synthesize m_Results;



@end
