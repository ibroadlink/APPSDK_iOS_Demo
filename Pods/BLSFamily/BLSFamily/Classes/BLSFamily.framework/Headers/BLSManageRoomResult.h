//
//  BLSManageRoomResult.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLSRoomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLSManageRoomResult : BLBaseResult

@property (nonatomic, strong)NSArray *roomInfos;

@end

NS_ASSUME_NONNULL_END
