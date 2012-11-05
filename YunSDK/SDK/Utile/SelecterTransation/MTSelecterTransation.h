//
//  PCSelecterTransation.h
//  Photocus
//
//  Created by zrz on 12-8-31.
//  Copyright (c) 2012年 Dingzai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTSelecterTransation : NSObject

@property (nonatomic, strong)   Protocol    *protocol;
@property (nonatomic, assign)   id  targetDelegate,
                                    sourceDelegate;
//默认是NO,如果是YES,在sourceDelegate响应方法的同业还会发送给targetDelegate
@property (nonatomic, assign, getter = isCross)   BOOL    cross;

@end
