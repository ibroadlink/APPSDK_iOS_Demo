//
//  BLFamilyBaseInfoListResult.h
//  Let
//
//  Created by zhujunjie on 2017/11/2.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLFamilyInfo.h"

@interface BLFamilyInfoBase : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@property (nonatomic, assign)NSInteger shareFlag;
@property (nonatomic, strong)NSString *createUser;
@property (nonatomic, strong)BLFamilyInfo *familyInfo;

@end

@interface BLFamilyBaseInfoListResult : BLBaseResult

@property (nonatomic, strong)NSArray<BLFamilyInfoBase *> *infoList;

@end
