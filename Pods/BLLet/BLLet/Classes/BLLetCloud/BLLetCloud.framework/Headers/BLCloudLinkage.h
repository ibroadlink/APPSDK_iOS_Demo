//
//  BLCloudLinkage.h
//  BLLetCloud
//
//  Created by 白洪坤 on 2017/12/26.
//  Copyright © 2017年 白洪坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLLinkageInfoResult.h"
#import "BLLinkageDataResult.h"

@interface BLCloudLinkage : NSObject

@property (nonatomic, strong)NSString *loginUserid;
@property (nonatomic, strong)NSString *loginSession;
@property (nonatomic, strong)NSString *sdkLicense;

/**
 Get CloudLinkage controller with global config
 
 @return  Family controller Object
 */
+ (nullable instancetype)sharedManagerWithLicenseId:(NSString * __nonnull)licenseId License:(NSString *)sdkLicense;
/**
 Added linkage information
 
 @param linkageInfo linkageInfo
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)addCloudLinkage:(NSDictionary *_Nonnull)linkageInfo fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLLinkageInfoResult *_Nonnull result))completionHandler;

/**
 Delete linkage information
 
 @param ruleid ruleid
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)deleteLinkageInfoWithRuleid:(NSString *_Nonnull)ruleid fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;

/**
 Query linkage information
 
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)queryCloudLinkageInfo:(NSString *_Nonnull)familyId completionHandler:(nullable void (^)(BLLinkageDataResult *_Nonnull result))completionHandler ;

/**
 Perform linkage tasks
 
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)executeCloudLinkage:(NSString *_Nonnull)familyId completionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;

/**
 Stop linkage tasks
 
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)stopCloudLinkage:(NSString *_Nonnull)familyId completionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;
@end
