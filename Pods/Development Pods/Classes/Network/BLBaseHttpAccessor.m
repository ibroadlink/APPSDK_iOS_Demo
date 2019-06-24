//
//  BaseHttpAccessor.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLBaseHttpAccessor.h"
#import "BLLog.h"
#import "BLCommonTools.h"
#import "BLConstants.h"
#import "BLConstantInner.h"
#import "BLTokenBurst.h"
#import "BLConfigParam.h"

@implementation BLBaseHttpAccessor

- (void)addCommondHeadToRequest:(NSMutableURLRequest *)request {
    if (!request) {
        return;
    }
    long nowTime = (long) [[NSDate date] timeIntervalSince1970];
    NSString *system = @"iOS";
    NSString *appPlatform = @"iOS";
    NSString *language = [BLCommonTools getCurrentLanguage];
    NSString *lid = [BLConfigParam sharedConfigParam].licenseId;
    NSString *userid = [BLConfigParam sharedConfigParam].userid;
    NSString *session = [BLConfigParam sharedConfigParam].loginSession;
    NSString *familyid = [BLConfigParam sharedConfigParam].familyId;

    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    [request addValue:[NSString stringWithFormat:@"%ld", nowTime] forHTTPHeaderField:@"timestamp"];
    [request addValue:system forHTTPHeaderField:@"system"];
    [request addValue:appPlatform forHTTPHeaderField:@"appPlatform"];
    [request addValue:language forHTTPHeaderField:@"language"];
    [request addValue:appVersion forHTTPHeaderField:@"appVersion"];
    
    if (lid) {
        [request addValue:lid forHTTPHeaderField:@"licenseid"];
        [request addValue:lid forHTTPHeaderField:@"lid"];
    }
    
    if (userid) {
        [request addValue:userid forHTTPHeaderField:@"userid"];
    }
    
    if (session) {
        [request addValue:session forHTTPHeaderField:@"loginsession"];
    }
    
    if (familyid) {
        [request addValue:familyid forHTTPHeaderField:@"familyid"];
    }
}

- (NSData *)get:(NSString *)url head:(NSDictionary *)head timeout:(NSUInteger)timeout error:(NSError *__autoreleasing  _Nullable *)err
{
    BLLogDebug(@"Http Method:GET Url:%@", url);
    
    NSURL *httpUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpUrl];
    
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:timeout/1000];
    [self addCommondHeadToRequest:request];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    if (head != nil) {
        for (NSString *key in head) {
            [request setValue:[head valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:err];
}

- (NSData *)post:(NSString *)url head:(NSDictionary *)head data:(NSData *)data timeout:(NSUInteger)timeout error:(NSError *__autoreleasing  _Nullable *)err
{
    BLLogDebug(@"Http Method:POSt Url:%@", url);
    
    NSURL *httpUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpUrl];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:timeout/1000];
    [self addCommondHeadToRequest:request];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    if (head != nil) {
        for (NSString *key in head) {
            [request setValue:[head valueForKey:key] forHTTPHeaderField:key];
        }
    }
    [request setHTTPBody:data];
    
    return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:err];
}

