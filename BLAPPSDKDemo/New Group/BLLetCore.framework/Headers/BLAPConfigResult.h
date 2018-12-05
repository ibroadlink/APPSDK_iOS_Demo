//
//  BLAPConfigResult.h
//  Let
//
//  Created by zhujunjie on 2017/7/25.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLAPConfigResult : BLBaseResult

@property (nonatomic, copy) NSString *did;      //设备唯一did
@property (nonatomic, copy) NSString *pid;      //设备的产品ID
@property (nonatomic, copy) NSString *ssid;     //设备所连接Wi-Fi SSID
@property (nonatomic, copy) NSString *devkey;   //设备控制密钥

@end
