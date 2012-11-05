//
//  KPAuthorizeViewController.h
//  KuaiPan
//
//  Created by zrz on 12-10-29.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPAuthorizeViewController : UIViewController

@property (nonatomic, readonly) UIToolbar   *toolBar;
@property (nonatomic, readonly) UIWebView   *webView;
@property (nonatomic, copy) void    (^cancelBlock)(KPAuthorizeViewController *sender);

- (void)showWaiting;
- (void)missWaiting;

@end
