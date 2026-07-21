//
//  BLCloudDevicePairedInfo.h
//  BLLetCore
//
//  Created by admin on 2019/8/28.
//  Copyright © 2019 admin All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDNADevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLCloudDevicePairedInfo : NSObject

- (instancetype)initWithBLDNADevice:(BLDNADevice *)device;

@property (nonatomic, copy)NSString *did;
@property (nonatomic, copy)NSString *pid;
@property (nonatomic, copy)NSString *mac;
@property (nonatomic, assign) NSUInteger devicetypeflag;
@property (nonatomic, copy)NSString *cookie;

@end

NS_ASSUME_NONNULL_END
