//
//  MTOAuth.m
//  YunSDK
//
//  Created by zrz on 12-10-31.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTOAuth.h"

@implementation MTOAuth

@synthesize consumerKey = _consumerKey;
@synthesize consumerSecret = _consumerSecret;
@synthesize webView = _webView;
@synthesize queue = _queue;

- (void)dealloc
{
    [_queue cancelAllOperations];
}

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
{
    self = [super init];
    if (self) {
        _consumerKey = consumerKey;
        _consumerSecret = consumerSecret;
    }
    return self;
}

- (BOOL)startOAuthWithWebView:(UIWebView *)webView
{
    if (!webView) {
        NSLog(@"webView is nil");
        return NO;
    }
    //_doing = YES;
    _webView = webView;
    return YES;
}

- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setSuspended:NO];
    }
    return _queue;
}

@end
