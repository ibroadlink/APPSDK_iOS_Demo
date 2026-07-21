//
//  BLCloudEndpointInfo.h
//  BLLetCore
//
//  Created by admin on 2019/8/27.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDNADevice.h"
#import "BLCloudDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLCloudEndpointInfo : NSObject

- (instancetype)initWithDeviceId:(NSString *)deviceId allDevice:(NSDictionary *)allDevices;

@property (nonatomic, copy)NSString *endpointId;
@property (nonatomic, copy)NSString *devSession;
@property (nonatomic, copy)NSString *gatewayId;
@property (nonatomic, assign)NSUInteger devicetypeFlag;
@property (nonatomic, strong)BLCloudDeviceInfo *devinfo;
@property (nonatomic, strong)BLCloudEndpointInfo *gatewayInfo;
@property (nonatomic, strong)NSArray<BLCloudEndpointInfo *> *groupdevice;

@end

NS_ASSUME_NONNULL_END
