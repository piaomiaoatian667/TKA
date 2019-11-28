//
//  DopBase64.h
//  Dopool
//
//  Created by Kiichi Takeuchi on 4/20/10.
//  Copyright (c) 2013年 Dopool. All rights reserved.
// 
// Original Source Code is donated by Cyrus
// Public Domain License
// 

//#import <Foundation/Foundation.h>
@import Foundation;

@interface DopBase64 : NSObject {

}
+ (void) initialize;
+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;
+ (NSString*) encode:(NSData*) rawBytes;
+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;
+ (NSData*) decode:(NSString*) string;
@end
