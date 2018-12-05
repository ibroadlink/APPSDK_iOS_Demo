//
//  BLFamilyController.h
//  Let
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BLFamilyInfo.h"
#import "BLModuleInfo.h"
#import "BLFamilyDeviceInfo.h"

#import "BLFamilyIdListGetResult.h"
#import "BLFamilyInfoResult.h"
#import "BLFamilyBaseInfoListResult.h"
#import "BLAllFamilyInfoResult.h"
#import "BLDefineRoomTypesResult.h"
#import "BLManageRoomsResult.h"
#import "BLFamilyInvitedQrcodeGetResult.h"
#import "BLFamilyInvitedQrcodePostResult.h"
#import "BLFamilyMemberInfoGetResult.h"
#import "BLFamilyConfigedDevicesResult.h"
#import "BLModuleControlResult.h"
#import "BLFamilyElectricityInfoResult.h"
#import "BLPrivateDataIdResult.h"
#import "BLPrivateDataResult.h"
#import "BLGroupDeviceInfo.h"

@interface BLFamilyController : NSObject

/** Global Http timeout, default 30000ms */
@property (nonatomic, assign, getter=getHttpTimeout) NSUInteger httpTimeout;
/** Obtain loginUserid from Login result */
@property (nonatomic, strong)NSString *loginUserid;
/** Obtain loginSession from Login result */
@property (nonatomic, strong)NSString *loginSession;
/** Obtain familyId from BLFamilyInfoResult */
@property (nonatomic, strong)NSString *currentFamilyId;

/**
 Get family controller with global config
 
 @param licenseId           licenseId
 @return                    Family controller Object
 */
+ (nullable instancetype)sharedManagerWithlicenseId:(NSString *)licenseId;

/**
 *  Get family controller with global config
 *  This method can only be used after "sharedManagerWithlicenseId:" .
 *
 *  @return      Family controller Object
 */
+ (nullable instancetype)sharedManager;

/**
 Family Http Post Request
 
 @param urlPath url path without domain
 @param head request head
 @param body request body
 @param completionHandler return
 */
- (void)familyHttpPost:(nonnull NSString *)urlPath head:(nullable NSDictionary *)head body:(nullable NSDictionary *)body completionHandler:(nonnull void (^)(NSData *__nonnull data, NSError *__nullable error))completionHandler;

/**
 Family Http Multipart Post Request

 @param urlPath url path without domain
 @param head request head
 @param body request body
 @param image post image
 @param completionHandler return
 */
- (void)familyMultipartPost:(nonnull NSString *)urlPath head:(nullable NSDictionary *)head body:(nullable NSDictionary *)body image:(nullable UIImage *)image completionHandler:(nullable void (^)(NSData *__nonnull data, NSError *__nullable error))completionHandler;

/**
 Create new family
 
 @param familyInfo          Family info
 @param iconImage           Family icon, can be nil
 @param completionHandler   Callback with create result
 */
- (void)createNewFamilyWithInfo:(nonnull BLFamilyInfo *)familyInfo iconImage:(nullable UIImage*)iconImage completionHandler:(nullable void (^)(BLFamilyInfoResult * __nonnull result))completionHandler;


/**
 Create Default family

 @param name name
 @param country country
 @param province province
 @param city city
 @param completionHandler Callback with create result
 */
- (void)createDefaultFamilyWithInfo:(nonnull NSString *)name country:(nullable NSString *)country province:(nullable NSString *)province city:(nullable NSString *)city completionHandler:(nullable void (^)(BLFamilyInfoResult * __nonnull result))completionHandler;

/**
 * Set current family id
 * @param currentFamilyId currentFamilyId
 */
- (void)setCurrentFamilyId:(NSString *_Nullable)currentFamilyId;
/**
 Query all family id list by current login user.
 
 @param completionHandler   Callback with query result
 */
- (void)queryLoginUserFamilyIdListWithCompletionHandler:(nullable void (^)(BLFamilyIdListGetResult * __nonnull result))completionHandler;

/**
 Query all family baseinfo list by current login user.
 
 @param completionHandler   Callback with query result
 */
- (void)queryLoginUserFamilyBaseInfoListWithCompletionHandler:(nullable void (^)(BLFamilyBaseInfoListResult * __nonnull result))completionHandler;
/**
 Query family all infos with specify ids

 @param ids                 Family id list
 @param completionHandler   Callback with query result
 */
- (void)queryFamilyInfoWithIds:(nonnull NSArray *)ids completionHandler:(nullable void (^)(BLAllFamilyInfoResult * __nonnull result))completionHandler;

/**
 Modify family base info
 
 @param familyInfo          Family base info
 @param completionHandler   Callback with modify result
 */
