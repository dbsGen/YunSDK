//
//  MTOAuth1.m
//  YunSDK
//
//  Created by zrz on 12-10-31.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTOAuth1.h"
#import "MTTools.h"
#import "NSString+MTString.h"
#import "MTCoderUtile.h"
#import "MTSelecterTransation.h"
#import "SBJson.h"

@implementation MTOAuth1 {
    NSString    *_oauthTokenSecret;
    MTSelecterTransation    *_transation;
    BOOL    _waitingForLoadOver;
}

@synthesize version = _version;

- (BOOL)startOAuthWithWebView:(UIWebView *)webView
{
    BOOL ret = [super startOAuthWithWebView:webView];
    if (ret) {
        [self reset];
        [self startGetRequestToken];
    }
    return ret;
}

- (void)reset
{
    _oauthTokenSecret = nil;
    _waitingForLoadOver = NO;
    [self.queue cancelAllOperations];
}

#pragma mark - net work

- (NSString *)version
{
    if (!_version) {
        _version = @"1.0";
    }
    return _version;
}

- (void)startGetRequestToken
{
    if ([self.delegate respondsToSelector:@selector(oauthDidStartLoading:)]) {
        [self.delegate oauthDidStartLoading:self];
    }
    
    NSDictionary *params =
    @{
        @"oauth_consumer_key"       : self.consumerKey,
        @"oauth_signature_method"   : @"HMAC-SHA1" ,
        @"oauth_timestamp"          : [NSString stringWithFormat:@"%d",
                                       (int)[[NSDate date] timeIntervalSince1970]],
        @"oauth_nonce"              : [MTTools UUID],
        @"oauth_version"            : self.version ,
        @"oauth_callback"           : self.callback
    };
    
    NSDictionary *retParams = [self oauth1SignatureWithParams:params
                                                       method:@"GET"
                                                          url:self.requestURLString];
    NSLog(@"%@", self.requestURLString);
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self.requestURLString stringByDeletingLastPathComponentEx]]];
    
    
    NSMutableURLRequest *request = [client requestWithMethod:@"GET"
                                                        path:[self.requestURLString lastPathComponent]
                                                  parameters:retParams];
    
    NSLog(@"%@", request.URL);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTOAuth1 *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [this getRequestToken:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if ([this.delegate respondsToSelector:@selector(oauth:faildWithError:)]) {
            [this.delegate oauth:this
                  faildWithError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)getRequestToken:(NSData *)responseData
{
    NSDictionary *requstResult = [responseData JSONValue];
    NSString *oauthToken = [requstResult objectForKey:@"oauth_token"];
    _oauthTokenSecret = [requstResult objectForKey:@"oauth_token_secret"];
    
    if (self.webView.delegate) {
        _transation = [[MTSelecterTransation alloc] init];
        _transation.sourceDelegate = self;
        _transation.targetDelegate = self.webView.delegate;
        _transation.protocol = @protocol(UIWebViewDelegate);
        _transation.cross = YES;
        self.webView.delegate = (id)_transation;
    }else {
        _transation = nil;
        self.webView.delegate = self;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:
                              [NSString stringWithFormat:
                               self.authorizeURLString, oauthToken]]];
    [self.webView loadRequest:request];
    _waitingForLoadOver = YES;
    
}

- (void)getOAuthToken:(NSString *)urlString
{
    if ([self.delegate respondsToSelector:@selector(oauthDidStartLoading:)]) {
        [self.delegate oauthDidStartLoading:self];
    }
    NSDictionary *params = [MTCoderUtile decodeURLString:urlString];
    NSString *oauthToken = [params objectForKey:@"oauth_token"];
    NSString *oauthVerifier = [params objectForKey:@"oauth_verifier"];
    
    NSDictionary *sourceParams =
    @{@"oauth_consumer_key"     : self.consumerKey,
    @"oauth_signature_method"   : @"HMAC-SHA1",
    @"oauth_timestamp"          : [NSString stringWithFormat:@"%d",
                                   (int)[[NSDate date] timeIntervalSince1970]],
    @"oauth_nonce"              : [MTTools UUID],
    @"oauth_version"            : self.version,
    @"oauth_token"              : oauthToken,
    @"oauth_verifier"           : oauthVerifier};
    
    NSDictionary *resultParams = [self oauth1SignatureWithParams:sourceParams
                                                          method:@"GET"
                                                             url:self.accessURLString];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:
                            [NSURL URLWithString:[self.accessURLString stringByDeletingLastPathComponentEx]]];
    NSMutableURLRequest *request = [client requestWithMethod:@"GET"
                                                        path:[self.accessURLString lastPathComponent]
                                                  parameters:resultParams];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTOAuth1 *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [this getAccessToken:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if ([this.delegate respondsToSelector:@selector(oauth:faildWithError:)]) {
            [this.delegate oauth:this faildWithError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)getAccessToken:(NSData *)responseData
{
    NSDictionary *result = [responseData JSONValue];
    if ([self.delegate respondsToSelector:@selector(oauthDidStopLoading:)]) {
        [self.delegate oauthDidStopLoading:self];
    }
    if ([self.delegate respondsToSelector:@selector(oauth:seccussWithOAuthInfo:)]) {
        [self.delegate oauth:self seccussWithOAuthInfo:result];
    }
}

#pragma mark - web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.description;
    if ([url hasPrefix:self.callback]) {
        //回调
        if ([self.delegate respondsToSelector:@selector(oauthDidStopLoading:)]) {
            [self.delegate oauthDidStopLoading:self];
        }
        [self getOAuthToken:url];
        self.webView.delegate = _transation.targetDelegate;
        _transation = nil;
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_waitingForLoadOver) {
        _waitingForLoadOver = NO;
        if ([self.delegate respondsToSelector:@selector(oauthDidStopLoading:)]) {
            [self.delegate oauthDidStopLoading:self];
        }
    }
}

#pragma mark - private method

- (NSDictionary *)oauth1SignatureWithParams:(NSDictionary *)params
                                     method:(NSString *)method
                                        url:(NSString *)urlString
{
    NSString *secret = [self.consumerSecret stringByAppendingString:@"&"];
    if (_oauthTokenSecret) {
        secret = [secret stringByAppendingString:_oauthTokenSecret];
    }
    NSMutableDictionary *outParams = [params mutableCopy];
    NSString *sign = [MTCoderUtile oauthSignature:method
                                              url:urlString
                                           params:params
                                           secret:secret];
    
    [outParams setObject:sign
                  forKey:@"oauth_signature"];
    return [outParams copy];
}

@end
