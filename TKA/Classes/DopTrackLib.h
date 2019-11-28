//
//  DopTrackLib.h
//  Dopool
//
//  Created by zzg on 13-4-1.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Foundation;
#import <sqlite3.h>

// Define check string method.
#define CHECK_STR_OBJ(strObj, value) if(nil == (strObj) || 0 == [(strObj) length]) (strObj) = (value)

// Define database name.
#define DB_NAME_PLAYER      (@"DopTrackLib.sql")

// Define database version.
#define DB_VER_PLAYER       (@"1.0")
#define DB_VER_PLAYER_KEY   (@"DBTrackVerKey")

#define CREATE_DOPTRACKER_TABLE     "CREATE TABLE IF NOT EXISTS Trackerlist (Time double PRIMARY KEY, TrackerData TEXT)"

@interface DopTrackLib : NSObject
{
    sqlite3 *m_Database;
}

// Create and initialize object method.
- (id)init;

// Manage dopTracker function.
- (BOOL)getTracker:(NSMutableArray *)trackerList curTrackerTime:(double)curTrackerTime;
- (BOOL)getTimeWithTrackerData:(NSString *)trackerData time:(double*)time;
- (BOOL)insertTrackerData:(double)trackerTime trackData:(NSString *)trackData;
- (BOOL)insertTrackerList:(NSArray *)trackerList;
- (BOOL)deleteAllTrackerData;
- (BOOL)deleteTrackerDataBeforeTime:(double)time;

@end
