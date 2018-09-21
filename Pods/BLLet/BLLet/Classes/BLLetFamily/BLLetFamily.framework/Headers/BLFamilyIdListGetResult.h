//
//  BLFamilyIdListGetResult.h
//  Let
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLFamilyIdInfo : NSObject

@property (nonatomic, assign)NSInteger shareFlag;
@property (nonatomic, strong)NSString *familyId;
@property (nonatomic, strong)NSString *familyName;
@property (nonatomic, strong)NSString *familyVersion;

@end

@interface BLFamilyIdListGetResult : BLBaseResult

@property (nonatomic, copy)NSArray<BLFamilyIdInfo *> *idList;

@end

