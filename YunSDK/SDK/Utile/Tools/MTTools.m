//
//  MTTools.m
//  YunSDK
//
//  Created by zrz on 12-10-31.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTTools.h"
#import "Config.h"

void showAlert(NSString *content) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:content
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

@implementation MTTools

+ (NSString *)UUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    
    CFRelease(uuidObject);
    return uuidStr;
}



@end
