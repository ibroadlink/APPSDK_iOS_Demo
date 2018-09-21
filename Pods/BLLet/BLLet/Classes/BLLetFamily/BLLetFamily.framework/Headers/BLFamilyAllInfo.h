//
//  BLFamilyAllInfo.h
//  Let
//
//  Created by zjjllj on 2017/2/8.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLFamilyInfo.h"
#import "BLRoomInfo.h"
#import "BLFamilyDeviceInfo.h"
#import "BLModuleInfo.h"

//单个家庭包含的所有信息
@interface BLFamilyAllInfo : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@property (nonatomic, assign)NSInteger shareFlag;
@property (nonatomic, strong)NSString *createUser;
@property (nonatomic, strong)BLFamilyInfo *familyBaseInfo;
@property (nonatomic, strong)NSArray<BLRoomInfo *> *roomBaseInfoArray;
@property (nonatomic, strong)NSArray<BLFamilyDeviceInfo *> *deviceBaseInfo;
@property (nonatomic, strong)NSArray<BLFamilyDeviceInfo *> *subDeviceBaseInfo;
@property (nonatomic, strong)NSArray<BLModuleInfo *> *moduleBaseInfo;

@end
