//
//  BLSFamilyInfoResult.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLSFamilyInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLSFamilyInfoResult : BLBaseResult

@property (nonatomic, strong)BLSFamilyInfo *familyInfo;

@end

NS_ASSUME_NONNULL_END
