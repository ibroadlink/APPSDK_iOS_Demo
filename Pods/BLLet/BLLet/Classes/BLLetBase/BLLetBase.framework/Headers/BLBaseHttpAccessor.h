//
//  BaseHttpAccessor.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLBaseHttpAccessor : NSObject

/**
 *  HTTP的同步GET操作
 *
 *  @param url     HTTP地址
 *  @param head    HTTP header
 *  @param timeout 超时时间
 *  @param err     若出错，则返回相应的错误信息
 *
 *  @return 返回结果
 */
- (nullable NSData *)get:(nonnull NSString *)url
                    head:(nullable NSDictionary *)head
                 timeout:(NSUInteger)timeout
                   error:( NSError * _Nullable __autoreleasing * _Nullable)err;

/**
 *  HTTP的同步POST操作
 *
 *  @param url     HTTP地址
 *  @param head    HTTP header
 *  @param data    POST数据
 *  @param timeout 超时时间
 *  @param err     若出错，则返回相应的错误信息
 *
 *  @return 返回结果
 */
- (nullable NSData *)post:(nonnull NSString *)url
                     head:(nullable NSDictionary *)head
                     data:(nonnull NSData *)data
                  timeout:(NSUInteger)timeout
                    error:( NSError * _Nullable __autoreleasing * _Nullable)err;

/**
 *  HTTP multipart方式同步POST上传文件操作
 *
 *  @param url     HTTP地址
 *  @param head    HTTP header
 *  @param data    上传数据内容
 *  @param timeout 超时时间
 *  @param err     若出错，则返回相应的错误信息
 *
 *  @return 返回结果
 */
- (nullable NSData *)multipartPost:(nonnull NSString *)url
                              head:(nullable NSDictionary *)head
                              data:(nonnull NSDictionary *)data
                           timeout:(NSUInteger)timeout
                             error:( NSError * _Nullable __autoreleasing * _Nullable)err;

/**
 *  Http的异步Get操作
 *
 *  @param url     HTTP地址
 *  @param head    HTTP header
 *  @param timeout 请求超时时间
 *  @param completionHandler 操作结果
 */
- (void)get:(nonnull NSString *)url head:(nullable NSDictionary *)head timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;

/**
 *  Http的异步POST操作
 *
 *  @param url               HTTP地址
 *  @param head              HTTP header
 *  @param data              请求数据
 *  @param timeout           超时时间
 *  @param completionHandler 操作结果
 */
- (void)post:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSData *)data timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;

/**
 *  multipart方式异步POST上传文件内容
 *
 *  @param url               HTTP地址
 *  @param head              HTTP header
 *  @param data              上传数据内容
 *  @param timeout           超时时间
 *  @param completionHandler 操作结果
 */
- (void)multipartPost:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSDictionary *)data timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData *__nullable result, NSError * __nullable error))completionHandler;

/**
 *  Http的异步POST方式下载文件
 *
 *  @param url               HTTP地址
 *  @param head              HTTP header
 *  @param data              请求数据
 *  @param timeout           超时时间
 *  @param savePath          下载文件存放目录绝对路径
 *  @param completionHandler 操作结果
 */
- (void)download:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSData *)data timeout:(NSUInteger)timeout savePath:(nonnull NSString *)savePath completionHandler:(nullable void (^)(NSError * __nullable error, NSString * __nullable path))completionHandler;

/**
 *  HTTP的异步POST方式上传文件
 *
 *  @param url               HTTP地址
 *  @param head              HTTP header
 *  @param data              请求数据
 *  @param timeout           超时时间
 *  @param filePath          上传文件的绝对路径
 *  @param completionHandler 操作结果
 */
- (void)upload:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSData *)data timeout:(NSUInteger)timeout filePath:(nonnull NSString *)filePath completionHandler:(nullable void (^)(NSData *__nullable result, NSError * __nullable error))completionHandler;

@end
