//
//  BLQueryIRCodeParams.h
//  Let
//
//  Created by junjie.zhu on 2017/1/23.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*按键类型*/
typedef NS_ENUM(NSUInteger, BL_AC_KEY_E) {
    BL_AC_KEY_SWITCH,      /*开关键*/
    BL_AC_KEY_MODE,        /*模式键*/
    BL_AC_KEY_TEMP_ADD,    /*温度加键*/
    BL_AC_KEY_TEMP_SUB,    /*温度减键*/
    BL_AC_KEY_WIND_SPPED   /*风速键*/
};

@interface BLQueryIRCodeParams : NSObject

@property(nonatomic, assign)NSUInteger state;
@property(nonatomic, assign)NSUInteger mode;
@property(nonatomic, assign)NSUInteger speed;
@property(nonatomic, assign)NSUInteger direct;
@property(nonatomic, assign)NSUInteger temperature;
@property(nonatomic, assign)BL_AC_KEY_E key;

/**
 Mostly freq = 38 kHz
 */
@property(nonatomic, assign)NSUInteger freq;

@end
