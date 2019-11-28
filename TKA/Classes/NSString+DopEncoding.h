//
//  NSString+Encoding.h
//  Dopool
//
//  Created on 11-1-12.
//  Copyright (c) 2013年 Dopool. All rights reserved.
//

//#import <Foundation/Foundation.h>
@import Foundation;

@interface NSString (DopUrlEncoding)

- (NSString *)dopURLEncodedString;

- (NSString *)dopURLDecodedString;

@end
