//
//  NSTimer+BLLet.h
//  Let
//
//  Created by zjjllj on 2017/4/5.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (BLLet)

+ (NSTimer *)bl_socheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)(void))block repeats:(BOOL)repeats;

@end
