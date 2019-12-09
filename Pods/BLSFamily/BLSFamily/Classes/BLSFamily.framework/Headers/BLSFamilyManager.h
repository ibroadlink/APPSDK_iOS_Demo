//
//  BLSFamilyManager.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLSFamilyInfoResult.h"
#import "BLSFamilyCreateResult.h"
#import "BLSFamilyListResult.h"
#import "BLSFamilyIconResult.h"
#import "BLSInvitedQrcodeResult.h"
#import "BLSFamilyMembersResult.h"
#import "BLSManageRoomResult.h"
#import "BLSQueryEndpointsResult.h"
#import "BLSQueryScenesResult.h"
#import "BLSAddSceneResult.h"
#import "BLSAddAuthResult.h"
#import "BLLinkageInfo.h"
#import "BLSVirtualidResult.h"
#import "BLSGroupDevice.h"
#import "BLSGroupDeviceResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLSFamilyManager : NSObject

/** you need set familyid by yourself **/
@property (nonatomic, copy)NSString *familyid;

+ (instancetype)sharedFamily;

/**
 Create Default family
 
 @param name name
 @param country country
 @param province province
 @param city city
 @param completionHandler Callback with create result
 */
- (void)createDefaultFamilyWithInfo:(nonnull NSString *)name country:(nullable NSString *)country province:(nullable NSString *)province city:(nullable NSString *)city completionHandler:(nullable void (^)(BLSFamilyCreateResult * __nonnull result))completionHandler;

/**
 Delete family with familyid
 
 @param familyid            Family id
 @param completionHandler   Callback with delete result
 */
- (void)delFamilyWithFamilyid:(nonnull NSString *)familyid completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Modify family base info.(as name / description / countryCode / provinceCode / cityCode / familylimit)
 
 @param info          Family base info
 @param completionHandler   Callback with modify result
 */
- (void)modifyFamilyInfo:(nonnull BLSFamilyInfo *)info completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Modify family icon

 @param iconImage icon image
 @param completionHandler Callback with modify result
 */
- (void)modifyFamilyIcon:(nonnull UIImage *)iconImage completionHandler:(nullable void (^)(BLSFamilyIconResult * __nonnull result))completionHandler;

/**
 Query all family baseinfo list by current login user.
 
 @param completionHandler   Callback with query result
 */
- (void)queryFamilyBaseInfoListWithCompletionHandler:(nullable void (^)(BLSFamilyListResult * __nonnull result))completionHandler;

/**
 Get family invite qrcode from server
 
 @param completionHandler   Callback with get resultC
 */
- (void)getFamilyInvitedQrcodeWithCompletionHandler:(nullable void (^)(BLSInvitedQrcodeResult * __nonnull result))completionHandler;

/**
 Query family info by invite qrcode
 
 @param qrcode              Qrcode string
 @param completionHandler   Callback with post result
 */
- (void)queryFamilyInfoWithQrcode:(nonnull NSString *)qrcode completionHandler:(nullable void (^)(BLSFamilyInfoResult * __nonnull result))completionHandler;

/**
 Join Family with invite qrcode
 
 @param qrcode              Qrcode string
 @param completionHandler   Callback with join result
 */
- (void)joinFamilyWithQrcode:(nonnull NSString *)qrcode completionHandler:(nullable void (^)(BLSFamilyInfoResult * __nonnull result))completionHandler;

/**
 Get all family members
 
 @param completionHandler   Callback with get result
 */
- (void)getFamilyMembersWithCompletionHandler:(nullable void (^)(BLSFamilyMembersResult * __nonnull result))completionHandler;

/**
 Delete family members
 
 @param userids             Delete userids
 @param completionHandler   Callback with delete result
 */
- (void)deleteFamilyMembersWithUserids:(nonnull NSArray *)userids completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;


/**
 Quite family
 
 @param completionHandler   Callback with quite result
 */
- (void)quiteFamilyWithCompletionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;


/**
 Transfer family master to other user

 @param userid userid
 @param completionHandler Callback with transfer result
 */
- (void)transferFamilyMasterToUserid:(nonnull NSString *)userid completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;


/**
 Destory Family

 @param verifyCode verifyCode,{“phone”:“152”,“email”:“”,“type”:“phone”,“code”:“”,“countrycode”:“”,“companyid”:“”,“codetype”:“”}
 @param completionHandler Callback  result
 */
- (void)destoryFamilyToVerifyCode:(nonnull NSString *)verifyCode completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Get all family rooms
 
 @param completionHandler   Callback with get result
 */
- (void)getFamilyRoomsWithCompletionHandler:(nullable void (^)(BLSManageRoomResult * __nonnull result))completionHandler;

/**
 Manage rooms
 action 传入del,modify,add表示删除、修改、增加
 
 @param rooms               Rooms in family
 @param completionHandler   Callback with manage result
 */
