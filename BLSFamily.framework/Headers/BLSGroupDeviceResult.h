//
//  BLSGroupDeviceResult.h
//  BLSFamily
//
//  Created by hongkun.bai on 2019/8/28.
//  Copyright © 2019 hongkun.bai. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLSGroupDevice.h"
NS_ASSUME_NONNULL_BEGIN

@interface BLSGroupDeviceResult : BLBaseResult
@property (nonatomic, copy)   NSString *endpointId;
@property (nonatomic, copy)   NSArray<BLSGroupDevice *> *groupdevice;
@end

NS_ASSUME_NONNULL_END
