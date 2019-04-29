//
//  CommonTools.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLCommonTools.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation BLCommonTools

+ (NSString*)getCurrentTimes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

+ (NSString *)getCurrentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString *preferredLang = [currentLanguage lowercaseString];
    if ([preferredLang containsString:@"hans"]) {
        preferredLang = @"zh-cn";
    } else if ([preferredLang containsString:@"hant"]) {
        preferredLang = @"zh-tw";
    }
    
    return preferredLang;
}

+ (NSData *)hexString2Bytes:(NSString *)hexStr
{
    const char *hex = [[hexStr lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    int length = (int)strlen(hex);
    int i;
    NSMutableData *result = [[NSMutableData alloc] init];
    
    if (length % 2) {
        NSLog(@"%@ not a valid hex string ,length = %d", hexStr, length);
        return nil;
    }
    
    for (i=0; i<length/2; i++) {
        unsigned int value;
        unsigned char bin;
        NSString *hexCharStr = [hexStr substringWithRange:NSMakeRange(i*2, 2)];
        NSScanner *scanner = [[NSScanner alloc] initWithString:[NSString stringWithFormat:@"0x%@", hexCharStr]];
        
        if (![scanner scanHexInt:&value]) {
            NSLog(@"hexStr: %@, i: %d", hexStr, i);
            NSLog(@"%@ not a valid hex char", hexCharStr);
            return nil;
        }
        
        bin = value & 0xff;
        
        [result appendBytes:&bin length:1];
    }
    
    return result;
}

+ (NSString *)data2hexString:(NSData *)data {
    int count = (int)data.length;
    const unsigned char* temp = (const unsigned char*)data.bytes;
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i = 0; i < count; i++)
        {
                [string appendFormat:@"%02x",*(temp+i)];
            }
    return string;
}

+ (Boolean)isEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailPredicate evaluateWithObject:email];
}

+ (Boolean)isPhoneNumber:(NSString *)number
{
    NSString *phoneRegex = @"^[0-9]\\d*$";
    NSPredicate *phonePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phonePredicate evaluateWithObject:number];
}

//伊莱克斯专用sha加密
//+ (NSString *)sha1:(NSString *)string
//{
//    NSString *sha256String = [BLCommonTools sha256:string];
//
//    int i;
//    const char *cstr = [sha256String cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:sha256String.length];
//    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
//    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
//
//    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
//
//    for (i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
//        [output appendFormat:@"%02x", digest[i]];
//    }
//
//    return output;
//}
//
//+ (NSString *)sha256:(NSString *)string
//{
//    int i;
//    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:string.length];
//    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
//    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
//
//    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
//
//    for (i=0; i<CC_SHA256_DIGEST_LENGTH; i++) {
//        [output appendFormat:@"%02x", digest[i]];
//    }
//
//    return output;
//}

+ (NSString *)sha1:(NSString *)string
{
    int i;
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

    for (i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

+ (NSString *)sha256:(NSString *)string
{
    int i;
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);

    for (i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

+ (NSString *)md5:(NSString *)string
{
    const char *cStr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSData *)aes128NoPadding:(NSString *)dataStr
{
    unsigned char iv[] = {
        0xea, 0xaa, 0xaa, 0x3a, 0xbb, 0x58, 0x62, 0xa2,
        0x19, 0x18, 0xb5, 0x77, 0x1d, 0x16, 0x15, 0xaa
    };
    
    unsigned char key[] = {
        0xac, 0xcf, 0x8b, 0x02, 0x76, 0x5c, 0x15, 0x13,
        0x3f, 0xe9, 0x9e, 0x23, 0x09, 0x76, 0x28, 0x34
    };
    
    return [self aes128NoPadding:dataStr key:[NSData dataWithBytes:key length:sizeof(key)] iv:[NSData dataWithBytes:iv length:sizeof(iv)]];
}

+ (NSData *)aes128NoPadding:(NSString *)dataStr key:(NSData *)key
{
    unsigned char iv[] = {
        0xea, 0xaa, 0xaa, 0x3a, 0xbb, 0x58, 0x62, 0xa2,
        0x19, 0x18, 0xb5, 0x77, 0x1d, 0x16, 0x15, 0xaa
    };
    
    return [self aes128NoPadding:dataStr key:key iv:[NSData dataWithBytes:iv length:sizeof(iv)]];
}

+ (NSData *)aes128NoPadding:(NSString *)dataStr key:(NSData *)key iv:(NSData *)iv
{
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    return [self aes128NoPaddingWithData:data key:key iv:iv];
}

+ (NSData *)aes128NoPaddingWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    const char zero[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    size_t numBytesCrypted = 0;
    NSUInteger dataLength = [data length];
    NSUInteger appending = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    NSMutableData *srcData = [NSMutableData dataWithData:data];
    [srcData appendBytes:zero length:appending];
    
    size_t bufferSize = srcData.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    if (NULL == buffer) {
        NSLog(@"aes128NoPadding malloc fail ...");
        return nil;
    }
    memset(buffer, 0, sizeof(buffer));
    
    CCCryptorStatus status = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 0x0000, [key bytes], kCCKeySizeAES128, [iv bytes], [srcData bytes], srcData.length, buffer, bufferSize, &numBytesCrypted);
    
    if (status != kCCSuccess) {
        free(buffer);
        return nil;
    }
    
    NSData *result = [NSData dataWithBytes:buffer length:numBytesCrypted];
    free(buffer);
    
    return result;
}

+ (NSData *)aes128DecryptData:(NSData *)data {
    unsigned char iv[] = {
        0xea, 0xaa, 0xaa, 0x3a, 0xbb, 0x58, 0x62, 0xa2,
        0x19, 0x18, 0xb5, 0x77, 0x1d, 0x16, 0x15, 0xaa
    };
    
    unsigned char key[] = {
        0xac, 0xcf, 0x8b, 0x02, 0x76, 0x5c, 0x15, 0x13,
        0x3f, 0xe9, 0x9e, 0x23, 0x09, 0x76, 0x28, 0x34
    };
    
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    memcpy(keyPtr, key, sizeof(keyPtr));
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    memcpy(ivPtr, iv, sizeof(ivPtr));
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytes:buffer length:numBytesCrypted];
        free(buffer);
        return resultData;
    }
    free(buffer);
    return nil;
}