- (NSData *)multipartPost:(NSString *)url head:(NSDictionary *)head data:(NSDictionary *)data timeout:(NSUInteger)timeout error:(NSError *__autoreleasing  _Nullable *)err
{
    BLLogDebug(@"Http Method:multipartPost Url:%@", url);

    NSURL *httpUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpUrl];
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *boundary = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    NSMutableData *postData = [[NSMutableData alloc] init];
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:timeout/1000];
    [self addCommondHeadToRequest:request];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
    [request addValue:@"utf-8" forHTTPHeaderField:@"Charset"];
    
    if (head != nil) {
        for (NSString *key in [head allKeys]) {
            [request setValue:[head valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    for (NSString *key in data) {
        id value = [data valueForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\nContent-Type: text/plain\r\n\r\n", boundary, key];
            [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        } else if ([value isKindOfClass:[NSData class]]) {
            NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"UTF-8\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key];
            [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:value];
        } else if ([value isKindOfClass:[NSFileWrapper class]]) {
            NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key, [value filename]];
            [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[value regularFileContents]];
        }
        [postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString *pair = [NSString stringWithFormat:@"--%@--\r\n\r\n", boundary];
    [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:err];
}

- (void)get:(nonnull NSString *)url head:(nullable NSDictionary *)head timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler
{
    BLLogDebug(@"Http Method:GET Url:%@", url);
    
    NSURL *httpUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDataTask * dataTask;
    
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:timeout/1000];
    [self addCommondHeadToRequest:request];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if (head != nil) {
        for (NSString *key in head) {
            [request setValue:[head valueForKey:key] forHTTPHeaderField:key];
        }
    }
    dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            BLLogDebug(@"Http Get Return: %@", text);
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSInteger statusCode = [httpResponse statusCode];
            BLLogDebug(@"HTTP Response Status Code : %ld", (long)statusCode);
            
            if (statusCode >= 200 && statusCode <= 299) {
                completionHandler(data, error);
            } else {
                NSDictionary *resulrDic = @{
                                            @"error":@(BL_APPSDK_ERR_UNKNOWN),
                                            @"msg":[NSString stringWithFormat:@"HTTP Response Status Code : %ld", (long)statusCode]
                                            };
                NSData *resultData = [NSJSONSerialization dataWithJSONObject:resulrDic options:0 error:nil];
                completionHandler(resultData, error);
            }
            
        } else {
            BLLogError(@"Http server has no return");
            NSDictionary *resulrDic = @{
                                        @"error":@(BL_APPSDK_SERVER_NO_RESULT_ERR),
                                        @"msg":kErrorMsgServerReturn
                                        };
            NSData *resultData = [NSJSONSerialization dataWithJSONObject:resulrDic options:0 error:nil];
            completionHandler(resultData, error);
        }
    }];
    
    [dataTask resume];
}

- (void)post:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSData *)data timeout:(NSUInteger)timeout completionHandler:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler
{
    BLLogDebug(@"Http Method:POST Url:%@", url);
    
    NSURL *httpUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDataTask *dataTask;
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:timeout/1000];
    [self addCommondHeadToRequest:request];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if (head != nil) {
        for (NSString *key in head) {
            [request setValue:[head valueForKey:key] forHTTPHeaderField:key];
        }
    }
    [request setHTTPBody:data];
    
    dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            BLLogDebug(@"Http Post Return: %@", text);
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSInteger statusCode = [httpResponse statusCode];
            BLLogDebug(@"HTTP Response Status Code : %ld", (long)statusCode);
            
            if (statusCode >= 200 && statusCode <= 299) {
                completionHandler(data, error);
            } else {
                NSDictionary *resulrDic = @{
                                            @"error":@(BL_APPSDK_ERR_UNKNOWN),
                                            @"msg":[NSString stringWithFormat:@"HTTP Response Status Code : %ld", (long)statusCode]
                                            };
                NSData *resultData = [NSJSONSerialization dataWithJSONObject:resulrDic options:0 error:nil];
                completionHandler(resultData, error);
            }
        } else {
            BLLogError(@"Http server has no return");
            NSDictionary *resulrDic = @{
                                        @"error":@(BL_APPSDK_SERVER_NO_RESULT_ERR),
                                        @"msg":kErrorMsgServerReturn
                                        };
            NSData *resultData = [NSJSONSerialization dataWithJSONObject:resulrDic options:0 error:nil];
            completionHandler(resultData, error);
        }

    }];
    [dataTask resume];
}

