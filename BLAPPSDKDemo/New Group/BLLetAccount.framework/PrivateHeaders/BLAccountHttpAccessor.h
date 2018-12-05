//
//  AccountHttpAccessor.h
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLAccountHttpAccessor : BLBaseHttpAccessor

/**
*  帐号系统异步POST请求
*
*  @param url               HTTP链接地址
*  @param dataStr           请求数据
*  @param timeout           超时时间
*  @param completionHandler 请求结果
*/
- (void)generalPost:(nonnull NSString *)url dataStr:(nonnull NSString *)dataStr timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;

/**
 *  帐号系统异步POST请求
 *
 *  @param url               HTTP链接地址
 *  @param head              HTTP header
 *  @param dataStr           请求数据
 *  @param timeout           超时时间
 *  @param completionHandler 请求结果
 */
- (void)generalPost:(nonnull NSString *)url head:(nullable NSDictionary *)head dataStr:(nonnull NSString *)dataStr timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;

/**
 *  帐号系统异步上传文件 <上传用户头像>
 *
 *  @param url               HTTP链接地址
 *  @param head              HTTP header
 *  @param dataStr           请求数据
 *  @param filePath          文件路径
 *  @param timeout           超时时间
 *  @param completionHandler 请求结果
 */
- (void)generalMultipartPost:(nonnull NSString *)url head:(nullable NSDictionary *)head dataStr:(nonnull NSString *)dataStr filePath:(nonnull NSString *)filePath timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData *__nullable data, NSError *__nullable error))completionHandler;

@end
