//
//  BLDeviceService.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/11/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetCore/BLLetCore.h>

@interface BLDeviceService : NSObject

+ (instancetype)sharedDeviceService;

@property (nonatomic, strong) BLDNADevice *selectDevice;
@property (nonatomic, strong) BLController *blController;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *h5Data;   //存储H5调用接口的时候传递的data数据（当前地产项目使用到改数据）

@end
