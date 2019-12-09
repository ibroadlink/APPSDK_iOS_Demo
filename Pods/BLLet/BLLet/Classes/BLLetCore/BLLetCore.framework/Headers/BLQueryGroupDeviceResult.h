//
//  BLQueryGroupDeviceResult.h
//  AFNetworking
//
//  Created by hongkun.bai on 2019/8/20.
//

#import <BLLetBase/BLLetBase.h>
#import "BLGroupConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLQueryGroupDeviceResult : BLBaseResult

@property (nonatomic, copy)NSString *did;

@property (nonatomic, copy)NSString *pid;

@property (nonatomic, copy)NSString *name;

@property (nonatomic, copy)NSArray<BLGroupConfig *> *config;

@end



NS_ASSUME_NONNULL_END
