//
//  Tools.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/3.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BLLetCore/BLLetCore.h>
#import <BLLetBase/BLLetBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject

#pragma mark - Image
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize compressionQuality:(CGFloat)compressionQuality;

#pragma mark - Device
/// ownerId 存在时返回 deviceId，否则返回 did
+ (NSString *)controlDidForDevice:(BLDNADevice *)device;
/// 定时等场景：优先 sdid，否则 device.did
+ (NSString *)timerTargetDidForDevice:(BLDNADevice *)device sdid:(nullable NSString *)sdid;
+ (NSString *)stringForDeviceState:(BLDeviceStatusEnum)state;

#pragma mark - JSON / Result
+ (nullable NSString *)jsonStringFromObject:(id)obj;
+ (nullable NSDictionary *)dictionaryFromJSONString:(NSString *)json;
+ (NSString *)messageForError:(NSInteger)error msg:(nullable NSString *)msg;
+ (NSString *)messageForSDKResult:(BLBaseResult *)result;

#pragma mark - Cordova / UI Resource
+ (BOOL)copyCordovaJsNamed:(NSString *)fileName forPid:(NSString *)pid;

#pragma mark - Network
+ (void)postJSONToURL:(NSString *)url
                 head:(nullable NSDictionary *)head
                 data:(NSDictionary *)data
              timeout:(NSUInteger)timeout
    completionHandler:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionHandler;

#pragma mark - Alert helpers
+ (void)presentAlertOn:(UIViewController *)vc
                 title:(NSString *)title
                fields:(NSArray<NSDictionary *> *)fields
               handler:(void (^)(NSArray<UITextField *> *textFields))handler;

@end

@interface UIViewController (BLDemoHelpers)

/// 展示 SDK 结果：成功 toast 自定义文案，失败展示 Code/Msg
- (void)showSDKResult:(BLBaseResult *)result successMessage:(nullable NSString *)successMessage;
- (void)showErrorCode:(NSInteger)code msg:(nullable NSString *)msg;

@end

NS_ASSUME_NONNULL_END
