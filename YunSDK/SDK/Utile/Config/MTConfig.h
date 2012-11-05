//
//  MTConfig.h
//  SOP2p
//
//  Created by zrz on 12-6-12.
//  Copyright (c) 2012年 Sctab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTConfig : NSObject {
    dispatch_queue_t    _queue;
    NSMutableDictionary *_dictionary;
}

@property (nonatomic, strong, readonly) NSString    *path;
@property (nonatomic, readonly) BOOL    canWrite;

+ (MTConfig*)defaultConfig;
- (id)initWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path writeAble:(BOOL)write;

- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setObject:(id)anObject forKey:(id)aKey;

- (id)valueForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

@end
