//
//  BLSFamilyInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLSRoomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLSFamilyInfo : NSObject

@property (nonatomic, copy)NSString *familyid;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *version;
@property (nonatomic, copy)NSString *createUser;
@property (nonatomic, copy)NSString *createTime;
@property (nonatomic, copy)NSString *master;
@property (nonatomic, copy)NSString *iconpath;
@property (nonatomic, copy)NSString *countryCode;
@property (nonatomic, copy)NSString *provinceCode;
@property (nonatomic, copy)NSString *cityCode;
@property (nonatomic, copy)NSString *desc;

@property (nonatomic, assign)NSInteger familylimit;

@property (nonatomic, copy)NSArray *roominfo;

@end

NS_ASSUME_NONNULL_END
