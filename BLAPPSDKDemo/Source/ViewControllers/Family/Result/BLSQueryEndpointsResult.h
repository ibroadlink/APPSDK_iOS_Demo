//
//  BLSQueryEndpointsResult.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLSEndpointInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLSQueryEndpointsResult : BLBaseResult

@property (nonatomic, copy)NSArray *endpoints;

@end

NS_ASSUME_NONNULL_END
