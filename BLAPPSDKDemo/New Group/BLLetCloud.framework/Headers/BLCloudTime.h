//
//  BLCloudController.h
//  Let
//
//  Created by 白洪坤 on 2017/12/8.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLCloudTimerResult.h"
#import "BLCouldTimerQueryResult.h"
@interface BLCloudTime : NSObject

@property (nonatomic, strong)NSString *loginUserid;
@property (nonatomic, strong)NSString *loginSession;
@property (nonatomic, strong)NSString *sdkLicense;

/**
 Get CloudTime controller with global config
 
 @return                    Family controller Object
 */
+ (nullable instancetype)sharedManagerWithLicenseId:(NSString * __nonnull)licenseId License:(NSString *)sdkLicense;

/**
 Add time tasks

 @param timerInfo timerInfo
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)addCloudTimer:(NSDictionary *_Nonnull)timerInfo fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLCloudTimerResult *_Nonnull result))completionHandler;


/**
 Delete time tasks

 @param jobid jobid
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)delCloudTimer:(NSString *_Nonnull)jobid actionType:(NSInteger)actionType fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLCloudTimerResult *_Nonnull result))completionHandler;

/**
 modify time tasks

 @param timerInfo timerInfo
 @param jobid jobid
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)modifyCloudTimer:(NSMutableDictionary *_Nonnull)timerInfo jobid:(NSString *_Nonnull)jobid fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLCloudTimerResult *_Nonnull result))completionHandler;

/**
 Query Device time tasks

 @param did did
 @param sDid sDid
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)queryDeviceCloudTimer:(NSString *_Nonnull)did subdevice:(NSString *_Nullable)sDid fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLCouldTimerQueryResult *_Nonnull result))completionHandler;
/**
 Query scene time tasks
 
 @param sceneid sceneid
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)querySceneCloudTimers:(NSString *_Nonnull)sceneid fromfamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLCouldTimerQueryResult *_Nonnull result))completionHandler;

@end
