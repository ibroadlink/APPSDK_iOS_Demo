//
//  EAirNetWorkDataParser.h
//  Let
//
//  Created by junjie.zhu on 16/8/3.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>

@interface BLTaskTimerInfo : NSObject

/*Timer task's year*/
@property (nonatomic, assign) uint16_t year;
/*Timer task's month*/
@property (nonatomic, assign) uint8_t month;
/*Timer task's day*/
@property (nonatomic, assign) uint8_t day;
/*Timer task's hour*/
@property (nonatomic, assign) uint8_t hour;
/*Timer task's minute*/
@property (nonatomic, assign) uint8_t minute;
/*Timer task's second*/
@property (nonatomic, assign) uint8_t second;
/*Timer task's weekday, do not care*/
@property (nonatomic, assign) uint8_t weekday;

@end

/*eAir*/
@interface BLeAirStatusValueInfo : NSObject

@property (nonatomic, assign) NSInteger integer;
@property (nonatomic, assign) NSInteger decimal;

@end

@interface BLeAirStatusInfo : NSObject

@property (nonatomic, strong) BLeAirStatusValueInfo *temperature;   //温度
@property (nonatomic, strong) BLeAirStatusValueInfo *humidity;      //湿度
@property (nonatomic, strong) BLeAirStatusValueInfo *light;         //光照
@property (nonatomic, strong) BLeAirStatusValueInfo *air;           //空气质量
@property (nonatomic, strong) BLeAirStatusValueInfo *noisy;         //噪音

@end

@interface BLeAirTriggerInfo : NSObject

// 0: temperature 1: humidity 2: light 3: air quality 4: noisy
@property (nonatomic, assign) NSInteger type;
// 0: condition up 1: condition down
@property (nonatomic, assign) NSInteger trigger;

@property (nonatomic, strong) BLeAirStatusValueInfo *value;

@end

@interface BLeAirConditStatusInfo : NSObject

// 0表示该传感器对IFTTT没有作用，1则表示对IFTTT的执行有作用，并且高7位可以用来说明传感器值的范围，比如温度28上下浮动5%，那高7位就设为5.
@property (nonatomic, assign) NSInteger valid;
// 0: temperature 1: humidity 2: light 3: air quality 4: noisy
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) BLeAirStatusValueInfo *value;

@end

@interface BLeAirConditionInfo : NSObject

@property (nonatomic, strong) BLeAirTriggerInfo *trigger;
@property (nonatomic, strong) NSArray *statusArray;   // <type> BLeAirConditStatusInfo.

@end

@interface BLeAirIFTTT : NSObject

@property (nonatomic, assign) BOOL timeEnable;
@property (nonatomic, assign) BOOL iftttEnable;
@property (nonatomic, assign) uint32_t index;
@property (nonatomic, strong) BLTaskTimerInfo *timeA;
@property (nonatomic, strong) BLTaskTimerInfo *timeB;
@property (nonatomic, strong) BLeAirConditionInfo *condition;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) uint32_t version;

@end

@interface BL2DeviceAuthInfo : NSObject

@property (nonatomic, assign) int32_t terminal_id;
@property (nonatomic, strong) NSData *key;

@end

@interface BLeAirIOTInfo : NSObject

@property (nonatomic, strong) BL2DeviceAuthInfo *authInfo;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSData *data;

@end

@interface BLeAirIFTTTSetInfo : NSObject

@property (nonatomic, strong) BLeAirIFTTT *info;
@property (nonatomic, strong) BLeAirIOTInfo *iot;

@end

@interface BLeAirIFTTTInfo : NSObject

@property (nonatomic, strong) BLeAirIFTTT *ifttt;
@property (nonatomic, strong) NSString *mac;

@end

@interface BLeAirIFTTTList : NSObject

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray *list;   // <type> BLeAirIFTTTInfo.

@end

@interface BLeAirNetWorkDataParser : NSObject

+ (instancetype)sharedInstace;

/**
 *  Get a1 refresh code
 *
 *  @return code
 */
- (NSData *)a1RefreshByts;

/**
 *  Add ifttt to list code
 *
 *  @param ifttt
 *
 *  @return code
 */
- (NSData *)addIFTTT:(BLeAirIFTTTSetInfo *)ifttt;

/**
 *  Delete ifttt from list code
 *
 *  @param index - index in ifttt list
 *
 *  @return code
 */
- (NSData *)deleteIFTTT:(NSInteger)index;

/**
 *  Get ifttt list code
 *
 *  @return code
 */
- (NSData *)getIFTTT;

/**
 *  Parse a1RefreshByts return
 *
 *  @param data
 *
 *  @return a1 status info
 */
- (BLeAirStatusInfo *)parseA1RefreshResult:(NSData *)data;

/**
 *  Parse add/del/get ifttt result
 *
 *  @param data
 *
 *  @return ifttt list
 */
- (BLeAirIFTTTList *)parseIFTTTList:(NSData *)data;

@end
