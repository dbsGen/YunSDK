//
//  MTOAuth.h
//  YunSDK
//
//  Created by zrz on 12-10-31.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MTOAuthDelegate;

@interface MTOAuth : NSObject {
//@protected
//    BOOL    _doing;
}

@property (nonatomic, assign)   id<MTOAuthDelegate> delegate;

@property (nonatomic, readonly) NSString    *consumerKey;
@property (nonatomic, readonly) NSString    *consumerSecret;
@property (nonatomic, readonly) UIWebView   *webView;
@property (nonatomic, strong)   NSOperationQueue    *queue;

//回调地址
@property (nonatomic, strong)   NSString    *callback;

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret;

- (BOOL)startOAuthWithWebView:(UIWebView *)webView;

@end

@protocol MTOAuthDelegate <NSObject>

@optional
- (void)oauthDidStartLoading:(MTOAuth *)oauth;
- (void)oauthDidStopLoading:(MTOAuth *)oauth;

- (void)oauth:(MTOAuth *)oauth faildWithError:(NSError *)error;
- (void)oauth:(MTOAuth *)oauth seccussWithOAuthInfo:(NSDictionary *)info;

@end