//
//  BLCloudScene.h
//  BLLetCloud
//
//  Created by 白洪坤 on 2017/12/26.
//  Copyright © 2017年 白洪坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLSceneControlResult.h"
#import "BLSceneHistroyResult.h"
#import "BLSceneDeteailResult.h"
#import "BLSceneResult.h"
@interface BLCloudScene : NSObject

/** Obtain loginUserid from Login result */
@property (nonatomic, strong)NSString *loginUserid;
/** Obtain loginSession from Login result */
@property (nonatomic, strong)NSString *loginSession;

@property (nonatomic, strong)NSString *sdkLicense;

/**
 Get CloudScene controller with global config
 
 @return  Family controller Object
 */
+ (nullable instancetype)sharedManagerWithLicenseId:(NSString * __nonnull)licenseId License:(NSString *)sdkLicense;
/**
 Add module to family
 
 @param sceneInfo          Add module indo
 @param familyId          Family info
 @param deviceInfo          Module contains device info, can nil.
 @param subDeviceInfo       Module contains sub device info, can nil.
 @param completionHandler   Callback with add result
 */
- (void)addScene:(nonnull NSDictionary*)sceneInfo withDevice:(nullable NSDictionary*)deviceInfo subDevice:(nullable NSDictionary*)subDeviceInfo fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)familyVersion  completionHandler:(nullable void (^)(BLSceneResult * __nonnull result))completionHandler;
/**
 Delete module from family
 
 @param sceneId             Delete module ID
 @param familyId            Family ID
 @param familyVersion             Family current version
 @param completionHandler   Callback with delete result
 */
- (void)delScene:(nonnull NSString *)sceneId fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)familyVersion completionHandler:(nullable void (^)(BLSceneResult * __nonnull result))completionHandler;
/**
 Modify module info from family
 
 @param sceneInfo          Modify module info
 @param familyId            Family ID
 @param familyVersion             Family current version
 @param completionHandler   Callback with modify result
 */
- (void)modifyScene:(nonnull NSDictionary*)sceneInfo fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)familyVersion completionHandler:(nullable void (^)(BLSceneResult * __nonnull result))completionHandler;
/**
 Move module to specify room in family
 
 @param sceneId            sceneId
 @param roomId              Specify room ID
 @param familyId            Family ID
 @param familyVersion             Family current version
 @param completionHandler   Callback with move result
 */
- (void)moveScene:(nonnull NSString*)sceneId toRoomId:(nonnull NSString*)roomId fromFamilyId:(nonnull NSString *)familyId familyVersion:(nullable NSString *)familyVersion completionHandler:(nullable void (^)(BLSceneResult * __nonnull result))completionHandler;
/**
 Scene task execution
 
 @param sceneId             sceneId
 @param familyId             Family ID
 @param completionHandler    Callback result
 */
- (void)controlScene:(NSString *_Nonnull)sceneId fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLSceneControlResult * __nonnull result))completionHandler;
/**
 Scene task canceled
 
 @param taskid scene taskid ID
 @param familyId Family ID
 @param completionHandler Callback result
 */
- (void)cancelScene:(NSString *_Nonnull)taskid fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLSceneControlResult * _Nonnull result))completionHandler;
/**
 Query Scene history task
 
 @param sceneId sceneId
 @param index index
 @param count count
  @param familyId familyId
 @param completionHandler Callback result
 */
- (void)querySceneHistory:(NSString *_Nonnull)sceneId index:(NSInteger)index count:(NSInteger)count fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLSceneHistroyResult * _Nonnull result))completionHandler;
/**
 Query Scene task deteail
 
 @param taskidList taskidList
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)querySceneDeteail:(NSArray *_Nonnull)taskidList fromFamilyId:(nonnull NSString *)familyId completionHandler:(nullable void (^)(BLSceneDeteailResult *_Nonnull result))completionHandler;
/**
 Query scene real-time tasks
 
 @param familyId familyId
 @param completionHandler Callback result
 */
- (void)querySceneRuning:(NSString *_Nonnull)familyId completionHandler:(nullable void (^)(BLSceneDeteailResult *_Nonnull result))completionHandler;
@end
