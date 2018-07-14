//
//  ConfigParam.h
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>

@interface BLConfigParam : NSObject

/**
 Init Global Config Settings by license.

 @param license license from BroadLink Co., Ltd.
 @return Global Config Params Instance object
 */
+ (instancetype)sharedConfigParamWithLicense:(NSString *)license;

/** Get License from BroadLink Co., Ltd. */
@property (nonatomic, strong, readonly) NSString *sdkLicense;

/** Get Company ID */
@property (nonatomic, strong, readonly) NSString *companyId;

/** Get License ID */
@property (nonatomic, strong, readonly) NSString *licenseId;

/** Global Http timeout, default 30000ms */
@property (nonatomic, assign, getter=getHttpTimeout) NSUInteger httpTimeout;

/** Account Http timeout, default 30000ms */
@property (nonatomic, assign, getter=getAccountHttpTimeout) NSUInteger accountHttpTimeout;

/** Account Http retry times, default 1 */
@property (nonatomic, assign, getter=getAccountHttpRetryTimes) NSUInteger accountHttpRetryTimes;

/** Account Http request host base url */
@property (nonatomic, strong, getter=getAccountHost) NSString *accountHost;

/** APP Manage Http request host base url */
@property (nonatomic, strong, getter=getAppManageHost) NSString *appManageHost;

/** IRCode Http request host base url */
@property (nonatomic, strong, getter=getIRCodeHost) NSString *iRCodeHost;

/** Family Http request host base url */
@property (nonatomic, strong, getter=getFamilyHost) NSString *familyHost;

/** FamilyPrivate Http request host base url */
@property (nonatomic, strong, getter=getFamilyPrivateHost) NSString *familyPrivateHost;

/** Data Service Http request host base url */
@property (nonatomic, strong, getter=getDataServiceHost) NSString *dataServiceHost;

/** Picker Http request host base url */
@property (nonatomic, strong, getter=getPickerHost) NSString *pickerHost;

/** Oauth Http request host base url */
@property (nonatomic, strong, getter=getOauthHost) NSString *oauthHost;
/** APP Controler store script and ui path, default in ./Let/ */
@property (nonatomic, strong, getter=getSdkFileSavePath) NSString *sdkFileSavePath;

/** APP Controler probe devices timeout, default 3000ms */
@property (nonatomic, assign, getter=getControllerProbeInterval) NSUInteger controllerProbeInterval;

/** APP Controler control devices timeout in lan, default 2000ms*/
@property (nonatomic, assign, getter=getControllerLocalTimeout) NSUInteger controllerLocalTimeout;

/** APP Controler control devices timeout in wan, default 4000ms*/
@property (nonatomic, assign, getter=getControllerRemoteTimeout) NSUInteger controllerRemoteTimeout;

/** APP Controler control devices netmode, default BL_NET_DEFAULT */
@property (nonatomic, assign, getter=getControllerNetMode) BLDeviceNetModeEnum controllerNetMode;

/** APP Controler control devices send package count, default 1 */
@property (nonatomic, assign, getter=getControllerSendCount) NSUInteger controllerSendCount;

/** APP Controler query device status count, default 100 */
@property (nonatomic, assign, getter=getControllerQueryCount) NSUInteger controllerQueryCount;

/** APP Controler easyconfig timeout - set device wifi ssid and password timeout, default 75s */
@property (nonatomic, assign, getter=getControllerEasyConfigTimeout) NSUInteger controllerEasyConfigTimeout;

/** APP Download address whether to use the new platform , default 0 */
@property (nonatomic, assign, getter=getControllerScriptDownloadVersion) NSUInteger controllerScriptDownloadVersion;

@end
