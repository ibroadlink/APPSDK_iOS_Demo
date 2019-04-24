//
//  BLSMediator.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/4/24.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BLSMediator : NSObject

+ (instancetype)shared;

- (id)performActionWithURL:(NSURL *)url completion:(void(^)(NSDictionary *info))completion;
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;
- (void)releaseCachedTargetWithTargetName:(NSString *)targetName;

@end
