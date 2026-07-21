//
//  BLQueryDeviceFaultResult.h
//  BLLetCore
//
//  Created by admin on 2019/9/24.
//  Copyright © 2019 朱俊杰. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLDeviceFaultInfo : NSObject

@property (nonatomic, assign) NSUInteger timestamp;
@property (nonatomic, assign) NSUInteger error_code;
@property (nonatomic, assign) NSUInteger index;

@end

@interface BLQueryDeviceFaultResult : BLBaseResult

@property (nonatomic, assign) NSUInteger reset_reboot;
@property (nonatomic, assign) NSUInteger other_reboot;
@property (nonatomic, copy) NSArray<BLDeviceFaultInfo *> *list;

@end

NS_ASSUME_NONNULL_END
