//
//  BLSNotificationService.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/7.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLSNotificationService : NSObject

@property (nonatomic, copy) NSString *deviceToken;

+ (BLSNotificationService *)sharedInstance;
- (void)registerDevice;
- (void)registerDeviceCompletionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler;
- (void)setAllPushState:(BOOL)state;
- (void)setAllPushState:(BOOL)state completionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler;
- (void)userLogout;
- (void)userLogoutCompletionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler;
- (void)queryCategory:(NSArray *)category TemplateWithCompletionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler;
- (void)queryLinkageInfoWithCompletionHandler:(void (^)(NSString *result))completionHandler;
@end

NS_ASSUME_NONNULL_END
