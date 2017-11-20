//
//  UIBarButtonItem+EasyBlock.m
//  EasyBlockDemo
//
//  Created by 徐仲平 on 2017/6/16.
//  Copyright © 2017年 徐仲平. All rights reserved.
//

#import "UIBarButtonItem+EasyBlock.h"
#import "EasyGCD.h"
#import <objc/message.h>
#import "EasyEventHandler.h"


@interface UIBarButtonItem()
@property dispatch_semaphore_t  lock;
@property NSMutableArray        *handleCallBackPool;
@end

@implementation UIBarButtonItem (EasyBlock)
static const char * property_handlePoolKey = "property_handlePoolKey";
static const char * property_lockKey       = "property_lockKey";


- (void)addTouchEventHandleBlock:(EasyVoidIdBlock)block{
    [self addTouchEventHandleBlock:block ignoreDuration:0.0];
}
- (void)addTouchEventHandleBlock:(EasyVoidIdBlock)block ignoreDuration:(CGFloat)duration{
    
    EasyEventHandler *handle = [EasyEventHandler handler];
    easyLock([self lock]);
    NSMutableArray *handlePool = [self handleCallBackPool];
    easyUnLock([self lock]);
    
    [handlePool addObject:handle];
    [handle setHandBlock:block];
    [handle setSource:self];
    [handle setIgnoreDuration:duration];
    [self setTarget:handle];
    [self setAction:NSSelectorFromString(EasyBarButtonAction)];
}

#pragma mark - set && get

- (void)setHandlePoolProperty{
    objc_setAssociatedObject(self, property_handlePoolKey,@[].mutableCopy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)getHandlePoolProperty{
    id value = objc_getAssociatedObject(self, property_handlePoolKey);
    return value;
}

- (void)setSemaphoreLock:(dispatch_semaphore_t)lock{
    objc_setAssociatedObject(self, property_lockKey,lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (dispatch_semaphore_t)getSemaphoreLock{
    return objc_getAssociatedObject(self, property_lockKey);
}

- (dispatch_semaphore_t)lock{
    if (![self getSemaphoreLock]) {
        [self setSemaphoreLock:easyGetLock()];
    }
    return [self getSemaphoreLock];
}
- (NSMutableArray *)handleCallBackPool{
    if (![self getHandlePoolProperty]) {
        [self setHandlePoolProperty];
    }
    return [self getHandlePoolProperty];
}
@end
