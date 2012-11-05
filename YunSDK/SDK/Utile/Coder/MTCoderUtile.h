//
//  MTCoderUtile.h
//  YunSDK
//
//  Created by zrz on 12-10-31.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface MTCoderUtile : NSObject

+ (NSString *)oauthSignature:(NSString *)method
                         url:(NSString *)urlString
                      params:(NSDictionary *)params
                      secret:(NSString *)secret;

+ (NSDictionary *)decodeURLString:(NSString *)urlString;

+ (NSString *)encodeWithUTF8:(NSString *)inString;

+ (NSString *)encodeWithHMAC_SHA1:(NSString *)inString
                           secret:(NSString *)secret;

+ (NSString *)encodeURLWithBaseURLString:(NSString *)urlString
                               params:(NSDictionary *)params;

@end
