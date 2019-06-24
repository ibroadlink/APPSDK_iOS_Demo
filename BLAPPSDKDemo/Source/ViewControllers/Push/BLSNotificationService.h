//
//  BLSNotificationService.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/7.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>
#import "BLTemplate.h"
#import "BLLinkageTemplate.h"
NS_ASSUME_NONNULL_BEGIN

@interface BLSNotificationService : NSObject

@property (nonatomic, copy) NSString *deviceToken;

+ (BLSNotificationService *)sharedInstance;
- (void)registerDevice;
- (void)registerDeviceCompletionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler;
- (void)setAllPushState:(BOOL)state;
- (void)setAllPushState:(BOOL)state completionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler;
- (void)userLogoutCompletionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler;
- (void)queryCategory:(NSArray *)category TemplateWithCompletionHandler:(nullable void (^)(BLTemplate * _Nonnull template))completionHandler;
- (void)addLinkageWithTemplate:(BLTemplateElement *)template module:(NSDictionary *)module CompletionHandler:(void (^)(BLBaseResult *result))completionHandler;
- (void)queryLinkageInfoWithCompletionHandler:(void (^)(BLLinkageTemplate *linkageTemplate))completionHandler;
- (void)deleteLinkageInfoWithRuleid:(NSString *)ruleid CompletionHandler:(void (^)(BLBaseResult *result))completionHandler;
@end

NS_ASSUME_NONNULL_END
