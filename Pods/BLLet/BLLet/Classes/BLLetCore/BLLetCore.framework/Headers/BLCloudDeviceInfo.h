//
//  BLCloudDeviceInfo.h
//  BLLetCore
//
//  Created by admin on 2019/8/27.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDNADevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLCloudDeviceInfo : NSObject

- (instancetype)initWithBLDNADevice:(BLDNADevice *)device;

@property (nonatomic, copy)NSString *productId;
@property (nonatomic, copy)NSString *cookie;
@property (nonatomic, copy)NSString *ircode;

@end

NS_ASSUME_NONNULL_END
