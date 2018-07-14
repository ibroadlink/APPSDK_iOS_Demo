//
//  BLFamilyMemberInfoGetResult.h
//  Let
//
//  Created by zjjllj on 2017/2/8.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLFamilyMemberInfo.h"

@interface BLFamilyMemberInfoGetResult : BLBaseResult

@property (nonatomic, copy)NSArray<BLFamilyMemberInfo *> *memberInfoArray;

@end
