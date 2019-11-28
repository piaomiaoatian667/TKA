//
//  TrackConst.h
//  DopTv
//
//  Created by dopooliPhone on 5/17/13.
//
//

//#define TrackStartNotification @"start_track_notification"
//#define TrackFailedNotification @"failed_track_notification"

#define EVENTID_HOME                 @"con_home"
#define EVENTID_FIND                 @"con_find"
#define EVENTID_AREA                 @"con_cplist"
#define EVENTID_SEARCH               @"con_search"
#define EVENTID_CANCELSEARCH         @"con_cancelsearch"
#define EVENTID_PERSON               @"con_personalinfo"
#define EVENTID_MORE                 @"con_morechannels"
#define EVENTID_HOME_CONTENT         @"con_recommend"
#define EVENTID_FIND_CONTENT         @"con_findplate"
#define EVENTID_CP_CONTENT           @"con_cp"
#define EVENTID_SEARCH_CATEGORY      @"con_channellisttype"
#define EVENTID_SEARCH_KEYWORD       @"con_searchkeyword"
#define EVENTID_SEARCH_VIDEO         @"con_channelsearchlist"
#define EVENTID_SEARCH_PROGRAM       @"con_programsearchlist"
#define EVENTID_LOGIN                @"con_login"
#define EVENTID_RECOMMEND_APPS       @"con_apps"
#define EVENTID_MYRESERVE            @"con_myreserve"
#define EVENTID_MYRECORD             @"con_myrecord"
#define EVENTID_MYMESSAGES           @"con_mymessages"
#define EVENTID_WATCHRECORD          @"con_lastview"
#define EVENTID_UPDATE               @"con_update"
#define EVENTID_CANCELUPDATE         @"con_cancelupdate"
#define EVENTID_CHECK_UPDATE         @"check_update"
#define EVENTID_FEEDBACK             @"con_feedback"
#define EVENTID_FIGHTING             @"con_fighting"
#define EVENTID_ABOUT                @"con_about"
#define EVENTID_NOTICE               @"con_notice"
#define EVENTID_MYSUBSCRIBE          @"con_mysubscribe"
#define EVENTID_GUIDE                @"con_guide"

#define EVENTID_MENU                 @"con_menu"

#define EVENTID_LOGIN_DOPOOL         @"con_logindopool"
#define EVENTID_LOGIN_SINA           @"con_loginsina"
#define EVENTID_LOGIN_QQ             @"con_logintencent"
#define EVENTID_LOGIN_CONFIRM        @"con_loginconfirm"
#define EVENTID_REGISTER             @"con_register"
#define EVENTID_FORGET_PASSWORD      @"con_forgetpwd"
#define EVENTID_CHANGE_AVATAR        @"con_changeavatar"
#define EVENTID_SUBMIT_REGISTER      @"con_registercommit"
#define EVENTID_MODIFY_NICKNAME      @"con_modifynickname"
#define EVENTID_BINDING_WEIBO        @"con_bindingmicroblog"
#define EVENTID_CANCEL_BINDINGWEIBO  @"con_unbindmicroblog"
#define EVENTID_CHANGE_PASSWORD      @"con_changepwd"
#define EVENTID_LOGOUT               @"con_logoff"
#define EVENTID_DELETE_RECORED       @"con_delrecord"
#define EVENTID_SUBMIT_FEEDBACK      @"con_submitfeedback"
#define EVENTID_CUSTOMER_PHONE       @"con_customerphone"
#define EVENTID_DOPOOL_WEBSITE       @"con_officialwebsite"
#define EVENTID_DOPOOL_WEIBO         @"con_officialmicroblog"
#define EVENTID_VERSION_INTRODUCTION @"con_introduction"
#define ENENTID_EXECEPTION_CLAUSE    @"con_execptionclause"
#define EVENTID_ABOUTDOPOOL          @"con_aboutdopool"


#define EVENTID_SUBSCRIBE            @"fun_subscribe"
#define EVENTID_RESERVE              @"fun_reserve"
#define EVENTID_FAVORITE             @"fun_favorite"
#define EVENTID_RECORD               @"fun_record"
#define EVENTID_CANCELRECORD         @"fun_cancelrecord"
#define EVENTID_SHARE                @"fun_share"
#define EVENTID_SIGN                 @"fun_sign"
#define EVENTID_CANCELSUBSCRIBE      @"fun_cancelsubscribe"
#define EVENTID_CANCELRESERVE        @"fun_cancelreserve"
#define EVENTID_CANCELFAVORITE       @"fun_cancelfavorite"
#define EVENTID_CONFIRMRECORD        @"fun_confirmrecord"
#define EVENTID_NORECORD             @"fun_neednotrecord"

