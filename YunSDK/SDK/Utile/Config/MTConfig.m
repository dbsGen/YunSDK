//
//  MTConfig.m
//  SOP2p
//
//  Created by zrz on 12-6-12.
//  Copyright (c) 2012年 Sctab. All rights reserved.
//

#import "MTConfig.h"

@implementation MTConfig

@synthesize canWrite = _canWrite, path = _path;

static __strong MTConfig *__defaultConfig;

+ (MTConfig*)defaultConfig
{
    @synchronized(self) {
        if (!__defaultConfig) {
            __defaultConfig = [[MTConfig alloc] initWithPath:
                               [[NSBundle mainBundle] pathForResource:@"config"
                                                               ofType:@"plist"]];
        }
        return __defaultConfig;
    }
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (void)dealloc
{
    if (_queue) dispatch_release(_queue);
}
#endif

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = path;
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"%@%@",
                                        NSStringFromClass([self class]),
                                         path] UTF8String], NULL);
        _dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:_path];
        if (!_dictionary) {
            _dictionary = [[NSMutableDictionary alloc] init];
            dispatch_async(_queue, ^{
                [_dictionary writeToFile:_path
                              atomically:YES];
            });
        }
    }
    return self;
}

- (id)initWithPath:(NSString *)path 
         writeAble:(BOOL)write
{
    self = [self initWithPath:path];
    if (self) {
        _canWrite = write;
    }
    return self;
}

- (id)objectForKey:(NSString *)key
{
    return [_dictionary objectForKey:key];
}

- (id)valueForKey:(NSString *)key
{
    return [_dictionary valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if (_canWrite) {
        [super setValue:value 
                 forKey:key];
        dispatch_async(_queue, ^{
            [_dictionary writeToFile:_path
                   atomically:YES];
        });
    }else {
        NSLog(@"config can't write");
    }
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    if (_canWrite) {
        [super setValue:anObject 
                 forKey:aKey];
        dispatch_async(_queue, ^{
            [_dictionary writeToFile:_path
                   atomically:YES];
        });
    }else {
        NSLog(@"config can't write");
    }
}

@end
