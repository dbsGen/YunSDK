//
//  PCSelecterTransation.m
//  Photocus
//
//  Created by zrz on 12-8-31.
//  Copyright (c) 2012年 Dingzai. All rights reserved.
//

#import "MTSelecterTransation.h"
#import <objc/runtime.h>


static NSMethodSignature* getMethodSignatureRecursively(Protocol *p, SEL aSel)
{
	NSMethodSignature* methodSignature = nil;
    NSLog(@"%@", NSStringFromProtocol(p));
	struct objc_method_description md = protocol_getMethodDescription(p, aSel, YES, YES);
    if (md.name == NULL) {
        md = protocol_getMethodDescription(p, aSel, NO, YES);
        methodSignature = [NSMethodSignature signatureWithObjCTypes:md.types];
    } else {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:md.types];
    }
    return methodSignature;
}

@implementation MTSelecterTransation
{
    NSMutableDictionary *_cachedMethod;
}

- (id)init
{
    self = [super init];
    if (self) {
        _cachedMethod = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    struct objc_method_description md = protocol_getMethodDescription(self.protocol, aSelector, NO, YES);
    if (md.name != NULL) {
        //有但是不是必须的
        if ([self.sourceDelegate respondsToSelector:aSelector]) {
            return YES;
        }
        if ([self.targetDelegate respondsToSelector:aSelector]) {
            return YES;
        }
        return NO;
    }
    md = protocol_getMethodDescription(self.protocol, aSelector, YES, YES);
    if (md.name != NULL) {
        //是必须的
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    //not need
    //NSAssert((self.sourceDelegate != nil && self.targetDelegate != nil), @"Please set the delegates");
    NSMethodSignature *m = [self.sourceDelegate methodSignatureForSelector:aSelector];
    if (!m) {
        NSString *keyOfSelecter = NSStringFromSelector(aSelector);
        m = [_cachedMethod objectForKey:keyOfSelecter];
        if (!m) {
            m = getMethodSignatureRecursively(self.protocol, aSelector);
            if (m) {
                [_cachedMethod setObject:m forKey:keyOfSelecter];
            }
        }
    }
    return m;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    BOOL responsed = NO;
    if ([self.sourceDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.sourceDelegate];
        responsed = YES;
    }
    
    if (!responsed || self.isCross) {
        if ([self.targetDelegate respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:self.targetDelegate];
        }
    }
}

@end