#define EVENTID_START_PLAY           @"start_play"
#define EVENTID_START_DOWNLOAD       @"vod_download"
#define EVENTID_DOWNLOAD_FINISHED    @"vod_download_finish"
#define EVENTID_START_OFFLINE_PLAY   @"offline_view"
#define EVENTID_END_OFFLINE_PLAY     @"offline_stop"


#define EVENTID_PLAY_VIEW            @"view"
#define EVENTID_PLAY_EPG             @"playing_epg"
#define EVENTID_PLAY_SHARE           @"playing_share"
#define EVENTID_PLAY_SIGN            @"playing_sign"
#define EVENTID_PLAY_ZAPING          @"playing_switchchannel"
#define EVENTID_PLAY_LRATE           @"playing_lrate"
#define EVENTID_PLAY_MRATE           @"playing_mrate"
#define EVENTID_PLAY_HRATE           @"playing_hrate"
#define EVENTID_PLAY_FAVORITE        @"playing_favorite"
#define EVENTID_PLAY_CANCELFAVORITE  @"playing_cancelfavorite"
#define EVENTID_PLAY_STOP            @"player_stop"

//广告
#define EVENTID_AD_SHOW              @"zgsdView"
#define EVENTID_AD_CLICK             @"zgsdClick"
#define EVENTID_PLAY_AD              @"macAdvCpm"

#define EVENTID_LOAD_PAGE            @"page_view" /*page_load*/

#define EVENTID_PUSHENGINE_KEEPALIVE  @"pushengine_keepalive"
#define EVENTID_PUSHENGINE_GETMSG     @"pushengine_getmessage"
#define EVENTID_PUSHMESSAGE_STARTAPP  @"pushmessage_startapp"
#define EVENTID_PUSHMESSAGE_STARTPLAY @"pushmessage_startplay"
#define EVENTID_PUSHMESSAGE_CANCEL    @"pushmessage_cancel"

//付费
#define EVENTID_PAYMENT_CLICK      @"payment_button_click"
#define EVENTID_PAY_START          @"payment_start_ali"
#define EVENTID_PAY_SUCCESS        @"payment_success_ali"
#define EVENTID_PAY_FAILD          @"payment_fail_ali"


#define ATTRIBUTE_POSITION  @"position"
#define ATTRIBUTE_KEYWORD   @"keyword"
#define ATTRIBUTE_PID       @"pid"
#define ATTRIBUTE_CPID      @"cpid"
#define ATTRIBUTE_ISSUB     @"issub"
#define ATTRIBUTE_BLOGTYPE  @"blogtype"
#define ATTRIBUTE_LENGTH    @"length"

#define ATTRIBUTE_VIDEO_ID   @"Videoid"
#define ATTRIBUTE_VIDEO_URL  @"url"
#define ATTRIBUTE_VIDEO_TYPE @"videotype"
#define ATTRIBUTE_VIDEO_NAME @"Videoname"
#define ATTRIBUTE_CP_NAME    @"cpName"
#define ATTRIBUTE_TAB_NAME   @"Tabname"
#define ATTRIBUTE_VOD_NAME   @"vodname"
#define ATTRIBUTE_LIVE_NAME  @"livename"
#define ATTRIBUTE_VIDEO_FLAG @"videoflag"

#define ATTRIBUTE_WEB_URL   @"page_url"
#define ATTRIBUTE_WEB_TITLE @"title"

#define ATTRIBUTE_MT        @"x_mt"
#define ATTRIBUTE_NT        @"x_nt"
#define ATTRIBUTE_24H       @"x_24h"
#define ATTRIBUTE_APPV      @"x_appv"
#define ATTRIBUTE_AREA      @"x_area"
#define ATTRIBUTE_OV        @"x_ov"
#define ATTRIBUTE_RS        @"x_rs"

#define ATTRIBUTE_LOCATION  @"location"


//pay
#define ATTRIBUTE_ORDER_NO           @"productorderid"
#define ATTRIBUTE_PRODUCT_NAME       @"productname"
#define ATTRIBUTE_PRODUCT_DESC       @"productdesc"
#define ATTRIBUTE_PRICE              @"money"
#define ATTRIBUTE_PAY_FAILD_REASON   @"reason"


#define CONTENT_HOME_RECOMMEND  @"首页_推荐"
#define CONTENT_HOME_SUBSCRIBE  @"首页_订阅列表"

#define CONTENT_FINDING_CONTENT @"发现"

#define CONTENT_SEARCH          @"搜索"

#define CONTENT_PERSON_HISTORY  @"个人中心_观看记录"
#define CONTENT_PERSON_FAVORITE @"个人中心_我的订阅"
