//
//  MTOAuth2.m
//  YunSDK
//
//  Created by zrz on 12-11-1.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTOAuth2.h"
#import "MTCoderUtile.h"

#import "MTSelecterTransation.h"
#import "SBJson.h"

@interface MTOAuth2 ()
<UIWebViewDelegate>

@end

@implementation MTOAuth2 {
    MTSelecterTransation    *_transation;
    BOOL    _waitingForLoading;
}

#pragma mark - refresh token获得

- (void)startGetAccessTokenWithRefreshToken:(NSString *)refreshToken
{
    NSDictionary *params = @{
    @"grant_type"       : @"refresh_token",
    @"refresh_token"    : refreshToken,
    @"client_id"        : self.consumerKey,
    @"client_secret"    : self.consumerSecret,
    @"scope"            : self.scope
    };
    
    NSString *urlString = [MTCoderUtile encodeURLWithBaseURLString:self.accessURLString
                                                   params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:
                                         [NSURLRequest requestWithURL:url]];
    
    __unsafe_unretained MTOAuth2 *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [this getAccessToken:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(oauth:faildWithError:)]) {
            [this.delegate oauth:this faildWithError:error];
        }
    }];
    [self.queue addOperation:operation];
}

#pragma mark - 普通验证

- (BOOL)startOAuthWithWebView:(UIWebView *)webView
{
    BOOL ret = [super startOAuthWithWebView:webView];
    if (ret) {
        [self startAuthorize];
    }
    return ret;
}

- (void)startAuthorize
{
    NSDictionary *params = @{
    @"response_type"    : @"code",
    @"client_id"        : self.consumerKey,
    @"redirect_uri"     : self.callback,
    @"scope"            : self.scope,
    @"display"          : @"popup"
    };
    
    _transation = [[MTSelecterTransation alloc] init];
    _transation.sourceDelegate = self;
    _transation.targetDelegate = self.webView.delegate;
    _transation.protocol = @protocol(UIWebViewDelegate);
    self.webView.delegate = (id)_transation;
    
    NSString *urlString = [MTCoderUtile encodeURLWithBaseURLString:self.authorizeURLString
                                                   params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"%@", urlString);
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    if ([self.delegate respondsToSelector:@selector(oauthDidStartLoading:)]) {
        [self.delegate oauthDidStartLoading:self];
    }
    _waitingForLoading = YES;
}

- (void)getAuthorizeCode:(NSString *)urlString
{
    if ([self.delegate respondsToSelector:@selector(oauthDidStartLoading:)]) {
        [self.delegate oauthDidStartLoading:self];
    }
    
    NSDictionary *result = [MTCoderUtile decodeURLString:urlString];
    NSString *authorizeCode = [result objectForKey:@"code"];
    
    NSDictionary *params = @{
    @"grant_type"       : @"authorization_code",
    @"code"             : authorizeCode,
    @"client_id"        : self.consumerKey,
    @"client_secret"    : self.consumerSecret,
    @"redirect_uri"     : self.callback
    };
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:
                            [NSURL URLWithString:self.accessURLString]];
    NSMutableURLRequest *request = [client requestWithMethod:@"GET"
                                                        path:nil
                                                  parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    __unsafe_unretained MTOAuth2 *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [this getAccessToken:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request access token faild : %@", error);
        if ([this.delegate respondsToSelector:@selector(oauth:faildWithError:)]) {
            [this.delegate oauth:this faildWithError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)getAccessToken:(NSData *)data
{
    NSDictionary *result = [data JSONValue];
    if ([self.delegate respondsToSelector:@selector(oauthDidStopLoading:)]) {
        [self.delegate oauthDidStopLoading:self];
    }
    if ([self.delegate respondsToSelector:@selector(oauth:seccussWithOAuthInfo:)]) {
        [self.delegate oauth:self seccussWithOAuthInfo:result];
    }
}

#pragma mark - web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_waitingForLoading) {
        _waitingForLoading = NO;
        if ([self.delegate respondsToSelector:@selector(oauthDidStopLoading:)]) {
            [self.delegate oauthDidStopLoading:self];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.description;
    if ([urlString hasPrefix:self.callback]) {
        [self getAuthorizeCode:urlString];
        self.webView.delegate = _transation.targetDelegate;
        _transation = nil;
        return NO;
    }
    return YES;
}

@end
