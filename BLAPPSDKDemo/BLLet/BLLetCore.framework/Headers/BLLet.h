//
//  Let.h
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>

#import "BLConfigParam.h"
#import "BLController.h"
#import "BLIRCode.h"

/**
 * APPSDK核心类
 * 为了设备的安全，所有使用 SDK 的用户必须向 BroadLink Co., Ltd.申请 License。
 * License 与应用的包名(packageName)相关联，不同的应用包名需要申请不同的 License。 
 * License 还用于远程资源访问的限制。
 *
 * APPSDK Core Class.
 * ALL sdk users should apply for license from BroadLink Co., Ltd.
 * License is associated with the package name. Different application should apply for different License.
 *
 */
@interface BLLet : NSObject

/** Debug log Levels */
@property (nonatomic, assign) BLDebugLevelEnum debugLog;

/** Global Config Params Instance object */
@property (nonatomic, strong) BLConfigParam *configParam;

/** Device Instance object */
@property (nonatomic, strong) BLController *controller;

/** IRCode object */
@property (nonatomic, strong) BLIRCode *ircode;


/**
 *  Get APPSDK Instance object with License.
 *  You must call this method first, if you want to use appsdk.
 *
 *  @param license License from BroadLink Co., Ltd.
 *
 *  @return APPSDK Instance object
 */
+ (instancetype)sharedLetWithLicense:(NSString *)license;

/**
 *  Get APPSDK Instance object without License.
 *  This method can only be used after "sharedLetWithLicense:" .
 *
 *  @return APPSDK Instance object
 */
+ (instancetype)sharedLet;

/**
 *  Get APPSDK Version
 *
 *  @return Version
 */
- (NSString *)getSDKVersion;

@end