- (void)multipartPost:(NSString *)url head:(NSDictionary *)head data:(NSDictionary *)data timeout:(NSUInteger)timeout completionHandler:(void (^)(NSData * _Nullable, NSError * _Nullable))completionHandler
{
    BLLogDebug(@"Http Method:multipartPost Url:%@", url);
    
    NSURL *httpUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDataTask *dataTask;
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *boundary = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    NSMutableData *postData = [[NSMutableData alloc] init];
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:timeout/1000];
    [self addCommondHeadToRequest:request];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
    [request addValue:@"utf-8" forHTTPHeaderField:@"Charset"];
    
    if (head != nil) {
        for (NSString *key in [head allKeys]) {
            [request setValue:[head valueForKey:key] forHTTPHeaderField:key];
        }
    }

    for (NSString *key in data) {
        id value = [data objectForKey:key];
        
        if ([value isKindOfClass:[NSString class]]) {
            NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\nContent-Type: text/plain\r\n\r\n", boundary, key];
            [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        } else if ([value isKindOfClass:[NSData class]]) {
            NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"UTF-8\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key];
            [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:value];
        } else if ([value isKindOfClass:[NSFileWrapper class]]) {
            NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key, [value filename]];
            [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[value regularFileContents]];
        }
        [postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString *pair = [NSString stringWithFormat:@"--%@--\r\n\r\n", boundary];
    [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            BLLogDebug(@"Http Post Return: %@", text);
            
            //如果服务器返回json不标准，返回-3001
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([BLCommonTools isEmptyDic:dataDic]) {
                NSDictionary *resulrDic = @{
                                            @"error":@(BL_APPSDK_ERR_UNKNOWN),
                                            @"msg":[NSString stringWithFormat:@"HTTP Response Json is not standard"]
                                            };
                NSData *resultData = [NSJSONSerialization dataWithJSONObject:resulrDic options:0 error:nil];
                completionHandler(resultData, error);
                return ;
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSInteger statusCode = [httpResponse statusCode];
            BLLogDebug(@"HTTP Response Status Code : %ld", (long)statusCode);
            
            if (statusCode >= 200 && statusCode <= 299) {
                completionHandler(data, error);
            } else {
                NSDictionary *resulrDic = @{
                                            @"error":@(BL_APPSDK_ERR_UNKNOWN),
                                            @"msg":[NSString stringWithFormat:@"HTTP Response Status Code : %ld", (long)statusCode]
                                            };
                NSData *resultData = [NSJSONSerialization dataWithJSONObject:resulrDic options:0 error:nil];
                completionHandler(resultData, error);
            }
        } else {
            BLLogError(@"Http server has no return");
            NSDictionary *resulrDic = @{
                                        @"error":@(BL_APPSDK_SERVER_NO_RESULT_ERR),
                                        @"msg":kErrorMsgServerReturn
                                        };
            NSData *resultData = [NSJSONSerialization dataWithJSONObject:resulrDic options:0 error:nil];
            completionHandler(resultData, error);
        }
    }];
    [dataTask resume];
}

- (void)download:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSData *)data timeout:(NSUInteger)timeout savePath:(nonnull NSString *)savePath completionHandler:(nullable void (^)(NSError * __nullable error, NSString * __nullable path))completionHandler
{
    BLLogDebug(@"Http Method:download Url:%@", url);

    NSURL *httpUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpUrl];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:timeout/1000];
    [self addCommondHeadToRequest:request];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if (head != nil) {
        for (NSString *key in head) {
            [request setValue:[head valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    if (data) {
        BLLogDebug(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [request setHTTPBody:data];
    }
    
    NSURLSessionDownloadTask *dataTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            BLLogDebug(@" %@ ", response);
            if (!error) {
                NSString *path = savePath;
                if ([response isKindOfClass:[NSURLResponse class]]) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    
                    NSInteger statusCode = [httpResponse statusCode];
                    BLLogDebug(@"HTTP Response Status Code : %ld", (long)statusCode);
                    
                    if (!(statusCode >= 200 && statusCode <= 299)) {
                        NSDictionary *resulrDic = @{
                                                    @"error":@(BL_APPSDK_ERR_UNKNOWN),
                                                    @"msg":[NSString stringWithFormat:@"HTTP Response Status Code : %ld", (long)statusCode]
                                                    };
                        NSError *err = [[NSError alloc] initWithDomain:@"Download Fail" code:statusCode userInfo:resulrDic];
                        completionHandler(err ,nil);
                        return;
                    }
                    
                    NSString *resourceType = [httpResponse.allHeaderFields objectForKey:@"Resourcetype"];
                    if (resourceType) {
                        if ([resourceType isEqualToString:@"lua"]) {
                            path = [path stringByAppendingString:@".script"];
                        } else if ([resourceType isEqualToString:@"js"]) {
                            path = [path stringByAppendingString:@".js"];
                        }
                    }
                }
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *sPath = [savePath stringByDeletingLastPathComponent];
                BOOL isDir;
                
                if ([fileManager fileExistsAtPath:sPath isDirectory:&isDir] == NO) {
                    if (![fileManager createDirectoryAtPath:sPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                        completionHandler(error, nil);
                        return;
                    }
                } else {
                    if (!isDir) {
                        NSError *err = [[NSError alloc] initWithDomain:@"SavePath not a directory" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"SavePath not a directory, please check it.", nil]];
                        completionHandler(err, nil);
                        return;
                    }
                    
                    NSURL *saveUrl = [NSURL fileURLWithPath:path];
                    NSError *err = nil;
                    
                    // file is exist, delete it
                    if ([fileManager fileExistsAtPath:path]) {
                        [fileManager removeItemAtPath:path error:nil];
                    }
                    
                    if (![fileManager moveItemAtURL:location toURL:saveUrl error:&err]) {
                        completionHandler(err, nil);
                        return;
                    }
                    
                    BLLogDebug(@"download file path: %@", path);
                    completionHandler(nil, path);
                    
                    return;
                }
            }
            
            completionHandler(error, nil);
        }];
    [dataTask resume];
}

- (void)upload:(nonnull NSString *)url head:(nullable NSDictionary *)head data:(nonnull NSData *)data timeout:(NSUInteger)timeout filePath:(nonnull NSString *)filePath completionHandler:(nullable void (^)(NSData *__nullable result, NSError * __nullable error))completionHandler
{
    BLLogDebug(@"Http Method:upload Url:%@", url);
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    NSURL *httpUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionUploadTask *dataTask;
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:timeout/1000];
    [self addCommondHeadToRequest:request];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if (head != nil) {
        for (NSString *key in head) {
            [request setValue:[head valueForKey:key] forHTTPHeaderField:key];
        }
    }
    [request setHTTPBody:data];
    
    dataTask = [session uploadTaskWithRequest:request fromFile:fileUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            BLLogDebug(@"Http Post Return: %@", text);
            completionHandler(data, error);
        } else {
            BLLogError(@"Http server has no return");
            NSDictionary *resulrDic = @{
                                        @"error":@(BL_APPSDK_SERVER_NO_RESULT_ERR),
                                        @"msg":kErrorMsgServerReturn
                                        };
            NSData *resultData = [NSJSONSerialization dataWithJSONObject:resulrDic options:0 error:nil];
            completionHandler(resultData, error);
        }
    }];
    
    [dataTask resume];
}

