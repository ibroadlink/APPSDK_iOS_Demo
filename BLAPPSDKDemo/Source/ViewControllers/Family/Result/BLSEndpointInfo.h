//
//  BLSEndpointInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetCore/BLLetCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLSEndpointInfo : NSObject

@property (nonatomic, copy)NSString *endpointId;
@property (nonatomic, copy)NSString *friendlyName;
@property (nonatomic, copy)NSString *mac;
@property (nonatomic, copy)NSString *gatewayId;
@property (nonatomic, copy)NSString *productId;
@property (nonatomic, copy)NSString *icon;
@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, assign)NSInteger order;
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *cookie;
@property (nonatomic, copy)NSString *irData;
@property (nonatomic, copy)NSString *vGroup;
@property (nonatomic, copy)NSString *extend;

- (instancetype)initWithBLDevice:(BLDNADevice *)device;

- (BLDNADevice *)toDNADevice;

@end

NS_ASSUME_NONNULL_END
