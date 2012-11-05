//
//  MTOAuth2.h
//  YunSDK
//
//  Created by zrz on 12-11-1.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTOAuth.h"

@interface MTOAuth2 : MTOAuth

@property (nonatomic, strong)   NSString    *authorizeURLString,
                                            *accessURLString,
                                            *scope;
- (void)startGetAccessTokenWithRefreshToken:(NSString *)refreshToken;

@end