- (NSError *)httpSendError {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:kErrorMsgRequestFast forKey:NSLocalizedDescriptionKey];
    NSError *aError = [NSError errorWithDomain:@"cn.com.broadlink" code:BL_APPSDK_HTTP_TOO_FAST_ERR userInfo:userInfo];
    return aError;
}

-(NSError *) judgeError:(NSString *)path{
    NSError *err;
    
    //解析出错，说明是正确的zip包，否则是{"code":xxx,"msg":"xxxx"}的错误提示
    NSString *s = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (err != nil){
        return nil;
    }
    
    NSDictionary *ndic = [NSJSONSerialization JSONObjectWithData:
                          [s dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];
    if (err == nil){
        if ([ndic[@"code"] intValue] != 0){
            err = [NSError errorWithDomain:@"cn.com.broadlink" code:[ndic[@"code"] intValue] userInfo:@{NSLocalizedDescriptionKey:ndic[@"msg"]}];
            return err;
        }
    }
    return nil;
}

// 收到身份验证
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSURLProtectionSpace *space = [challenge protectionSpace];
    NSString *host = space.host;
    NSLog(@"host:%@,",host);
    
    BOOL receivesCredentialSecurely = space.receivesCredentialSecurely;
    NSLog(@"iScreadentialSecurely:%@",@(receivesCredentialSecurely));
    
    NSString *authenticationMethod = space.authenticationMethod;
    NSLog(@"authenticationMethod:%@",authenticationMethod);
    
    NSString *protocol = space.protocol;
    NSLog(@"protocol:%@",protocol);
    
    NSInteger port = space.port;
    NSLog(@"port:%@",@(port));
    
    SecTrustRef trus = space.serverTrust;
    NSLog(@"trus:%@",trus);
    
    if ([BLConfigParam sharedConfigParam].ClientCertificate == nil || [BLConfigParam sharedConfigParam].ServerCertificate == nil) {
        
        completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
    }else {
        // 认证方法：客户端认证
        if ([authenticationMethod isEqualToString:@"NSURLAuthenticationMethodClientCertificate"] ) {
            //        NSString *p12Path = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
            //        NSData * p12Data = [NSData dataWithContentsOfFile:p12Path];
            
            [self authClientCerData:[BLConfigParam sharedConfigParam].ClientCertificate cerPass:[BLConfigParam sharedConfigParam].cerPass space:space success:^(NSURLCredential *credential) {
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            } failure:^(NSString *errorMsg) {
                // 验证失败
                NSLog(@"errorMsg = %@",errorMsg);
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
            }];
            //验证服务器证书
        } else if([authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
            
            //        NSString *path = [[NSBundle mainBundle] pathForResource:@"server_client.cer" ofType:nil];
            //        NSData *cerData = [[NSData alloc] initWithContentsOfFile:path];
            [self authServerCerData:[BLConfigParam sharedConfigParam].ServerCertificate space:space success:^{
                // 验证成功
                NSURLCredential *credential = [NSURLCredential credentialForTrust:space.serverTrust];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            } failure:^(NSString *errorMsg) {
                // 验证失败
                NSLog(@"errorMsg = %@",errorMsg);
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
            }];
        } else {
            // 其他服务器连接取消连接
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
        }
    }
    
    
}


// 认证服务器证书
-(void)authServerCerData:(NSData *)cerData space:(NSURLProtectionSpace *)space success:(void(^)(void))success failure:(void(^)(NSString *errorMsg))failure {
    if(![space.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        if (failure) {
            failure([[NSString alloc] initWithFormat:@"服务器认证方法不为'NSURLAuthenticationMethodServerTrust',authenticationMethod='%@'",space.authenticationMethod]);
        }
        
        return;
    }
    SecTrustRef serverTrust = space.serverTrust;
    if(serverTrust == nil) {
        if (failure) {
            failure(@"space.serverTurst == nil");
        }
        
        return;
    }
    
    // 读取证书
    if (cerData == nil) {
        if (failure) {
            failure(@"证书数据为空");
        }
        
        return;
    }
    
    SecCertificateRef cerRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)cerData);
    if(cerRef == nil) {
        if (failure) {
            failure(@"不能读取证书信息,请检查证书名称");
        }
        
        return;
    }
    
    NSArray *caArray = @[(__bridge id)cerRef];
    //将读取的证书设置为服务端帧数的根证书
    OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
    if(!(status == errSecSuccess)) {
        if (failure) {
            failure([[NSString alloc] initWithFormat:@"设置为服务端帧数的根证书失败,status=%@",@(status)]);
        }
        
        return;
    }
    
    SecTrustResultType result = -1;
    //验证服务器的证书是否可信(有可能通过联网验证证书颁发机构)
    status = SecTrustEvaluate(serverTrust, &result);
    if(!(status == errSecSuccess)) {
        if (failure) {
            failure([[NSString alloc] initWithFormat:@"服务器证书验证失败,status=%@",@(status)]);
        }
        
        return;
    }
    // result返回结果,是否信任
    BOOL allowConnect = ((result == kSecTrustResultUnspecified) || (result == kSecTrustResultProceed));
    if(!allowConnect) {
        if (failure) {
            failure(@"不是信任的连接");
        }
        
        return;
    }
    // 全部通过验证
    if (success) {
        success();
    }
}

