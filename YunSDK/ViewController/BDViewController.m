//
//  BDViewController.m
//  YunSDK
//
//  Created by zrz on 12-11-4.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "BDViewController.h"
#import "KPAuthorizeViewController.h"
#import "MTBaiduClient.h"
#import "MTTools.h"

#warning 请替换成自己的key和secret以及callback
#define kConsumerKey    @"0WFIfkgnmrMSBjwC7nL4OYGZ"
#define kConsumerSecret @"xn6jS7Wyowf5BzMvr9ktm2dlPskXTxRG"
#define kCallbackAddress    @"http://zhaorenzhi.cn/"

@interface BDViewController ()
<MTBaiduClientDelegate>

@end

@implementation BDViewController {
    KPAuthorizeViewController   *_authorizeController;
    UIButton    *_loginButton;
    MTBaiduClient   *_client;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _client = [[MTBaiduClient alloc] initWithConsumerKey:kConsumerKey
                                              consumerSecret:kConsumerSecret];
        _client.callback = kCallbackAddress;
        _client.oauthInfo = [self oauthInfo];
        _client.delegate = self;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// 
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loginButton.frame = CGRectMake(100, 33, 120, 33);
    [_loginButton setTitle:@"Login"
                  forState:UIControlStateNormal];
    [_loginButton addTarget:self
                     action:@selector(loginClick)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    //[self checkLoginState];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 76, 120, 33);
    [button setTitle:@"DiskInfo"
                  forState:UIControlStateNormal];
    [button addTarget:self
                     action:@selector(infoClick)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 119, 120, 33);
    [button setTitle:@"Upload"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(uploadClick)
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (NSDictionary *)oauthInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults objectForKey:@"baiduAccessToken"];
    if (dic) {
        NSLog(@"Saved accessToken : %@", dic);
        return dic;
    }
    return nil;
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
        [userDefaults removeObjectForKey:@"baiduAccessToken"];
        [userDefaults synchronize];
        [_client cleanCookies];
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

- (void)infoClick
{
    [_client checkDiskQuota];
}

- (void)uploadClick
{
    [_client uploadFile:@"/apps/云酷/qb.jpg"
                   file:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]
                                                        pathForResource:@"qb"
                                                        ofType:@"jpg"]]];
}

- (void)createFolderClick
{
    [_client createFolderWithPath:@"/apps/云酷/testFolder"];
}

#pragma mark - delegate

- (void)oauthDidStartLoading:(MTOAuth *)oauth
{
    [_authorizeController showWaiting];
}

- (void)oauthDidStopLoading:(MTOAuth *)oauth
{
    [_authorizeController missWaiting];
}

- (void)oauth:(MTOAuth *)oauth faildWithError:(NSError *)error
{
    [self missAuthorizeController];
}

- (void)oauth:(MTOAuth *)oauth seccussWithOAuthInfo:(NSDictionary *)info
{
    [self missAuthorizeController];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:info
                     forKey:@"baiduAccessToken"];
    [userDefaults synchronize];
}

- (void)client:(MTBaiduClient *)client uploadFile:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"上传失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"上传成功");
        NSLog(@"%@", dictionary);
    }
}

- (void)client:(MTBaiduClient *)client createFolder:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"创建失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"创建成功");
        NSLog(@"%@", dictionary);
    }
}

@end
