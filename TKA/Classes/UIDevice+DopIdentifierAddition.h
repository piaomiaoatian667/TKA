//
//  UIDevice(Identifier).h
//  Dopool
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import Foundation;

@interface UIDevice (DopIdentifierAddition)

- (NSString *)dopMacAddress;

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates a hash from the MAC-address in combination with the bundle identifier
 * of your app.
 */

- (NSString *)dopUniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. as example a advertising network will use this method to track the device
 * from different apps.
 * It generates a hash from the MAC-address only.
 */

- (NSString *)dopUniqueGlobalDeviceIdentifier;
- (NSString *)dopAppId;
- (NSString *)dopAppName;
- (NSString *)dopAppVersion;
- (BOOL)dopSupportMultitask;
- (BOOL)dopSupportRunningInBackground;
- (BOOL)dopDeviceIsiPad;
- (BOOL)dopDeviceIsiPhone5;

@end
