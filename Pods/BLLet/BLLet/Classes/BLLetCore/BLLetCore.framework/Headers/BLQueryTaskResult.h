//
//  QueryTaskResult.h
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

/**
 *  定时任务信息
 */
@interface BLTimerOrDelayInfo : NSObject
/**
 *  位标
 */
@property (nonatomic, assign, getter=getIndex) NSUInteger index;

/**
 *  使能标志
 */
@property (nonatomic, assign, getter=isEnable) Boolean enable;

/**
 *  年
 */
@property (nonatomic, assign, getter=getYear) NSUInteger year;

/**
 *  月
 */
@property (nonatomic, assign, getter=getMonth) NSUInteger month;

/**
 *  日
 */
@property (nonatomic, assign, getter=getDay) NSUInteger day;

/**
 *  时
 */
@property (nonatomic, assign, getter=getHour) NSUInteger hour;

/**
 *  分
 */
@property (nonatomic, assign, getter=getMinute) NSUInteger minute;

/**
 *  秒
 */
@property (nonatomic, assign, getter=getSeconds) NSUInteger seconds;

@end


/**
 *  周期任务信息
 */
@interface BLPeriodInfo : NSObject

/**
 *  位标
 */
@property (nonatomic, assign, getter=getIndex) NSUInteger index;

/**
 *  使能标志
 */
@property (nonatomic, assign, getter=isEnable) Boolean enable;

/**
 *  时
 */
@property (nonatomic, assign, getter=getHour) NSUInteger hour;

/**
 *  分
 */
@property (nonatomic, assign, getter=getMinute) NSUInteger minute;

/**
 *  秒
 */
@property (nonatomic, assign, getter=getSeconds) NSUInteger seconds;

/**
 *  Week repeat list. 1:Monday 2:Tuesday 3:Wednesday 4:Thursday 5:Friday 6:Saturday 7:Sunday
 */
@property (nonatomic, strong, getter=getRepeat) NSArray<NSNumber *> *repeat;

@end

/**
 *  循环任务信息
 */
@interface BLCycleOrRandomInfo : NSObject

/**
 *  位标
 */
@property (nonatomic, assign, getter=getIndex) NSUInteger index;

/**
 *  使能标志
 */
@property (nonatomic, assign, getter=isEnable) Boolean enable;

/**
 *  时
 */
@property (nonatomic, assign, getter=getHour) NSUInteger hour;

/**
 *  分
 */
@property (nonatomic, assign, getter=getMinute) NSUInteger minute;

/**
 *  秒
 */
@property (nonatomic, assign, getter=getSeconds) NSUInteger seconds;

/**
 *  结束时
 */
@property (nonatomic, assign, getter=getEndHour) NSUInteger endhour;

/**
 *  结束分
 */
@property (nonatomic, assign, getter=getEndMinute) NSUInteger endminute;

/**
 *  结束秒
 */
@property (nonatomic, assign, getter=getEndSeconds) NSUInteger endseconds;

/**
 *  Week repeat list. 1:Monday 2:Tuesday 3:Wednesday 4:Thursday 5:Friday 6:Saturday 7:Sunday
 */
@property (nonatomic, strong, getter=getRepeat) NSArray<NSNumber *> *repeat;
/**
 *  命令1持续时间 单位秒
 */
@property (nonatomic, assign, getter=getCmd1duration) NSUInteger cmd1duration;
/**
 *  命令2持续时间 单位秒
 */
@property (nonatomic, assign, getter=getCmd1duration) NSUInteger cmd2duration;
@end

/**
 Query Task Result
 */
@interface BLQueryTaskResult : BLBaseResult

/**
 Timer task list
 */
@property (nonatomic, strong, getter=getTimer) NSArray<BLTimerOrDelayInfo *> *timer;

/**
 delay task list
 */
@property (nonatomic, strong, getter=getDelay) NSArray<BLTimerOrDelayInfo *> *delay;
/**
 Period task list
 */
@property (nonatomic, strong, getter=getPeriod) NSArray<BLPeriodInfo *> *period;
/**
 Period task list
 */
@property (nonatomic, strong, getter=getCycle) NSArray<BLCycleOrRandomInfo *> *cycle;
/**
 Period task list
 */
@property (nonatomic, strong, getter=getRandom) NSArray<BLCycleOrRandomInfo *> *random;

@end
