//
//  AccountHttpAccessor.m
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLAccountHttpAccessor.h"

@interface BLAccountHttpAccessor ()

/**
 *  Body加密salt
 */
@property (nonatomic, strong, readonly) NSString *accountBodyEncrypt;

/**
 *  Token加密salt
 */
@property (nonatomic, strong, readonly) NSString *accountTokenEncrypt;

@end

@implementation BLAccountHttpAccessor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _accountBodyEncrypt = @"xgx3d*fe3478$ukx";
        _accountTokenEncrypt = @"kdixkdqp54545^#*";
    }
    
    return self;
}

- (void)generalPost:(NSString *)url dataStr:(NSString *)dataStr timeout:(NSUInteger)timeout completionHandler:(void (^)(NSData * _Nullable, NSError * _Nullable))completionHandler
{
    return [self generalPost:url head:nil dataStr:dataStr timeout:timeout completionHandler:completionHandler];
}

- (void)generalPost:(NSString *)url head:(NSDictionary *)head dataStr:(NSString *)dataStr timeout:(NSUInteger)timeout completionHandler:(void (^)(NSData * _Nullable, NSError * _Nullable))completionHandler
{
    NSString *timestamp = [NSString stringWithFormat:@"%ld", time(NULL)];
    NSString *key = [BLCommonTools md5:[timestamp stringByAppendingString:self.accountTokenEncrypt]];
    NSString *token = [BLCommonTools md5:[dataStr stringByAppendingString:self.accountBodyEncrypt]];
    NSMutableDictionary *httpHead = [NSMutableDictionary dictionaryWithObjectsAndKeys:timestamp, @"timestamp", token, @"token", nil];
    
    if (![head isEqual:nil]) {
        for (NSString *key in [head allKeys]) {
            [httpHead setValue:[head valueForKey:key] forKey:key];
        }
    }
    
    BLLogDebug(@"Json Param: %@", dataStr);
    
    NSData *data = [BLCommonTools aes128NoPadding:dataStr key:[BLCommonTools hexString2Bytes:key]];
    
    return [self post:url head:httpHead data:data timeout:timeout completionHandler:completionHandler];
}

- (void)generalMultipartPost:(nonnull NSString *)url head:(nullable NSDictionary *)head dataStr:(nonnull NSString *)dataStr filePath:(nonnull NSString *)filePath timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData *__nullable data, NSError *__nullable error))completionHandler
{
    NSString *timestamp = [NSString stringWithFormat:@"%ld", time(NULL)];
    NSString *key = [BLCommonTools md5:[timestamp stringByAppendingString:self.accountTokenEncrypt]];
    NSString *token = [BLCommonTools md5:[dataStr stringByAppendingString:self.accountBodyEncrypt]];
    NSMutableDictionary *httpHead = [NSMutableDictionary dictionaryWithObjectsAndKeys:timestamp, @"timestamp", token, @"token", nil];
    
    if (![head isEqual:nil]) {
        for (NSString *key in [head allKeys]) {
            [httpHead setValue:[head valueForKey:key] forKey:key];
        }
    }
    
    BLLogDebug(@"Json Param: %@", dataStr);
    
    NSError *err = nil;
    NSData *data = [BLCommonTools aes128NoPadding:dataStr key:[BLCommonTools hexString2Bytes:key]];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    
    [dataDic setObject:data forKey:@"text"];
    
    if (filePath && ![filePath isEqualToString:@""]) {
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        NSFileWrapper *warpper = [[NSFileWrapper alloc] initWithURL:fileUrl options:NSFileWrapperReadingImmediate error:&err];
        if (err) {
            completionHandler(nil, err);
            return;
        }
        
        [dataDic setObject:warpper forKey:@"picdata"];
    }
    
    return [self multipartPost:url head:httpHead data:dataDic timeout:timeout completionHandler:completionHandler];
}

@end
