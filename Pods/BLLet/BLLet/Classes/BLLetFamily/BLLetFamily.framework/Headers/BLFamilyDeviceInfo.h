//
//  BLFamilyDeviceInfo.h
//  Let
//
//  Created by zjjllj on 2017/2/8.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLFamilyDeviceInfo : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)toDictionary;

@property (nonatomic, copy)NSString *familyId;          //模块所在家庭ID
@property (nonatomic, copy)NSString *roomId;            //模块所在房间ID
@property (nonatomic, copy)NSString *did;               //设备did
@property (nonatomic, copy)NSString *sDid;              //子设备Did
@property (nonatomic, copy)NSString *mac;               //设备mac
@property (nonatomic, copy)NSString *pid;               //设备产品Pid
@property (nonatomic, copy)NSString *name;              //设备名称
@property (nonatomic, assign)NSInteger password;
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, assign)BOOL lock;
@property (nonatomic, copy)NSString *aesKey;
@property (nonatomic, assign)NSInteger terminalId;
@property (nonatomic, assign)NSInteger subdeviceNum;
@property (nonatomic, copy)NSString *longitude;         //设备所在纬度
@property (nonatomic, copy)NSString *latitude;          //设备所在经度
@property (nonatomic, copy)NSString *wifimac;
@property (nonatomic, copy)NSString *extend;

@end
