//
//  MTKuaiPanClient.m
//  YunSDK
//
//  Created by zrz on 12-11-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTKuaiPanClient.h"
#import "MTOAuth1.h"
#import "MTSelecterTransation.h"
#import "MTTools.h"
#import "Config.h"
#import "SBJson.h"
#import "MTCoderUtile.h"
#import "NSString+MTString.h"

@implementation MTKuaiPanClient{
    MTSelecterTransation    *_transtion;
    MTOAuth1    *_oauth;
    AFHTTPClient    *_httpClient;
}

@synthesize consumerKey = _consumerKey;
@synthesize consumerSecret = _consumerSecret;
@synthesize queue = _queue;
@synthesize oauthInfo = _oauthInfo;
@synthesize delegate = _delegate;
@synthesize callback = _callback;

- (MTOAuth1 *)newOAuth
{
    MTOAuth1 *oauth = [[MTOAuth1 alloc] initWithConsumerKey:_consumerKey
                                             consumerSecret:_consumerSecret];
    oauth.requestURLString = [kKuaiPanBaseURLString stringByAppendingString:kKuaiPanRequestTokenURLAdd];
    oauth.authorizeURLString = kKuaiPanAuthorizeURLString;
    oauth.accessURLString = [kKuaiPanBaseURLString stringByAppendingString:kKuaiPanAccessTokenURLAdd];
    oauth.version = @"1.0";
    oauth.callback = _callback;
    
    oauth.delegate = (id)_transtion;
    return oauth;
}

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setSuspended:NO];
        
        _consumerKey = consumerKey;
        _consumerSecret = consumerSecret;
        
        _transtion = [[MTSelecterTransation alloc] init];
        _transtion.sourceDelegate = self;
        _transtion.targetDelegate = self;
        _transtion.cross = YES;
        _transtion.protocol = @protocol(MTOAuthDelegate);
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

#pragma mark - oauth  delegate

- (void)setDelegate:(id<MTOAuthDelegate>)delegate
{
    _delegate = (id)delegate;
    _transtion.targetDelegate = _delegate;
}

- (void)oauth:(MTOAuth *)oauth seccussWithOAuthInfo:(NSDictionary *)info
{
    _oauthInfo = info;
}

