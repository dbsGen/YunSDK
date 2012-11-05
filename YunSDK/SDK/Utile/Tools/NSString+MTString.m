//
//  NSString+MTString.m
//  YunSDK
//
//  Created by zrz on 12-11-3.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "NSString+MTString.h"

@implementation NSString (MTString)

- (NSString *)stringByDeletingLastPathComponentEx
{
    NSRange range = [self rangeOfString:@"/"
                                options:NSBackwardsSearch];
    return [self substringToIndex:range.location];
}

@end