// 服务器认证客户端证书
-(void)authClientCerData:(NSData *)cerData cerPass:(NSString *)pass space:(NSURLProtectionSpace *)space success:(void(^)(NSURLCredential *credential))success failure:(void(^)(NSString *errorMsg))failure {
    if(![space.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodClientCertificate"]) {
        failure([[NSString alloc] initWithFormat:@"服务器认证方法不为'NSURLAuthenticationMethodClientCertificate',authenticationMethod='%@'",space.authenticationMethod]);
        return;
    }
    
    // 读取证书
    if (cerData == nil) {
        if (failure) {
            failure(@"证书数据为空");
        }
        
        return;
    }
    
    CFDataRef inPKCS12Data = (__bridge CFDataRef)cerData;
    
    SecIdentityRef identity = NULL;
    
    OSStatus status = [self extractIdentity:inPKCS12Data identity:&identity pass:pass];
    if(status != 0 || identity == NULL) {
        if(failure) {
            failure([[NSString alloc] initWithFormat:@"提取身份失败,status=%@",@(status)]);
        }
        return;
        
    }
    
    SecCertificateRef certificate = NULL;
    SecIdentityCopyCertificate (identity, &certificate);
    const void *certs[] = {certificate};
    CFArrayRef arrayOfCerts = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
    
    // NSURLCredentialPersistenceForSession:创建URL证书,在会话期间有效
    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray*)arrayOfCerts persistence:NSURLCredentialPersistenceForSession];
    if (success) {
        success(credential);
    }
    
    if(certificate) {
        CFRelease(certificate);
    }
    
    if (arrayOfCerts) {
        CFRelease(arrayOfCerts);
        
    }
    return;
}

// 提取身份identity
- (OSStatus)extractIdentity:(CFDataRef)inP12Data identity:(SecIdentityRef*)identity pass:(NSString *)pass {
    
    CFStringRef password = (__bridge CFStringRef)(pass);//证书密码
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import(inP12Data, options, &items);
    if (securityError == 0)
    {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}


@end
