//
//  BLFamilyHttpAccessor.m
//  Let
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLFamilyHttpAccessor.h"

#import "BLApiUrls.h"
#import "BLCommonTools.h"
#import "BLConfigParam.h"

#define UPDATA_ICON_MAXLIMIT            (2014 * 512)
#define UPDATA_KEY_TIMEINTERVAL         (2 * 60 * 60)
#define FAMILY_TOKEN_KEY                @"xgx3d*fe3478$ukx"

@interface BLFamilyHttpAccessor ()

@property (nonatomic, strong)NSData *nowKey;
@property (nonatomic, assign)NSTimeInterval lastTimeInterval;

@end

@implementation BLFamilyHttpAccessor

+ (instancetype)sharedAccessor
{
    static dispatch_once_t onceToken;
    static BLFamilyHttpAccessor *familyAccessor = nil;
    dispatch_once(&onceToken, ^{
        familyAccessor = [[BLFamilyHttpAccessor alloc] init];
    });
    
    return familyAccessor;
}

- (void)generatePost:(NSString *)url
                head:(NSDictionary *)head
                data:(NSDictionary *)data
             timeout:(NSUInteger)timeout
   completionHandler:(void (^)(NSData * data, NSError * error))completionHandler
{
    [self checkLockKeyIsVaildWithcompletionHandler:^(NSData *keyData, NSError *keyError) {
        if (keyError) {
            completionHandler(nil, keyError);
        } else {
            NSData *postData = [BLCommonTools aes128NoPadding:[BLCommonTools serializeMessage:data] key:self.nowKey];
            NSDictionary *headDic = [self generateHttpHeadDicWithBodyStr:[BLCommonTools serializeMessage:data] head:head];
            
            [self post:url head:headDic data:postData timeout:timeout completionHandler:completionHandler];
        }
    }];
}

- (NSData *)generalPost:(NSString *)url
                head:(NSDictionary *)head
                data:(NSDictionary *)data
             timeout:(NSUInteger)timeout
   error:(NSError *__autoreleasing  _Nullable *)err
{
    NSData *postData = [BLCommonTools aes128NoPadding:[BLCommonTools serializeMessage:data] key:self.nowKey];
    NSDictionary *headDic = [self generateHttpHeadDicWithBodyStr:[BLCommonTools serializeMessage:data] head:head];
    return [self post:url head:headDic data:postData timeout:timeout error:err];
}

- (void)generateMultipartPost:(NSString *)url
                         head:(NSDictionary *)head
                         data:(NSDictionary *)data
                        image:(UIImage *)image
                      timeout:(NSUInteger)timeout
            completionHandler:(void (^)(NSData * data, NSError * error))completionHandler
{
    [self checkLockKeyIsVaildWithcompletionHandler:^(NSData *keyData, NSError *keyError) {
        if (keyError) {
            completionHandler(keyData, keyError);
        } else {
            NSData *postData = [BLCommonTools aes128NoPadding:[BLCommonTools serializeMessage:data] key:self.nowKey];
            NSDictionary *headDic = [self generateHttpHeadDicWithBodyStr:[BLCommonTools serializeMessage:data] head:head];
            
            NSData *postData2;
            if (image) {
                postData2 = [BLCommonTools convertToDataWithimage:image MaxLimit:@(UPDATA_ICON_MAXLIMIT)];
            }
            
            NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:2];
            if (postData) {
                [postDic setObject:postData forKey:@"text"];
            }
            if (postData2) {
                [postDic setObject:postData2 forKey:@"picdata"];
            }
            
            [self multipartPost:url head:headDic data:postDic timeout:timeout completionHandler:completionHandler];
        }
    }];
}

#pragma mark -
//生成HTTP头
- (NSDictionary *)generateHttpHeadDicWithBodyStr:(NSString *)bodyStr head:(NSDictionary *)head
{
    NSString *userid = [BLConfigParam sharedConfigParam].userid;
    NSString *token = [NSString stringWithFormat:@"%@%@%ld%@", bodyStr, FAMILY_TOKEN_KEY, (long)self.lastTimeInterval, userid];
    token = [[BLCommonTools md5:token] lowercaseString];
    
    NSMutableDictionary *headDic;
    if ([BLCommonTools isEmptyDic:head]) {
        headDic = [NSMutableDictionary dictionaryWithCapacity:0];
    } else {
        headDic = [[NSMutableDictionary alloc] initWithDictionary:head];
    }
    
    [headDic setValue:[NSString stringWithFormat:@"%ld", (long)self.lastTimeInterval] forKey:@"timestamp"];
    [headDic setValue:[BLCommonTools convertNullOrNil:token] forKey:@"token"];
    
    return headDic;
}

//判断是否需要更新家庭HTTP key, 2小时更新一次
- (void)checkLockKeyIsVaildWithcompletionHandler:(void (^)(NSData *keyData, NSError *keyError))completionHandler
{
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (self.nowKey && (nowTimeInterval - self.lastTimeInterval < UPDATA_KEY_TIMEINTERVAL)) {
        completionHandler(nil, nil);
    } else {
        BLBaseHttpAccessor *baseAccessor = [[BLBaseHttpAccessor alloc] init];
        NSString *url = [[BLApiUrls sharedApiUrl] familyTimestrampAndKeyUrl];
        
        [baseAccessor get:url head:nil timeout:30000 completionHandler:^(NSData * data, NSError * error) {
            if (error) {
                completionHandler(nil, error);
            } else {
                NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                NSInteger status = [[dataJson objectForKey:@"error"] integerValue];
                if (status == 0) {
                    if ([dataJson objectForKey:@"timestamp"]) {
                        self.lastTimeInterval = [[dataJson objectForKey:@"timestamp"] longLongValue];
                    }
                    if ([dataJson objectForKey:@"key"]) {
                        self.nowKey = [BLCommonTools hexString2Bytes:[dataJson objectForKey:@"key"]];
                    }
                    
                    completionHandler(data, nil);
                } else {
                    NSString *domain = @"com.broadlink.appsdk.family";
                    NSString *msg = [dataJson objectForKey:@"msg"];
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
                    NSError *aError = [NSError errorWithDomain:domain code:status userInfo:userInfo];
                    completionHandler(data, aError);
                }
                
            }
        }];
    }
}

@end
