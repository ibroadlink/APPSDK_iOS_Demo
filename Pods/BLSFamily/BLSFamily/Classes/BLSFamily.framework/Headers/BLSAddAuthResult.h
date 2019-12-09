//
//  BLSAddAuthResult.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/3/12.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLSAddAuthResult : BLBaseResult

@property (nonatomic, copy)NSString *ticket;
@property (nonatomic, copy)NSString *authid;

@end

NS_ASSUME_NONNULL_END
