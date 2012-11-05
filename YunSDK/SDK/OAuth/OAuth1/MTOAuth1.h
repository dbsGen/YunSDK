//
//  MTOAuth1.h
//  YunSDK
//
//  Created by zrz on 12-10-31.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTOAuth.h"

@interface MTOAuth1 : MTOAuth
<UIWebViewDelegate>

@property (nonatomic, strong)   NSString    *requestURLString,
                                            *authorizeURLString,
                                            *accessURLString,
                                            *version;
- (void)reset;

@end