- (void)manageRooms:(nonnull NSArray <BLSRoomInfo *>*)rooms completionHandler:(nullable void (^)(BLSManageRoomResult * __nonnull result))completionHandler;


/**
 Get all endpoints in family

 @param completionHandler  Callback with get result
 */
- (void)getEndpointsWithCompletionHandler:(nullable void (^)(BLSQueryEndpointsResult * __nonnull result))completionHandler;


/**
 Get all endpoints by userid

 @param querypage querypage
 @param querystep querystep
 @param completionHandler Callback with get result
 */
- (void)getEndpointsWithQuerypage:(NSInteger)querypage querystep:(NSInteger)querystep completionHandler:(nullable void (^)(BLSQueryEndpointsResult * __nonnull result))completionHandler;

/**
 add endpoints to family

 @param endpoints Endpoint list
 @param completionHandler Callback with add resutl
 */
- (void)addEndpoints:(nonnull NSArray <BLSEndpointInfo *>*)endpoints completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 del endpoint from family

 @param endpointId Endpoint id
 @param completionHandler Callback with del resutl
 */
- (void)delEndpoint:(nonnull NSString *)endpointId completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Modify endpoint info in family

 @param endpoint Endpoint info
 @param completionHandler Callback with modify result
 */
- (void)modifyEndpoint:(nonnull BLSEndpointInfo *)endpoint completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Modify endpoint some attributes in family

 @param endpointId endpointId
 @param attributes attributes
 @param completionHandler  Callback with modify result
 */
- (void)modifyEndpoint:(nonnull NSString *)endpointId attributes:(NSArray *)attributes completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Get all scenes in family
 
 @param completionHandler  Callback with get result
 */
- (void)getScenesWithCompletionHandler:(nullable void (^)(BLSQueryScenesResult * __nonnull result))completionHandler;

/**
 add scene to family
 
 @param sceneInfo Scene info
 @param completionHandler Callback with add resutl
 */
- (void)addScene:(nonnull BLSSceneInfo *)sceneInfo completionHandler:(nullable void (^)(BLSAddSceneResult * __nonnull result))completionHandler;

/**
 del scene from family
 
 @param sceneId sceneId
 @param completionHandler Callback with del resutl
 */
- (void)delScene:(nonnull NSString *)sceneId completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Modify scene info in family
 
 @param sceneInfo Scene info
 @param completionHandler Callback with modify result
 */
- (void)modifyScene:(nonnull BLSSceneInfo *)sceneInfo completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 Modify scene some attributes in family
 
 @param sceneId sceneId
 @param attributes attributes
 @param completionHandler  Callback with modify result
 */
- (void)modifyScene:(nonnull NSString *)sceneId attributes:(NSArray *)attributes completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 add Linkage

 @param linkageInfo linkageInfo description
 @param completionHandler result
 */
- (void)addCloudLinkage:(BLLinkageInfo *_Nonnull)linkageInfo completionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;

/**
 modify Linkage

 @param linkageInfo linkageInfo description
 @param completionHandler result
 */
- (void)modifyCloudLinkage:(BLLinkageInfo *_Nonnull)linkageInfo completionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;

/**
 delete Linkage

 @param ruleid ruleid description
 @param completionHandler result
 */
- (void)deleteLinkageInfoWithRuleid:(NSString *_Nonnull)ruleid completionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;

/**
 query Linkage

 @param completionHandler result
 */
- (void)queryCloudLinkageInfoWithCompletionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;

/**
 get Virtualid

 @param devicetypeFlag 实体设备(0),其他平台虚拟设备(1),分组设备(2),分路设备(3),功能模块虚拟设备(4)
 @param productId productId description
 @param gatewayId gatewayId description
 @param completionHandler result
 */
- (void)getVirtualidWithDevicetypeFlag:(NSInteger)devicetypeFlag productId:(NSString *_Nonnull)productId gatewayId:(NSString *_Nonnull)gatewayId completionHandler:(nullable void (^)(BLSVirtualidResult * __nonnull result))completionHandler;

/**
 group DeviceManage

 @param endpointId endpointId description
 @param action "add/del",//add 如果重复did则覆盖.del时可以只传did,gatewayid
 @param groupdevices groupdevices description
 @param completionHandler result
 */
- (void)groupDeviceManageWithEndpointId:(NSString *_Nonnull)endpointId action:(NSString *_Nonnull)action groupdevices:(NSArray<BLSGroupDevice *> *_Nonnull)groupdevices completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler;

/**
 query GroupDevice

 @param endpointId endpointId description
 @param completionHandler result
 */
- (void)queryGroupDeviceWithEndpointId:(NSString *_Nonnull)endpointId completionHandler:(nullable void (^)(BLSGroupDeviceResult * __nonnull result))completionHandler;
@end

NS_ASSUME_NONNULL_END