- (void)modifyFamilyInfoWithBaseFamilyInfo:(nonnull BLFamilyInfo *)familyInfo completionHandler:(nullable void (^)(BLFamilyInfoResult * __nonnull result))completionHandler;

/**
 Modify family base info and icon image
 
 @param familyInfo          Family base info
 @param iconImage           New icon image
 @param completionHandler   Callback with modify result
 */
- (void)modifyFamilyIconWithBaseFamilyInfo:(nonnull BLFamilyInfo *)familyInfo iconImage:(nonnull UIImage *)iconImage completionHandler:(nullable void (^)(BLFamilyInfoResult * __nonnull result))completionHandler;

/**
 Delete family with family id and version
 
 @param familyId            Family id
 @param version             Family current version
 @param completionHandler   Callback with delete result
 */
- (void)delFamilyWithFamilyId:(nonnull NSString *)familyId familyVersion:(nonnull NSString *)version completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Get System pre define room types
 
 @param completionHandler   Callback with get result
 */
- (void)getSystemPreDefineRoomTypesWithcompletionHandler:(nullable void (^)(BLDefineRoomTypesResult * __nonnull result))completionHandler;

/**
 Manage rooms with family id and version
 
 @param familyId            Family id
 @param version             Family current version
 @param rooms               Rooms in family
 @param completionHandler   Callback with manage result
 */
- (void)manageRoomsWithFamilyId:(nonnull NSString *)familyId familyVersion:(nonnull NSString *)version rooms:(nonnull NSArray <BLRoomInfo *>*)rooms completionHandler:(nullable void (^)(BLManageRoomsResult * __nonnull result))completionHandler;

/**
 Get family invite qrcode from server with family id
 
 @param familyId            Family id
 @param completionHandler   Callback with get result
 */
- (void)getFamilyInvitedQrcodeWithFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLFamilyInvitedQrcodeGetResult * __nonnull result))completionHandler;

/**
 Post scan family invite qrcode string to server
 
 @param qrcode              Qrcode string
 @param completionHandler   Callback with post result
 */
- (void)postScanFamilyInvitedQrcode:(nonnull NSString *)qrcode completionHandler:(nullable void (^)(BLFamilyInvitedQrcodePostResult * __nonnull result))completionHandler;

/**
 Join Family with scan qrcode string
 
 @param qrcode              Qrcode string
 @param completionHandler   Callback with join result
 */
- (void)joinFamilyWithQrcode:(nonnull NSString *)qrcode completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Join family with family id
 
 @param familyId            Family ID
 @param completionHandler   Callback with join result
 */
- (void)joinFamilyWithFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Quite family with family id
 
 @param familyId            Family ID
 @param completionHandler   Callback with quite result
 */
- (void)quiteFamilyWithFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Delete family members with family id
 
 @param familyId            Family ID
 @param members             Delete members
 @param completionHandler   Callback with delete result
 */
- (void)deleteFamilyMembersWithFamilyId:(nonnull NSString *)familyId members:(nonnull NSArray *)members completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Get all family member infos with family id
 
 @param familyId            Family ID
 @param completionHandler   Callback with get result
 */
- (void)getFamilyMemberInfosWithFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLFamilyMemberInfoGetResult * __nonnull result))completionHandler;

/**
 Charge devices have been family configed or not
 
 @param dids                Deice did list
 @param completionHandler   Callback with charge result
 */
- (void)chargeDevicesHaveFamilyConfigedWithDids:(nonnull NSArray *)dids completionHandler:(nullable void (^)(BLFamilyConfigedDevicesResult * __nonnull result))completionHandler;

/**
 Remove device from family
 
 @param did                 Delete device did
 @param familyId            Family id
 @param familyVersion       Family current version
 @param completionHandler   Callback with delete result
 */
- (void)removeDeviceWithDid:(nonnull NSString*)did fromFamilyId:(nonnull NSString *)familyId familyVersion:(nonnull NSString *)familyVersion completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Add module to family
 
 @param moduleInfo          Add module indo
 @param familyInfo          Family info
 @param deviceInfo          Module contains device info, can nil.
 @param subDeviceInfo       Module contains sub device info, can nil.
 @param completionHandler   Callback with add result
 */
- (void)addModule:(nonnull BLModuleInfo*)moduleInfo toFamily:(nonnull BLFamilyInfo*)familyInfo withDevice:(nullable BLFamilyDeviceInfo*)deviceInfo subDevice:(nullable BLFamilyDeviceInfo*)subDeviceInfo  completionHandler:(nullable void (^)(BLModuleControlResult * __nonnull result))completionHandler;

