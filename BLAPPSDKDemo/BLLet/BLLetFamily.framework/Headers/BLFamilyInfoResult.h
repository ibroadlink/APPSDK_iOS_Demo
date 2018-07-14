//
//  BLFamilyInfoResult.h
//  Let
//
//  Created by zjjllj on 2017/2/7.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLFamilyInfo.h"
#import "BLRoomInfo.h"
@interface BLFamilyInfoResult : BLBaseResult

@property (nonatomic, strong)BLFamilyInfo *familyInfo;
@property (nonatomic, strong)NSArray<BLRoomInfo *> *roomInfos;
@end
