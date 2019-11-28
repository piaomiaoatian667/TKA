//
//  DopTrackLib.m
//  Dopool
//
//  Created by zzg on 13-4-1.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import "DopTrackLib.h"
//#import "ARCMacros.h"
//#import "DebugMacros.h"
#import "NSDate+DopBJZone.h"

@interface DopTrackLib()

- (void)createDatabaseIfNeeded;
- (void)createDatabase;
- (BOOL)openDatabase;
- (void)closeDatabase;
- (BOOL)deleteDatabase;
- (NSString *)databasePath;

@end

@implementation DopTrackLib

- (id)init
{
    self = [super init];
    if (self)
    {
        [self createDatabaseIfNeeded];
    }
    return self;
}


#pragma mark -
#pragma mark Manger DopTrackerLib
- (BOOL)getTracker:(NSMutableArray *)trackerList curTrackerTime:(double)curTrackerTime;
{
    if(nil == trackerList || nil == trackerList)
    {
		return NO;
	}
	
	BOOL bRet = YES;
	[trackerList removeAllObjects];
	
	do {
		bRet = [self openDatabase];
		if(!bRet)
        {
			break;
		}
		
		sqlite3_stmt *statement = NULL;
		const char *sql = "SELECT * FROM Trackerlist WHERE Time < ? ORDER BY Time limit 50";
		if(sqlite3_prepare_v2(m_Database, sql, -1, &statement, NULL) != SQLITE_OK)
        {
			bRet = NO;
			break;
		}
        
        sqlite3_bind_double(statement, 1, curTrackerTime);
		while(sqlite3_step(statement) == SQLITE_ROW)
        {
            double dTrackerTime = sqlite3_column_double(statement, 0);
            NSNumber *trackerTime = [NSNumber numberWithDouble:dTrackerTime];
            
			const char *szTrackerData = (const char *)sqlite3_column_text(statement, 1);
            if(!szTrackerData)
            {
                continue;
            }
			NSString *strTrackerData = [NSString stringWithUTF8String:szTrackerData];
                                        
			NSDictionary *oneTracker = [NSDictionary dictionaryWithObjectsAndKeys:trackerTime, @"key", strTrackerData, @"info", nil];
			[trackerList addObject:oneTracker];
		}
		
		sqlite3_finalize(statement);
	}while(NO);
	
	[self closeDatabase];
	return bRet;
}


- (BOOL)insertTrackerData:(double)trackerTime trackData:(NSString *)trackData
{
    BOOL bRet = YES;
    
	do {
		bRet = [self openDatabase];
		if(!bRet)
        {
			break;
		}
		
		sqlite3_stmt *statement = NULL;
		const char *sql = "INSERT INTO Trackerlist (Time,TrackerData) VALUES(?,?)";
        
        if(sqlite3_prepare_v2(m_Database, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            bRet = NO;
            break;
        }
        
        sqlite3_bind_double(statement, 1, trackerTime);
        sqlite3_bind_text(statement, 2, [trackData UTF8String], -1, SQLITE_TRANSIENT);
        
        if(sqlite3_step(statement) != SQLITE_DONE)
        {
            bRet = NO;
        }
        
		sqlite3_finalize(statement);
	}while(NO);
	
	[self closeDatabase];
	return bRet;
}


- (BOOL)insertTrackerList:(NSArray *)trackerList
{
	if(nil == trackerList || 0 == [trackerList count])
    {
		return NO;
	}
	
	BOOL bRet = YES;
	
	do {
		bRet = [self openDatabase];
		if(!bRet)
        {
			break;
		}
		
		sqlite3_stmt *statement = NULL;
		const char *sql = "INSERT INTO Trackerlist (Time, TrackerData) VALUES(?,?)";
		
        for(NSDictionary *oneTracker in trackerList)
        {
            if(sqlite3_prepare_v2(m_Database, sql, -1, &statement, NULL) != SQLITE_OK)
            {
				bRet = NO;
				break;
			}
			
            double trackerTime = [[oneTracker objectForKey:@"key"] doubleValue];
            NSString *trackerInfo = [oneTracker objectForKey:@"info"];
			sqlite3_bind_double(statement, 1, trackerTime);
            sqlite3_bind_text(statement, 2, [trackerInfo UTF8String], -1, SQLITE_TRANSIENT);
			
			if(sqlite3_step(statement) != SQLITE_DONE)
            {
				bRet = NO;
				break;
			}
			
			sqlite3_reset(statement);
        }
		
		sqlite3_finalize(statement);
	}while(NO);
	
	[self closeDatabase];
	return bRet;
}


- (BOOL)deleteAllTrackerData
{
    BOOL bRet = YES;
	
	do {
		bRet = [self openDatabase];
		if(!bRet)
        {
			break;
		}
		
		sqlite3_stmt *statement = NULL;
		const char *sql = "DELETE FROM Trackerlist";
		if(sqlite3_prepare_v2(m_Database, sql, -1, &statement, NULL) != SQLITE_OK)
        {
			bRet = NO;
			break;
		}
		
		if(sqlite3_step(statement) != SQLITE_DONE)
        {
			bRet = NO;
		}
		sqlite3_finalize(statement);
	}while(NO);
	
	[self closeDatabase];
	return bRet;
}


- (BOOL)getTimeWithTrackerData:(NSString *)trackerData time:(double *)time
{
    if(nil == trackerData)
    {
		return NO;
	}
    
    BOOL bRet = YES;
	
	do {
		bRet = [self openDatabase];
		if(!bRet)
        {
			break;
		}
		
		sqlite3_stmt *statement = NULL;
		const char *sql = "SELECT * FROM Trackerlist WHERE TrackerData = ?";
		if(sqlite3_prepare_v2(m_Database, sql, -1, &statement, NULL) != SQLITE_OK)
        {
			bRet = NO;
			break;
		}
        
		sqlite3_bind_text(statement, 1, [trackerData UTF8String], -1, SQLITE_TRANSIENT);
        
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            *time = sqlite3_column_double(statement, 0);
		}
        
		sqlite3_finalize(statement);
	}while(NO);
	
	[self closeDatabase];
	return bRet;
}


