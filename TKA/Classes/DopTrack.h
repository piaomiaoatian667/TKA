//
//  KVTrack.h
//  real_app1
//
//  Created by vampire on 3/27/14.
//  Copyright (c) 2014 vampire. All rights reserved.
//

#import <Foundation/Foundation.h>
/* http://analytics3.dopool.com/index.php?m=Api&a=saveAction&e=iphone&data= */
//#define DOP_TRACKER_URL       @"http://analytics3.dopool.com/index.php?m=Api&a=saveAction&e=iphone&data="

#define DOP_TRACKER_STR       @"e=iphone&data=%@"
typedef enum {
    REALTIME = 0,       //实时发送
    BATCH = 1,          //启动发送
    //SENDDAILY = 4,      //每日发送
    SENDWIFIONLY = 5,   //仅在WIFI下启动时发送
    //SEND_INTERVAL = 6,  //按最小间隔发送
    //SEND_ON_EXIT = 7    //退出或进入后台时发送
} ReportPolicy;

@interface DopTrack : NSObject

@property (nonatomic, strong) NSString *trackURLStr;

+ (DopTrack *)defaultDopTracker;

- (void)setDefaultTrackURLStr;
- (void)setInnerTrackURLStr;
- (void)setUploadAddressWithURLStr:(NSString *)urlStr;

/******************************
 开启统计.
 
 @param     appKey
 @param     reportPolicy 发送策略. 默认为BATCH
 @param     channelId 渠道名称,为nil或@""时,默认会被被当作@"App Store"渠道
 @return    无.
 *******************************/
+ (void)startWithAppkey:(NSString *)appKey;
+ (void)startWithAppkey:(NSString *)appKey reportPolicy:(ReportPolicy)rp marketId:(NSString *)mid;
- (void)startWithAppkey:(NSString *)appKey reportPolicy:(ReportPolicy)rp marketId:(NSString *)mid;

/******************************
 退出统计.
 
 @param     无
 @return    无
 *******************************/
//+ (void)exitApp;
- (void)exitApp;

/******************************
 页面时长统计
 记录某个view被打开多长时间,可以自己计时也可以调用beginLogPageView,endLogPageView自动计时.
 
 @param     [IN]pageName 需要记录时长的view名称.
 @param     [IN]seconds  秒数.
 @return    无
 *******************************/
+ (void)logPageView:(NSString *)pageName seconds:(int)seconds;
+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;

/******************************
 自定义事件统计.
 
 @param     [IN]eventId      事件Id.
 @param     [IN]label        分类标签,不同的标签会分别进行统计，方便同一事件的不同标签的对比,为nil或空字符串时后台会生成和eventId同名的标签.
 @param     [IN]accumulation 累加值,为减少网络交互，可以自行对某一事件ID的某一分类标签进行累加，再传入次数作为参数.
 @param     [IN]attributes   事件的属性和取值（键值对）
 @return    无
 *******************************/
+ (void)event:(NSString *)eventId;
+ (void)event:(NSString *)eventId label:(NSString *)label;
+ (void)event:(NSString *)eventId acc:(NSInteger)accumulation;
+ (void)event:(NSString *)eventId label:(NSString *)label acc:(NSInteger)accumulation;
+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes;

/******************************
 自定义事件时长统计.
 beginEvent,endEvent要配对使用,也可以自己计时后通过durations参数传递进来
 
 @param     [IN]eventId     事件Id.
 @param     [IN]label       分类标签,不同的标签会分别进行统计，方便同一事件的不同标签的对比,
 为nil或空字符串时后台会生成和eventId同名的标签.
 @param     [IN]keyName     这个参数用于和eventId一起标示一个唯一事件，并不会被统计.
 @param     [IN]attributes  事件的属性和取值（键值对）
 @param     [IN]millisecond 毫秒数
 @return    无
 *******************************/
+ (void)beginEvent:(NSString *)eventId;
+ (void)endEvent:(NSString *)eventId;
+ (void)beginEvent:(NSString *)eventId label:(NSString *)label;
+ (void)endEvent:(NSString *)eventId label:(NSString *)label;

+ (void)beginEvent:(NSString *)eventId primarykey :(NSString *)keyName attributes:(NSDictionary *)attributes;
+ (void)endEvent:(NSString *)eventId primarykey:(NSString *)keyName;
+ (void)event:(NSString *)eventId durations:(int)second;
+ (void)event:(NSString *)eventId label:(NSString *)label durations:(int)millisecond;
+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes durations:(float)second;

/******************************
 检查当前app是否有更新，有更新弹出UIAlertView提示用户,当用户点击升级按钮时app会跳转到您预先设置的网址。
 无更新不做任何操作.
 
 @param     [IN]title       对应UIAlertView的title.
 @param     [IN]cancelTitle 对应UIAlertView的cancelTitle.
 @param     [IN]otherTitle  对应UIAlertView的otherTitle.
 @return    无
 *******************************/
+ (void)checkUpdate;
+ (void)checkUpdate:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSString *)otherTitle;

/******************************
 错误报告统计.
 
 @param     [IN]exceptionMessage 错误信息
 @return    无
 *******************************/
+ (void)reportError:(NSString *)exceptionMessage;


/******************************
 错误报告统计.
 
 @param     [IN]connection 本次链接
 @param     [IN]errorInfo 错误信息
 @return    无
 *******************************/
+ (void)reportErrorWithConnection:(NSURLConnection *)connection errorInfo:(NSDictionary *)errorInfo;


/******************************
 将统计保存到数据库中
 
 @param     [IN]trackerDic 统计数据
 @return    无
 *******************************/
+ (void)saveDicToLib:(NSDictionary *)trackerDic;
@end