#pragma mark - net work

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)path
                                 urlParams:(NSDictionary *)urlParams
                                formParams:(NSDictionary *)formParams
                                   baseUrl:(NSString *)baseUrl
{
    NSMutableDictionary *sourceParams = [self oauthParams];
    [urlParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [sourceParams setObject:obj forKey:key];
    }];
    
    
    NSString *urlString = [baseUrl stringByAppendingString:path];
    NSString *secret = [_consumerSecret stringByAppendingString:@"&"];
    NSString *accessSecret = [_oauthInfo objectForKey:kOAuthTokenSecret];
    if (accessSecret) secret = [secret stringByAppendingString:accessSecret];
    NSString *signature = [MTCoderUtile oauthSignature:method
                                                   url:urlString
                                                params:sourceParams
                                                secret:secret];
    
    [sourceParams setObject:signature
                     forKey:@"oauth_signature"];
    
    if ([method isEqualToString:@"POST"] && formParams) {
        NSString *string = [MTCoderUtile encodeURLWithBaseURLString:path
                                                             params:sourceParams];
        AFHTTPClient *client;
        if ([baseUrl isEqualToString:kKuaiPanBaseURLString]) {
            client = [self httpClient];
        }else {
            client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        }
        
        return [client multipartFormRequestWithMethod:method
                                                 path:[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
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
        AFHTTPClient *client;
        if ([baseUrl isEqualToString:kKuaiPanBaseURLString]) {
            client = [self httpClient];
        }else {
            client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        }
        return [client requestWithMethod:method
                                    path:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                              parameters:sourceParams];
    }
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method urlPath:(NSString *)path urlParams:(NSDictionary *)urlParams formParams:(NSDictionary *)formParams
{
    return [self requestWithMethod:method
                           urlPath:path
                         urlParams:urlParams
                        formParams:formParams
                           baseUrl:kKuaiPanBaseURLString];
}

#pragma mark - APIs

- (void)checkAccountInfo
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kKuaiPanUserInfoURLAdd
                                                 urlParams:nil
                                                formParams:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTKuaiPanClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:getAccountInfo:withError:)]) {
            [this.delegate client:this
                   getAccountInfo:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:getAccountInfo:withError:)]) {
            [this.delegate client:this
                   getAccountInfo:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)metadataWithPath:(NSString *)path
                    list:(NSNumber *)isList
               fileLimit:(NSNumber *)fileLimit
                    page:(NSNumber *)page
                pageSize:(NSNumber *)pageSize
               filterExt:(NSString *)filter
                  sortBy:(NSString *)sortBy
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (isList) {
        [params setObject:isList.stringValue
                   forKey:@"list"];
    }
    if (fileLimit) {
        [params setObject:fileLimit.stringValue
                   forKey:@"list_limit"];
    }
    if (page) {
        [params setObject:page.stringValue
                   forKey:@"page"];
    }
    if (pageSize) {
        [params setObject:pageSize.stringValue
                   forKey:@"page_size"];
    }
    if (filter) {
        [params setObject:filter
                   forKey:@"filter_ext"];
    }
    if (sortBy) {
        [params setObject:sortBy
                   forKey:@"sort_by"];
    }
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:[kKuaiPanMetadataURLAdd stringByAppendingString:
                                                            [NSString stringWithFormat:@"/%@%@",self.root,path]]
                                                 urlParams:params
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTKuaiPanClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:getMetadata:withError:)]) {
            [this.delegate client:this
                      getMetadata:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:getMetadata:withError:)]) {
            [this.delegate client:this
                      getMetadata:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)createFolderWithPath:(NSString *)path
{
    if (!path) {
        path = @"/";
        Log_warning(@"Path为空，被替换成'/'");
    }
    NSDictionary *params = @{@"root" : self.root, @"path" : path};
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kKuaiPanCreateFolderURLAdd
                                                 urlParams:params
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTKuaiPanClient *this = self;
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

- (void)getShareAddress:(NSString *)path name:(NSString *)name accessToken:(NSString *)accessToken
{
    if (!path) {
        path = @"/";
        Log_warning(@"Path为空，被替换成'/'");
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) {
        [params setObject:name
                   forKey:@"name"];
    }
    if (accessToken) {
        [params setObject:accessToken
                   forKey:@"access_code"];
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:[kKuaiPanShareLinkURLAdd stringByAppendingFormat:
                                                            @"/%@%@", self.root, path]
                                                 urlParams:params
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTKuaiPanClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:getShareLink:withError:)]) {
            [this.delegate client:this
                     getShareLink:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:getShareLink:withError:)]) {
            [this.delegate client:this
                     getShareLink:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)fileHistory:(NSString *)path
{
    if (!path) {
        path = @"/";
        Log_warning(@"Path为空，被替换成'/'");
    }
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:[kKuaiPanFileHistoryURLAdd stringByAppendingFormat:
                                                            @"/%@%@", self.root, path]
                                                 urlParams:nil
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTKuaiPanClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:fileHistory:withError:)]) {
            [this.delegate client:this
                      fileHistory:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:fileHistory:withError:)]) {
            [this.delegate client:this
                      fileHistory:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)deleteFile:(NSString *)path toRecycle:(NSString *)toRecycle
{
    if (!path) {
        path = @"/";
        Log_warning(@"Path为空，被替换成'/'");
    }
    NSDictionary *params = nil;
    if (toRecycle) {
        params = @{
        @"root"         : self.root,
        @"path"         : path,
        @"to_recycle"   : toRecycle
        };
    }else {
        Log_info(@"to_recycle参数为空");
        params = @{
        @"root"         : self.root,
        @"path"         : path
        };
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kKuaiPanFileDeleteURLAdd
                                                    urlParams:params
                                                formParams:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTKuaiPanClient *this = self;
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

- (void)uploadFile:(NSString *)path file:(NSData *)file overWritr:(BOOL)overWrite sourceIp:(NSString *)sourceIp
{
    Log_info(@"开始上传文件,文件长度%d", file.length);
    if (!path) {
        path = @"/";
        Log_warning(@"Path为空，被替换成'/'");
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (sourceIp) {
        [params setObject:sourceIp forKey:@"source_ip"];
    }
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kKuaiPanUploadLocateURLAdd
                                                    urlParams:params
                                                    formParams:nil
                                                    baseUrl:kKuaiPanFileServerBaseURLString];
    AFHTTPRequestOperation *opretion = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTKuaiPanClient *this = self;
    [opretion setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *result = [responseObject JSONValue];
         NSString *stat = [result objectForKey:@"stat"];
         
         if ([stat isEqualToString:@"OK"]) {
             NSString *url = [result objectForKey:@"url"];
             Log_info(@"获得上传服务器url : %@", url);
             NSDictionary *params = @{
             @"overwrite"    : overWrite ? @"true" : @"false",
             @"root"         : self.root,
             @"path"         : path
             };
             NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                            urlPath:kKuaiPanUploadFileURLAdd
                                                          urlParams:params
                                                         formParams:@{@"file" : file,}
                                                            baseUrl:url];
             
             AFHTTPRequestOperation *opretion = [[AFHTTPRequestOperation alloc] initWithRequest:request];
             [opretion setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                 Log_info(@"文件上传成功!");
                 if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
                     [this.delegate client:self
                                uploadFile:[responseObject JSONValue]
                                 withError:nil];
                 }
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 Log_error(@"上传失败，网络错误。");
                 if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
                     [this.delegate client:self
                                uploadFile:nil
                                 withError:error];
                 }
             }];
             [this.queue addOperation:opretion];
         }else {
             Log_error(@"上传失败，服务器不允许上传。");
             if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
                 [this.delegate client:self
                            uploadFile:nil
                             withError:[NSError errorWithDomain:@"Disable"
                                                           code:405
                                                       userInfo:nil]];
             }
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         Log_error(@"上传失败，获取上传服务器失败。");
         if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
             [this.delegate client:self
                        uploadFile:nil
                         withError:error];
         }
     }];
    [self.queue addOperation:opretion];
}

