//
//  BLDeviceConfigureInfo.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDeviceConfigIntroduction.h"
NS_ASSUME_NONNULL_BEGIN

@interface BLDeviceConfigureInfo : NSObject

@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *moduleName;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *failedHtml;
@property (nonatomic, strong) NSString *beforeConfigHtml;
@property (nonatomic, strong) NSString *configPicUrlString;
@property (nonatomic, strong) NSString *iconUrlString;
@property (nonatomic, strong) NSString *shortCutIconUrlString;
//@property (nonatomic, strong) ModuleProfile *moduleProfile;
@property (nonatomic, strong) NSArray *ads;
@property (nonatomic, strong) NSArray<BLDeviceConfigIntroduction *> *introduction;
@property (nonatomic, strong) NSString *resetPic;
@property (nonatomic, strong) NSString *resetText;
@property (nonatomic, strong) NSString *configText;
@property (nonatomic, strong) NSString *mappid;//云端用来映射产品信息的pid。产品列表中当mappid等于pid时显示，不相等时过滤
@property (nonatomic, strong) NSArray *pids;//该产品对应的pid数组
@property (nonatomic, strong) NSString *profile;//该产品对应的profile
@property (nonatomic, strong) NSNumber *protocol;//该产品对应的protocol

@end

NS_ASSUME_NONNULL_END
