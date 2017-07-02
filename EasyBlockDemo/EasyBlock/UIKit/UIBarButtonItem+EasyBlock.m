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
#import "EasyEventHandle.h"


@interface UIBarButtonItem()
@property dispatch_semaphore_t  lock;
@property NSMutableArray        *handleCallBackPool;
@end

@implementation UIBarButtonItem (EasyBlock)
static const char * property_handlePoolKey_ = "property_handlePoolKey";
static const char * property_lockKey_       = "property_lockKey";


- (void)addTouchEventHandleBlock:(EasyVoidIdBlock)block{
    
    EasyEventHandle *handle = [EasyEventHandle handle];
    
    easyLock([self lock]);
    NSMutableArray *handlePool = [self handleCallBackPool];
    easyUnLock([self lock]);
    
    [handlePool addObject:handle];
    [handle setHandBlock:block];
    [handle setSource:self];
    [self setTarget:handle];
    [self setAction:NSSelectorFromString(EasyBarButtonAction)];
}


#pragma mark - set && get

- (void)setHandlePoolProperty{
    objc_setAssociatedObject(self, property_handlePoolKey_,@[].mutableCopy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)getHandlePoolProperty{
    id value = objc_getAssociatedObject(self, property_handlePoolKey_);
    return value;
}

- (void)setSemaphoreLock:(dispatch_semaphore_t)lock{
    objc_setAssociatedObject(self, property_lockKey_,lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (dispatch_semaphore_t)getSemaphoreLock{
    return objc_getAssociatedObject(self, property_lockKey_);
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
