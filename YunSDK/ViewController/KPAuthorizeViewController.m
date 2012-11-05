//
//  KPAuthorizeViewController.m
//  KuaiPan
//
//  Created by zrz on 12-10-29.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "KPAuthorizeViewController.h"

@interface KPAuthorizeViewController ()

@end

@implementation KPAuthorizeViewController {
    UIActivityIndicatorView *_activityIndicatorView;
}

@synthesize toolBar = _toolBar, webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20,
                                                           screenSize.width, 44)];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64,
                                                           screenSize.width,
                                                           screenSize.height - 64)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(cancelClick)];
    _toolBar.items = @[item];
    
    
    [self.view addSubview:_webView];
    [self.view addSubview:_toolBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelClick
{
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
    CGFloat __systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    if (__systemVersion >= 6.0) {
        [(id)self dismissViewControllerAnimated:YES
                                 completion:nil];
    }else {
        [(id)self dismissModalViewControllerAnimated:YES];
    }
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        _activityIndicatorView.center = CGPointMake(size.width / 2,
                                                    size.height / 2);
        [self.view addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (void)showWaiting
{
    [[self activityIndicatorView] startAnimating];
}

- (void)missWaiting
{
    [[self activityIndicatorView] stopAnimating];
}

@end