+ (NSData *)aes128DecryptData:(NSData *)data WithKey:(uint8_t *)key iv:(uint8_t *)iv {
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    memcpy(keyPtr, key, sizeof(keyPtr));
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    memcpy(ivPtr, iv, sizeof(ivPtr));
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytes:buffer length:numBytesCrypted];
        free(buffer);
        return resultData;
    }
    free(buffer);
    return nil;
}

+ (BOOL)isNull:(id)object {
    if (object == nil || [object isEqual:[NSNull null]] || [object isKindOfClass:[NSNull class]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmpty:(NSString *)str {
    if ([BLCommonTools isNull:str]) {
        return YES;
    }
    
    if ([str isKindOfClass:[NSString class]] && str.length > 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isEmptyArray:(NSArray *)array {
    if ([BLCommonTools isNull:array]) {
        return YES;
    }
    
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0) {
        return NO;
    }else {
        return YES;
    }
}

+ (BOOL)isEmptyDic:(NSDictionary *)dic {
    if ([BLCommonTools isNull:dic]) {
        return YES;
    }
    
    if ([dic isKindOfClass:[NSDictionary class]] && [dic count] > 0) {
        return NO;
    }else {
        return YES;
    }
}

+ (NSString*)convertNullOrNil:(NSString*)str {
    if ([BLCommonTools isNull:str]) {
        return @"";
    }
    return str;
}

+ (NSString*)serializeMessage:(id)message {
    if (message) {
        NSError *error;
        NSString *ret = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:&error]
                                              encoding:NSUTF8StringEncoding];
        if (error) {
            NSLog(@"serializeMessage string : %@", message);
            NSLog(@"serializeMessage error : %@", [error localizedDescription]);
        } else {
            return ret;
        }
    }
    
    return nil;
}

+ (id)deserializeMessageJSON:(NSString*)messageJSON {
    if (messageJSON) {
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"deserializeMessageJSON string : %@", messageJSON);
            NSLog(@"deserializeMessageJSON error : %@ ", [error localizedDescription]);
            
            return nil;
        } else {
            return dic;
        }
    }
    return nil;
}

/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
+ (NSMutableDictionary *)getURLParameters:(NSString *)UrlStr {
    
    // 查找参数
    NSRange range = [UrlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [UrlStr substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}



+ (NSData *)convertToDataWithimage:(UIImage *)image MaxLimit:(NSNumber *)maxLimitDataSize isPng:(BOOL)ifPng{
    
    NSData *imageData;
    if (ifPng) {
        imageData = UIImagePNGRepresentation(image);
    }else {
        imageData = UIImageJPEGRepresentation(image, 0);
    }
    double   factor       = 1.0;
    double   adjustment   = 1.0 / sqrt(2.0);
    CGSize   size         = image.size;
    CGSize   currentSize  = size;
    UIImage *currentImage = image;
    
    while (imageData.length >= [maxLimitDataSize longLongValue]) {
        @autoreleasepool {
            factor      *= adjustment;
            currentSize  = CGSizeMake(roundf(size.width * factor), roundf(size.height * factor));
            currentImage = [self convertWithimage:currentImage Size: currentSize];
            if (ifPng) {
                imageData = UIImagePNGRepresentation(currentImage);
            }else {
                imageData = UIImageJPEGRepresentation(currentImage, 0);
            }
        }
    }
    return imageData;
}

+ (NSData *)convertToDataWithimage:(UIImage *)image MaxLimit:(NSNumber *)maxLimitDataSize {
    return [self convertToDataWithimage:image MaxLimit:maxLimitDataSize isPng:false];
}

+ (UIImage *)convertWithimage:(UIImage *)image Size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

+ (NSTimer *)bl_socheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)(void))block repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(bl_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)bl_blockInvoke:(NSTimer *)timer {
    void (^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}
@end