- (void)downloadFile:(NSString *)path rev:(NSString *)rev
{
    if (!path) {
        path = @"/";
        Log_warning(@"Path为空，被替换成'/'");
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.root, @"root", path, @"path", nil];
    if (rev) {
        [params setObject:rev forKey:@"rev"];
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kKuaiPanDownloadFileURLAdd
                                                 urlParams:params
                                                formParams:nil
                                                   baseUrl:kKuaiPanFileServerBaseURLString];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained MTKuaiPanClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:downloadFile:withError:)]) {
            [this.delegate client:self
                     downloadFile:responseObject
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:downloadFile:withError:)]) {
            [this.delegate client:self
                     downloadFile:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

#pragma mark - preivate

- (NSMutableDictionary *)oauthParams
{
    if (![_oauthInfo objectForKey:kOAuthToken] || !_consumerKey) {
        Log_error(@"客服端未登录或consumer key未设置。");
        return nil;
    }
    return [@{
            @"oauth_nonce"              : [MTTools UUID],
            @"oauth_timestamp"          : [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]],
            @"oauth_consumer_key"       : _consumerKey,
            @"oauth_signature_method"   : @"HMAC-SHA1",
            @"oauth_version"            : kKuaiPanApiVersion,
            @"oauth_token"              : [_oauthInfo objectForKey:kOAuthToken]
            } mutableCopy];
    
}

- (NSString *)root
{
    if (!_root) {
        _root = @"app_folder";
    }
    return _root;
}

- (AFHTTPClient *)httpClient
{
    if (!_httpClient) {
        Log_info(@"初始化HTTPClient,基础网络地址是:%@", kKuaiPanBaseURLString);
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kKuaiPanBaseURLString]];
    }
    return _httpClient;
}

@end
