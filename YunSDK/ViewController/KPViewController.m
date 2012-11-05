//
//  KPViewController.m
//  KuaiPan
//
//  Created by zrz on 12-10-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "KPViewController.h"
#import "MTKuaiPanClient.h"
#import "KPAuthorizeViewController.h"
#import "MTTools.h"

#warning 请替换成自己的key和secret以及callback
#define kConsumerKey    @"xcBJlaupNmsLNmHV"
#define kConsumerSecret @"eryHdR4EeDs6ePVb"
#define kCallbackAddress    @"http://zhaorenzhi.cn/"

@interface KPViewController ()
<UIWebViewDelegate, MTKuaiPanClientDelegate>

@end

@implementation KPViewController {
    MTKuaiPanClient    *_client;
    KPAuthorizeViewController   *_authorizeController;
    UIButton    *_loginButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSDictionary *info = [self oauthInfo];
        
        _client = [[MTKuaiPanClient alloc] initWithConsumerKey:kConsumerKey
                                                consumerSecret:kConsumerSecret];
        _client.callback = kCallbackAddress;
        _client.oauthInfo = info;
        
        _client.delegate = self;
        self.title = @"快盘";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// 初始化界面
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loginButton.frame = CGRectMake(100, 33, 120, 33);
    [_loginButton setTitle:@"Login"
            forState:UIControlStateNormal];
    [_loginButton addTarget:self
               action:@selector(loginClick)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    [self checkLoginState];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 76, 120, 33);
    [button setTitle:@"UserInfo"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(getUserInfo)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 119, 120, 33);
    [button setTitle:@"Metadata"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(getMetadata)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 162, 120, 33);
    [button setTitle:@"CreateFolder"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(createFolderClick)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 205, 120, 33);
    [button setTitle:@"Upload"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(uploadClick)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 248, 120, 33);
    [button setTitle:@"Download"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(downloadClick)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkLoginState
{
    if ([self oauthInfo]) {
        [_loginButton setTitle:@"Logout"
                      forState:UIControlStateNormal];
    }else {
        [_loginButton setTitle:@"Login"
                      forState:UIControlStateNormal];
    }
}

#pragma mark - access token cache

- (NSDictionary *)oauthInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults objectForKey:@"accessToken"];
    if (dic) {
        NSLog(@"Saved accessToken : %@", dic);
        return dic;
    }
    return nil;
}

#pragma mark - kp delegate

- (void)oauthDidStartLoading:(MTOAuth *)oauth
{
    [_authorizeController showWaiting];
}

- (void)oauthDidStopLoading:(MTOAuth *)oauth
{
    [_authorizeController missWaiting];
}

- (void)oauth:(MTOAuth *)oauth seccussWithOAuthInfo:(NSDictionary *)info
{
    showAlert(@"登陆成功");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:info
                     forKey:@"accessToken"];
    [userDefaults synchronize];
    [self checkLoginState];
    [self missAuthorizeController];
}

- (void)oauth:(MTOAuth *)oauth faildWithError:(NSError *)error
{
    showAlert(@"登陆失败");
    [self missAuthorizeController];
}

- (void)client:(MTKuaiPanClient *)client getAccountInfo:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"获取信息失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"获取信息成功");
        NSLog(@"%@", dictionary);
    }
}

- (void)client:(MTKuaiPanClient *)client getMetadata:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"获取信息失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"获取信息成功");
        NSLog(@"%@", dictionary);
    }
}

- (void)client:(MTKuaiPanClient *)client createFolder:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"获取信息失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"获取信息成功");
        NSLog(@"%@", dictionary);
    }
}

- (void)client:(MTKuaiPanClient *)client uploadFile:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"获取信息失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"获取信息成功");
        NSLog(@"%@", dictionary);
    }
}

- (void)client:(MTKuaiPanClient *)client downloadFile:(NSData *)file withError:(NSError *)error
{
    if (error) {
        showAlert(@"下载失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"下载成功");
        NSLog(@"%d", file.length);
    }
}

#pragma mark - action 

- (void)missAuthorizeController
{
    if (_authorizeController) {
        CGFloat __systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (__systemVersion >= 6.0) {
            [(id)self dismissViewControllerAnimated:YES
                                         completion:nil];
        }else {
            [(id)self dismissModalViewControllerAnimated:YES];
        }
        _authorizeController = nil;
    }
}

- (void)loginClick
{
    if ([self oauthInfo]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"accessToken"];
        [userDefaults synchronize];
        [self checkLoginState];
    }else {
        _authorizeController = [[KPAuthorizeViewController alloc] init];
        
        [_authorizeController view];
        [_client performSelector:@selector(startOAuthWithWebView:)
                      withObject:_authorizeController.webView
                      afterDelay:0.3];
        CGFloat __systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (__systemVersion >= 6.0) {
            [(id)self presentViewController:_authorizeController
                               animated:YES
                             completion:nil];
        }else {
            [(id)self presentModalViewController:_authorizeController
                                    animated:YES];
        }
    }
}

- (void)getUserInfo
{
    [_client checkAccountInfo];
}

- (void)getMetadata
{
    NSString *path = @"/我的应用/云酷/";
    [_client metadataWithPath:path
                         list:nil
                    fileLimit:nil
                         page:nil
                     pageSize:nil
                    filterExt:nil
                       sortBy:nil];
}

- (void)createFolderClick
{
    [_client createFolderWithPath:@"/我的应用/云酷"];
}

- (void)uploadClick
{
    [_client uploadFile:@"/我的应用/云酷/test.jpg"
                   file:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"qb" ofType:@"jpg"]]
              overWritr:YES
               sourceIp:nil];
}

- (void)downloadClick
{
    [_client downloadFile:@"/我的应用/云酷/test.jpg"
                      rev:nil];
}

@end
