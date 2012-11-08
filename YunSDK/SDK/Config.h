//
//  KPConfig.h
//  KuaiPan
//
//  Created by zrz on 12-10-30.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTConfig.h"

#pragma mark - logger

//这里可以替换成自己的logger

#define Log_error(...)      NSLog(@"Error : %@ in %s %d", [NSString stringWithFormat:__VA_ARGS__], __FILE__, __LINE__)
#define Log_warning(...)    NSLog(@"Warning : %@ int %s %d", [NSString stringWithFormat:__VA_ARGS__], __FILE__, __LINE__)
#define Log_info(...)       //NSLog(@"Info : %@ int %s %d", [NSString stringWithFormat:__VA_ARGS__], __FILE__, __LINE__)

#pragma mark - define

#define kKuaiPanApiVersion  [[MTConfig defaultConfig] objectForKey:@"KuaiPanApiVersion"]

#define kKuaiPanBaseURLString       [[MTConfig defaultConfig] objectForKey:@"KuaiPanBaseURLString"]
#define kKuaiPanFileServerBaseURLString [[MTConfig defaultConfig] objectForKey:@"KuaiPanFileServerBaseURLString"]

//---快盘API path
#define kKuaiPanRequestTokenURLAdd  [[MTConfig defaultConfig] objectForKey:@"KuaiPanRequestTokenURLAdd"]
#define kKuaiPanAccessTokenURLAdd   [[MTConfig defaultConfig] objectForKey:@"KuaiPanAccessTokenURLAdd"]
#define kKuaiPanUserInfoURLAdd      [[MTConfig defaultConfig] objectForKey:@"KuaiPanUserInfoURLAdd"]
#define kKuaiPanMetadataURLAdd      [[MTConfig defaultConfig] objectForKey:@"KuaiPanMetadataURLAdd"]
#define kKuaiPanCreateFolderURLAdd  [[MTConfig defaultConfig] objectForKey:@"KuaiPanCreateFolderURLAdd"]
#define kKuaiPanShareLinkURLAdd     [[MTConfig defaultConfig] objectForKey:@"KuaiPanShareLinkURLAdd"]
#define kKuaiPanFileHistoryURLAdd   [[MTConfig defaultConfig] objectForKey:@"KuaiPanFileHistoryURLAdd"]
#define kKuaiPanFileDeleteURLAdd    [[MTConfig defaultConfig] objectForKey:@"KuaiPanFileDeleteURLAdd"]
#define kKuaiPanUploadLocateURLAdd  [[MTConfig defaultConfig] objectForKey:@"KuaiPanUploadLocateURLAdd"]
#define kKuaiPanUploadFileURLAdd    [[MTConfig defaultConfig] objectForKey:@"KuaiPanUploadFileURLAdd"]
#define kKuaiPanDownloadFileURLAdd  [[MTConfig defaultConfig] objectForKey:@"KuaiPanDownloadFileURLAdd"]

#define kKuaiPanAuthorizeURLString  [[MTConfig defaultConfig] objectForKey:@"KuaiPanAuthorizeURLString"]

#define kBaiduAuthorizeURLString    [[MTConfig defaultConfig] objectForKey:@"BaiduAuthorizeURLString"]

#define kBaiduAccessTokenURLString  [[MTConfig defaultConfig] objectForKey:@"BaiduAccessTokenURLString"]
#define kBaiduBaseURLString         [[MTConfig defaultConfig] objectForKey:@"BaiduBaseURLString"]

//--百度API path
#define kBaiduQuotaURLAdd           [[MTConfig defaultConfig] objectForKey:@"BaiduQuotaURLAdd"]
#define kBaiduFileURLAdd            [[MTConfig defaultConfig] objectForKey:@"BaiduFileURLAdd"]