- (BOOL)deleteTrackerDataBeforeTime:(double)time
{
    BOOL bRet = YES;
	
	do {
		bRet = [self openDatabase];
		if(!bRet)
        {
			break;
		}
		
		sqlite3_stmt *statement = NULL;
		const char *sql = "DELETE FROM Trackerlist WHERE Time <= ?";
		if(sqlite3_prepare_v2(m_Database, sql, -1, &statement, NULL) != SQLITE_OK)
        {
			bRet = NO;
			break;
		}
        
        sqlite3_bind_double(statement, 1, time);
        
		if(sqlite3_step(statement) != SQLITE_DONE)
        {
			bRet = NO;
		}
		
		sqlite3_finalize(statement);
	}while(NO);
	
	[self closeDatabase];
	return bRet;
}


#pragma mark -
#pragma mark Class Private Function
- (void)createDatabaseIfNeeded
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *databasePath = [self databasePath];
	if([fileManager fileExistsAtPath:databasePath])
    {
        return;
    }
    
    [self createDatabase];
}


- (void)createDatabase
{
    if(![self openDatabase])
    {
		[self closeDatabase];
        return;
	}
    
    const char *sql = NULL;
	const char *tableName = NULL;
	char *errMsg = NULL;
    
    do {

        sql = CREATE_DOPTRACKER_TABLE;
        errMsg = NULL;
        if(sqlite3_exec(m_Database, sql, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            tableName = "DopTrack";
            break;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:DB_VER_PLAYER forKey:DB_VER_PLAYER_KEY];
	}while(NO);
    
	[self closeDatabase];
	
	if (tableName != NULL)
    {
        NSLog(@"[ERORR] Failed to create table '%s' with message '%s'.", tableName, errMsg);
	}
}


- (BOOL)openDatabase
{
	if(sqlite3_open([[self databasePath] UTF8String], &m_Database) != SQLITE_OK)
    {
        NSLog(@"[ERROR] Failed to open database with message '%s'.", sqlite3_errmsg(m_Database));
		return NO;
	}
	return YES;
}


- (void)closeDatabase
{
	sqlite3_close(m_Database);
	m_Database = NULL;
}


- (BOOL)deleteDatabase
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDir = [pathArray objectAtIndex:0];
	NSString *databasePath = [documentDir stringByAppendingPathComponent:DB_NAME_PLAYER];
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath])
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error])
        {
            NSLog(@"[ERROR] Delete DB of the player failed. message: %@", [error localizedDescription]);
            return NO;
        }
    }
    
    return YES;
}


- (NSString *)databasePath
{
	NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDir = [pathArray objectAtIndex:0];
	NSString *databasePath = [documentDir stringByAppendingPathComponent:DB_NAME_PLAYER];
	
	return databasePath;
}

@end
