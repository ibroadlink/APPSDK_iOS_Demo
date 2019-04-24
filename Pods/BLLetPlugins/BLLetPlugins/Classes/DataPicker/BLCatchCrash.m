//
//  BLCatchCrash.m
//  Let
//
//  Created by zhujunjie on 2017/7/11.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLCatchCrash.h"
#import "BLPicker.h"

@implementation BLCatchCrash

void uncaughtExceptionHandler(NSException *exception) {
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    
    // 出现异常的原因
    NSString *reason = [exception reason];
    
    // 异常名称
    NSString *name = [exception name];
    
    NSDictionary *exceDic = @{
                                @"exceptionName":name,
                                @"exceptionReason":reason,
                                @"exceptionStack":[stackArray componentsJoinedByString:@"\n"]
                                };
    BLPicker *picker = [BLPicker sharedPicker];
    [picker trackEvent:(NSString *)kPickCrashEventId label:(NSString *)kPickCrashEventLabel parameters:exceDic];
}


@end
