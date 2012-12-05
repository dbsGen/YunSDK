//
//  MTBaiduClient.m
//  YunSDK
//
//  Created by zrz on 12-11-4.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTBaiduClient.h"
#import "MTSelecterTransation.h"
#import "MTOAuth2.h"
#import "Config.h"
#import "MTCoderUtile.h"
#import "AFNetworking.h"
#import "SBJson.h"

@implementation MTBaiduClient {
    MTOAuth2    *_oauth;
    AFHTTPClient    *_httpClient;
    MTSelecterTransation    *_transation;
}

@synthesize consumerKey = _consumerKey;
@synthesize consumerSecret = _consumerSecret;
@synthesize callback = _callback;
@synthesize delegate = _delegate;
@synthesize queue = _queue;

- (MTOAuth2 *)newOAuth
{
    MTOAuth2 *oauth = [[MTOAuth2 alloc] initWithConsumerKey:_consumerKey
                                             consumerSecret:_consumerSecret];
    oauth.delegate = (id)_transation;
    oauth.scope = @"netdisk";
    oauth.callback = _callback;
    oauth.authorizeURLString = kBaiduAuthorizeURLString;
    oauth.accessURLString = kBaiduAccessTokenURLString;
    
    return oauth;
}

- (void)dealloc
{
    [self.queue cancelAllOperations];
}

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
{
    self = [super init];
    if (self) {
        _consumerKey = consumerKey;
        _consumerSecret = consumerSecret;
        
        _transation = [[MTSelecterTransation alloc] init];
        _transation.protocol = @protocol(MTOAuthDelegate);
        _transation.sourceDelegate = self;
        _transation.targetDelegate = nil;
        _transation.cross = YES;
        [self cleanCookies];
    }
    return self;
}

- (BOOL)startOAuthWithWebView:(UIWebView *)webView
{
    if (!_oauth) {
        _oauth = [self newOAuth];
    }
    return [_oauth startOAuthWithWebView:webView];
}

- (void)cleanCookies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *willDeletes = [storage.cookies filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"domain LIKE[cd] %@", @"*.baidu.com*"]];
    for (NSHTTPCookie *cookie in willDeletes) {
        [storage deleteCookie:cookie];
    }
}

#pragma mark - oauth delegate

- (void)oauth:(MTOAuth *)oauth seccussWithOAuthInfo:(NSDictionary *)info
{
    self.oauthInfo = info;
}

#pragma mark - net work 

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)path
                                 urlParams:(NSDictionary *)urlParams
                                formParams:(NSDictionary *)formParams
{
    return [self requestWithMethod:method
                           urlPath:path
                         urlParams:urlParams
                        formParams:formParams
                           baseUrl:kBaiduBaseURLString];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)path
                                 urlParams:(NSDictionary *)urlParams
                                formParams:(NSDictionary *)formParams
                                   baseUrl:(NSString *)baseUrl
{
    AFHTTPClient *client = nil;
    if ([baseUrl isEqualToString:kBaiduBaseURLString]) {
        client = [self httpClient];
    }else {
        client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    }
    if ([method isEqualToString:@"POST"]) {
        //使用表单上传
        NSString *urlString = [MTCoderUtile encodeURLWithBaseURLString:path
                                                                params:urlParams];
        return [client multipartFormRequestWithMethod:method
                                                 path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                           parameters:nil
                            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                [formParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                    [formData appendPartWithFileData:obj
                                                                name:key
                                                            fileName:key
                                                            mimeType:@"Multipart/form-data"];
                                }];
                            }];
    }else {
        return [client requestWithMethod:method
                                    path:path
                              parameters:urlParams];
    }
}

#pragma mark - APIs

#define UnretainedSelf(this)  __unsafe_unretained MTBaiduClient *this = self

- (void)checkDiskQuota
{
    NSDictionary *params = @{
    @"access_token" : [self accessToken],
    @"method"       : @"info"
    };
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kBaiduQuotaURLAdd
                                                 urlParams:params
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    UnretainedSelf(this);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:getDiskQuota:withError:)]) {
            [this.delegate client:this
                     getDiskQuota:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if ([this.delegate respondsToSelector:@selector(client:getDiskQuota:withError:)]) {
            [this.delegate client:this
                     getDiskQuota:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)uploadFile:(NSString *)path
              file:(NSData *)file
{
    NSDictionary *params =@{
    @"method"       : @"upload",
    @"access_token" : [self accessToken],
    @"path"         : path
    };
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                   urlPath:kBaiduFileURLAdd
                                                 urlParams:params
                                                formParams:@{@"file" : file}];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    UnretainedSelf(this);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
            [this.delegate client:this
                       uploadFile:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
            [this.delegate client:this
                       uploadFile:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)createFolderWithPath:(NSString *)path
{
    NSDictionary *params = @{
    @"method"       : @"mkdir",
    @"access_token" : [self accessToken],
    @"path"         : path
    };
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                   urlPath:kBaiduFileURLAdd
                                                 urlParams:params
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    UnretainedSelf(this);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:createFolder:withError:)]) {
            [this.delegate client:this
                     createFolder:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:createFolder:withError:)]) {
            [this.delegate client:this
                     createFolder:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)deleteFile:(NSString *)path
{
    NSDictionary *params = @{
    @"method"       : @"delete",
    @"access_token" : [self accessToken],
    @"path"         : path
    };
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                   urlPath:kBaiduFileURLAdd
                                                 urlParams:params
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    UnretainedSelf(this);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:deleteFile:withError:)]) {
            [this.delegate client:this
                       deleteFile:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:deleteFile:withError:)]) {
            [this.delegate client:this
                       deleteFile:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)downloadFile:(NSString *)path
{
    NSDictionary *params = @{
    @"method"       : @"download",
    @"access_token" : [self accessToken],
    @"path"         : path
    };
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kBaiduFileURLAdd
                                                 urlParams:params
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    UnretainedSelf(this);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:downloadFile:withError:)]) {
            [this.delegate client:this
                     downloadFile:responseObject
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:downloadFile:withError:)]) {
            [this.delegate client:this
                     downloadFile:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

#pragma mark - setter and getter


- (AFHTTPClient *)httpClient
{
    if (!_httpClient) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaiduBaseURLString]];
    }
    return _httpClient;
}

- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setSuspended:NO];
    }
    return _queue;
}

- (void)setDelegate:(id<MTBaiduClientDelegate>)delegate
{
    _delegate = delegate;
    _transation.targetDelegate = delegate;
}

- (NSString *)accessToken
{
    return [self.oauthInfo objectForKey:@"access_token"];
}

@end
