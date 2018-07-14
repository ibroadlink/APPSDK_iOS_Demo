//
//  BLModuleInfo.h
//  Let
//
//  Created by zjjllj on 2017/2/8.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLModuleIncludeDev.h"

typedef enum : NSUInteger {
    BLSDKModuleType_Scene = 0,                     //总开关
    BLSDKModuleType_SP,                            //SP系列
    BLSDKModuleType_PowerConsumption,              //能耗统计
    BLSDKModuleType_Common,                        //通用模块（除了其他几种外的模块类型，主要用于识别从dnakit系统绑定的设备）
    BLSDKModuleType_ControlCenter,                 //控制中心模块(只要发现家庭有两个（包含）以上的模块具有pwr接口的就自动创建一个这样的模块)
    BLSDKModuleType_Customize_Scene,               //自定义场景
    BLSDKModuleType_HK_SP,                         //homekitSP系列
    BLSDKModuleType_RM = 9,                        //RM设备本身对应的模块类型(云端不存在该模块，本地moduleTable中也没有该模块的数据，只存在设备家庭房间的关系，空模块，方便处理)
    BLSDKModuleType_RM_AC = 10,                    //RM AC 模块
    BLSDKModuleType_RM_TV,                         //RM tv 模块
    BLSDKModuleType_RM_TOPBOX,                     //RM 机顶盒 模块
    BLSDKModuleType_RM_NETWORK_BOX,                //RM 网络盒子 模块
    BLSDKModuleType_RM_TOPBOX_CHANNEL,             //RM topbox 频道模块
    BLSDKModuleType_RM_TC_1,                       //TC 1路
    BLSDKModuleType_RM_TC_2,                       //TC 2路
    BLSDKModuleType_RM_TC_3,                       //TC 3路
    BLSDKModuleType_RM_CURTAIN,                    //RM 窗帘
    BLSDKModuleType_RM_LAMP,                       //RM 灯
    BLSDKModuleType_RM_COMMON,                     //RM 通用面板
    BLSDKModuleType_RM_LAMP_RADIO,                 //RM 射频灯
    BLSDKModuleType_RM_CURTAIN_RADIO,              //RM 射频窗帘
    BLSDKModuleType_RM_CUSTOM_AC,
    BLSDKModuleType_RM_NEW_TV_CHANNEL = 24,         //RM 新电视模块 包含频道信息
    BLSDKModuleType_RM_NEW_TOPBOX_CHANNEL,          // RM 新机顶盒模块 包含频道信息
    
    BLSDKModuleType_SENSOR_GAS = 100,              //燃气
    BLSDKModuleType_SENSOR_SMOKE_DETECTOR = 101,   //烟感
    BLSDKModuleType_SENSOR_SECURITY = 102,         //安防
    BLSDKModuleType_SENSOR_IR = 103,               //红外
    BLSDKModuleType_SENSOR_DOOR = 104              //门磁
} BLSDKModuleTypeEnum;

@interface BLModuleInfo : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)toDictionary;

+ (BOOL)isDeviceModuleType:(BLSDKModuleTypeEnum)type;

+ (BOOL)isRMDeviceModuleType:(BLSDKModuleTypeEnum)type;

@property (nonatomic, copy)NSString *familyId;          //模块所在家庭ID
@property (nonatomic, copy)NSString *roomId;            //模块所在房间ID
@property (nonatomic, copy)NSString *moduleId;          //模块自身ID
@property (nonatomic, copy)NSString *name;              //模块名称
@property (nonatomic, copy)NSString *iconPath;          //模块icon路径
@property (nonatomic, copy)NSArray<BLModuleIncludeDev *> *moduleDevs; //模块下挂设备列表
@property (nonatomic, assign)NSInteger followDev;       //模块移动时，设备是否跟随  0-NO 1-YES
@property (nonatomic, assign)NSInteger order;           //模块序号
@property (nonatomic, assign)NSInteger flag;            //模块Flag
@property (nonatomic, assign)BLSDKModuleTypeEnum moduleType;     //模块类型
@property (nonatomic, copy)NSString *scenceType;        //场景类型
@property (nonatomic, copy)NSString *extend;            //模块扩展信息

@end
