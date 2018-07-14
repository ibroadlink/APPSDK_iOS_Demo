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

@end
