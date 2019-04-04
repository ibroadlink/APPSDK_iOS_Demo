//
//  ConfigParam.h
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLConstants.h"

@interface BLConfigParam : NSObject

/**
 Get Global Config Settings
 
 @return Global Config Params Instance object
 */
+ (instancetype)sharedConfigParam;

/** Get License from BroadLink Co., Ltd. */
@property (nonatomic, copy) NSString *sdkLicense;

/** APP Package Name (Bundle ID)**/
@property (nonatomic, copy) NSString *packName;

/** Get Company ID */
@property (nonatomic, copy) NSString *companyId;

/** Get License ID */
@property (nonatomic, copy) NSString *licenseId;

/** Get login user ID */
@property (nonatomic, copy) NSString *userid;

/** Get login user session */
@property (nonatomic, copy) NSString *loginSession;

/** Get login user family ID */
@property (nonatomic, copy) NSString *familyId;

/* Device Pair serInfo **/
@property (nonatomic, copy) NSDictionary *deviceConnectServiceInfo;

/** Global Http timeout, default 30000ms */
@property (nonatomic, assign, getter=getHttpTimeout) NSUInteger httpTimeout;

/** Account Http request host base url */
@property (nonatomic, copy, getter=getAccountHost) NSString *accountHost;

/** APP Manage Http request host base url */
@property (nonatomic, copy, getter=getAppManageHost) NSString *appManageHost;

/** IRCode Http request host base url */
@property (nonatomic, copy, getter=getIRCodeHost) NSString *iRCodeHost;

/** Family Http request host base url */
@property (nonatomic, copy, getter=getFamilyHost) NSString *familyHost;

/** FamilyPrivate Http request host base url */
@property (nonatomic, copy, getter=getFamilyPrivateHost) NSString *familyPrivateHost;

/** Data Service Http request host base url */
@property (nonatomic, copy, getter=getDataServiceHost) NSString *dataServiceHost;

/** Picker Http request host base url */
@property (nonatomic, copy, getter=getPickerHost) NSString *pickerHost;

/** CloudTime Http request host base url */
@property (nonatomic, copy, getter=getCloudHost) NSString *cloudHost;

/** Oauth Http request host base url */
@property (nonatomic, copy, getter=getOauthHost) NSString *oauthHost;

/** App Service Http request host base url */
@property (nonatomic, copy, getter=getAppServiceHost) NSString *appServiceHost;

/** APP Controler store script and ui path, default in ./Let/ */
@property (nonatomic, copy, getter=getSdkFileSavePath) NSString *sdkFileSavePath;

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

/** APPService Enable , default 0 */
@property (nonatomic, assign, getter=getAppServiceEnable) NSUInteger appServiceEnable;

/* APP Controler remote resend , default 0 **/
@property (nonatomic, assign) NSUInteger controllerResendMode;

/* BLPicker Data report count, default 20 **/
@property (nonatomic, assign) NSUInteger dataReportCount;

@end
