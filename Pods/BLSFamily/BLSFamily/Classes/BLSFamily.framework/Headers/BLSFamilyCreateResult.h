//
//  BLSFamilyCreateResult.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLSFamilyInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLSFamilyCreateResult : BLBaseResult

@property (nonatomic, copy)NSString *version;
@property (nonatomic, strong)BLSFamilyInfo *data;

@end

NS_ASSUME_NONNULL_END
