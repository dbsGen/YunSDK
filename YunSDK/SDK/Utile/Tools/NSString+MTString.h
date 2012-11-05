//
//  NSString+MTString.h
//  YunSDK
//
//  Created by zrz on 12-11-3.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MTString)

//原型方法会把"//"替换成"/"所以在,这里重写一个
- (NSString *)stringByDeletingLastPathComponentEx;

@end