/**
 Add module to family
 
 @param moduleInfo          Add module indo
 @param familyInfo          Family info
 @param deviceInfo          Module contains device info, can nil.
 @param subDeviceInfo       Module contains sub device info, can nil.
 @param groupDeviceList     Group device info, can nil.
 @param completionHandler   Callback with add result
 */
- (void)addModule:(nonnull BLModuleInfo*)moduleInfo toFamily:(nonnull BLFamilyInfo*)familyInfo withDevice:(nullable BLFamilyDeviceInfo*)deviceInfo subDevice:(nullable BLFamilyDeviceInfo*)subDeviceInfo groupDeviceList:(NSArray <BLGroupDeviceInfo *> *_Nullable)groupDeviceList completionHandler:(nullable void (^)(BLModuleControlResult * __nonnull result))completionHandler;

/**
 Delete module from family
 
 @param moduleId            Delete module ID
 @param familyId            Family ID
 @param version             Family current version
 @param completionHandler   Callback with delete result
 */
- (void)delModuleWithId:(nonnull NSString *)moduleId fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)version completionHandler:(nullable void (^)(BLModuleControlResult * __nonnull result))completionHandler;

/**
 Modify module info from family
 
 @param moduleInfo          Modify module info
 @param familyId            Family ID
 @param version             Family current version
 @param completionHandler   Callback with modify result
 */
- (void)modifyModule:(nonnull BLModuleInfo*)moduleInfo fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)version completionHandler:(nullable void (^)(BLModuleControlResult * __nonnull result))completionHandler;

/**
 Modify module flag from family
 
 @param moduleId            Modify module ID
 @param newFalg             New flag
 @param familyId            Family ID
 @param version             Family current version
 @param completionHandler   Callback with modify result
 */
- (void)modifyModuleWithId:(nonnull NSString*)moduleId flag:(NSInteger)newFalg fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)version completionHandler:(nullable void (^)(BLModuleControlResult * __nonnull result))completionHandler;

/**
 Move module to specify room in family
 
 @param moduleId            Move module ID
 @param roomId              Specify room ID
 @param familyId            Family ID
 @param version             Family current version
 @param completionHandler   Callback with move result
 */
- (void)moveModuleWithId:(nonnull NSString*)moduleId toRoomId:(nonnull NSString*)roomId fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)version completionHandler:(nullable void (^)(BLModuleControlResult * __nonnull result))completionHandler;

/**
 Modify module info and move to specify room in family
 
 @param moduleInfo          Modify module info
 @param roomId              Specify room ID
 @param type                Move type
 @param familyId            Family ID
 @param version             Family current version
 @param completionHandler   Callback with modify result
 */
- (void)modifyModule:(nonnull BLModuleInfo*)moduleInfo andMoveToRoomId:(nonnull NSString*)roomId moveType:(NSUInteger)type  fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)version completionHandler:(nullable void (^)(BLModuleControlResult * __nonnull result))completionHandler;

/**
 Query family peak valley electricity info
 
 @param completionHandler   Callback with query result
 */
- (void)queryFamilyPeakValleyElectricityInfoWithCompletionHandler:(nullable void (^)(BLFamilyElectricityInfoResult * __nonnull result))completionHandler;

/**
 Config family peak valley electricity info
 
 @param info                New family peak valley electricity info
 @param completionHandler   Callback with config result
 */
- (void)configFamilyPeakValleyElectricityWithInfo:(nonnull BLFamilyElectricityInfo*)info completionHandler:(nullable void (^)(BLFamilyElectricityInfoResult * __nonnull result))completionHandler;

/**
 * Get private data id
 * @param mtag mtag
 */
- (BLPrivateDataIdResult * __nonnull)getFamilyPrivateDataIdWithMtag:(NSString *_Nullable)mtag;

/**
 * Update private data list
 * @param datalist dataList
 */
- (BLPrivateDataResult *__nonnull)updateFamilyPrivateDataWithDatalist:(NSArray <BLPrivateData *> *_Nullable)datalist mtag:(NSString *_Nullable)mtag familyVersion:(NSString *_Nullable)familyVersion isUpdataFamilyVersion:(NSInteger)isUpdataFamilyVersion;
/**
 * Delete private data list
 * @param datalist dataList
 */
- (BLBaseResult *__nonnull)deleteFamilyPrivateDataWithDatalist:(NSArray <BLPrivateData *> *_Nullable)datalist mtag:(NSString *_Nullable)mtag familyVersion:(NSString *_Nullable)familyVersion isUpdataFamilyVersion:(NSInteger)isUpdataFamilyVersion;

/**
 * Query private data by key
 * @param mkeyid mkeyid
 * @param mtag mtag
 */
- (BLPrivateDataResult * __nonnull)queryFamilyPrivateDataWithMkeyid:(NSString *_Nullable)mkeyid mtag:(NSString *_Nullable)mtag;
@end

