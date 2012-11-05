//
//  MTViewController.m
//  YunSDK
//
//  Created by zrz on 12-10-31.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTViewController.h"
#import "KPViewController.h"
#import "BDViewController.h"

@interface MTViewController ()

@end

@implementation MTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)kuaiPanClick:(id)sender
{
    KPViewController *ctrl = [[KPViewController alloc] init];
    [self.navigationController pushViewController:ctrl
                                         animated:YES];
}

- (IBAction)baiduClick:(id)sender
{
    BDViewController *ctrl = [[BDViewController alloc] init];
    [self.navigationController pushViewController:ctrl
                                         animated:YES];
}

@end
