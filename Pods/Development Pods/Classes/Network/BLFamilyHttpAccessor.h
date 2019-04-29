//
//  BLFamilyHttpAccessor.h
//  Let
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BLBaseHttpAccessor.h"

@interface BLFamilyHttpAccessor : BLBaseHttpAccessor

+ (nonnull instancetype)sharedAccessor;

/**
 *  家庭相关接口同步POST请求
 *
 *  @param url               HTTP链接地址
 *  @param head              HTTP header
 *  @param data              请求数据
 *  @param timeout           超时时间
 *  @param err               请求错误
 */
- (NSData *_Nullable)generalPost:(NSString *_Nullable)url head:(NSDictionary *_Nullable)head data:(NSDictionary *_Nullable)data timeout:(NSUInteger)timeout error:(NSError *__autoreleasing  _Nullable *_Nullable)err;

/**
 *  家庭相关接口异步POST请求
 *
 *  @param url               HTTP链接地址
 *  @param head              HTTP header
 *  @param data              请求数据
 *  @param timeout           超时时间
 *  @param completionHandler 请求结果
 */
- (void)generatePost:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSDictionary *)data timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;


/**
 家庭相关multipart方式异步POST上传文件内容

 @param url HTTP地址
 @param head HTTP请求头
 @param data 文字部分
 @param image 图片部分
 @param timeout 超时时间
 @param completionHandler 请求结果
 */
- (void)generateMultipartPost:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSDictionary *)data image:(nullable UIImage *)image timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;

@end
