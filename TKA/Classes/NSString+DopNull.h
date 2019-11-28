//
//  NSString+Null.h
//  Dopool
//
//  Created by l lb on 13-1-29.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

//#import <Foundation/Foundation.h>
@import Foundation;
@interface NSString (DopNull)

+ (BOOL)dopStringIsEmpty:(NSString *)string;
+ (BOOL)dopStringIsInvalid:(NSString *)string;
- (BOOL)dopIsValid;
- (BOOL)dopIsValidUrl;

@end
