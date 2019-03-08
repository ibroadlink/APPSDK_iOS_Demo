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
- (void)setAllPushState:(BOOL)state;

@end

NS_ASSUME_NONNULL_END
