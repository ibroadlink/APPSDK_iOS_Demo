//
//  BLProduct.h
//  BLLetCore
//
//  Created by zhujunjie on 2017/12/20.
//  Copyright © 2017年 朱俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLProduct : NSObject

/** Global Http timeout, default 30000ms */
@property (nonatomic, assign, getter=getHttpTimeout) NSUInteger httpTimeout;

/**
 Get family controller with global config
 
 @param configParam         Global config params
 @return                    Family controller Object
 */
+ (nullable instancetype)sharedWithConfigParam:(NSString *)licenseId;

/**
 Product Http Post Request
 
 @param urlPath url path without domain
 @param head request head
 @param body request body
 @param completionHandler return
 */
- (void)productHttpPost:(nonnull NSString *)urlPath head:(nullable NSDictionary *)head body:(nullable NSDictionary *)body completionHandler:(nonnull void (^)(NSData *__nonnull data, NSError *__nullable error))completionHandler;

@end
