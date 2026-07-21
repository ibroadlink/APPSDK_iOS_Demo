//
//  Tools.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/3.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "Tools.h"
#import "BLStatusBar.h"

@implementation Tools

#pragma mark - Image

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize compressionQuality:(CGFloat)compressionQuality {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:UIImageJPEGRepresentation(newImage, compressionQuality)];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Device

+ (NSString *)controlDidForDevice:(BLDNADevice *)device {
    if (!device) { return @""; }
    return device.ownerId.length > 0 ? device.deviceId : device.did;
}

+ (NSString *)timerTargetDidForDevice:(BLDNADevice *)device sdid:(NSString *)sdid {
    if (![BLCommonTools isEmpty:sdid]) {
        return sdid;
    }
    return device.did ?: @"";
}

+ (NSString *)stringForDeviceState:(BLDeviceStatusEnum)state {
    switch (state) {
        case BL_DEVICE_STATE_LAN: return @"LAN";
        case BL_DEVICE_STATE_REMOTE: return @"REMOTE";
        case BL_DEVICE_STATE_OFFLINE: return @"OFFLINE";
        default: return @"Unknown";
    }
}

#pragma mark - JSON / Result

+ (NSString *)jsonStringFromObject:(id)obj {
    if (!obj) { return nil; }
    if (![NSJSONSerialization isValidJSONObject:obj]) { return nil; }
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    if (!data) { return nil; }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)dictionaryFromJSONString:(NSString *)json {
    if ([BLCommonTools isEmpty:json]) { return nil; }
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) { return nil; }
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return [obj isKindOfClass:[NSDictionary class]] ? obj : nil;
}

+ (NSString *)messageForError:(NSInteger)error msg:(NSString *)msg {
    return [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)error, msg ?: @""];
}

+ (NSString *)messageForSDKResult:(BLBaseResult *)result {
    if (!result) { return @"Unknown error"; }
    return [self messageForError:result.getError msg:result.getMsg];
}

#pragma mark - Cordova / UI Resource

+ (BOOL)copyCordovaJsNamed:(NSString *)fileName forPid:(NSString *)pid {
    if ([BLCommonTools isEmpty:fileName] || [BLCommonTools isEmpty:pid]) {
        return NO;
    }
    NSString *uiPath = [[[BLLet sharedLet].controller queryUIPath:pid] stringByDeletingLastPathComponent];
    NSString *fullPathFileName = [uiPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPathFileName]) {
        return YES;
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (!bundlePath) {
        BLLogDebug(@"%@ not found in bundle", fileName);
        return NO;
    }
    NSError *error = nil;
    BOOL success = [fileManager copyItemAtPath:bundlePath toPath:fullPathFileName error:&error];
    if (!success) {
        BLLogDebug(@"%@ copy failed: %@", fileName, error);
    }
    return success;
}

#pragma mark - Network

+ (void)postJSONToURL:(NSString *)url
                 head:(NSDictionary *)head
                 data:(NSDictionary *)data
              timeout:(NSUInteger)timeout
    completionHandler:(void (^)(NSData * _Nullable, NSError * _Nullable))completionHandler {
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    BLLogDebug(@"postData:%@", [BLCommonTools serializeMessage:data]);
    NSData *body = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    [httpAccessor post:url head:head data:body timeout:timeout completionHandler:completionHandler];
}

#pragma mark - Storyboard

+ (instancetype)viewControllerFromMainStoryboard:(Class)cls {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(cls)];
}

#pragma mark - Alert helpers

+ (void)presentAlertOn:(UIViewController *)vc
                 title:(NSString *)title
                fields:(NSArray<NSDictionary *> *)fields
               handler:(void (^)(NSArray<UITextField *> *textFields))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    for (NSDictionary *field in fields) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = field[@"text"] ?: @"";
            textField.placeholder = field[@"placeholder"] ?: @"";
            if (field[@"secure"]) {
                textField.secureTextEntry = [field[@"secure"] boolValue];
            }
        }];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler(alert.textFields);
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:alert animated:YES completion:nil];
}

@end

@implementation UIViewController (BLDemoHelpers)

- (void)showSDKResult:(BLBaseResult *)result successMessage:(NSString *)successMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([result succeed]) {
            [BLStatusBar showTipMessageWithStatus:successMessage ?: @"Success"];
        } else {
            [BLStatusBar showTipMessageWithStatus:[Tools messageForSDKResult:result]];
        }
    });
}

- (void)showErrorCode:(NSInteger)code msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [BLStatusBar showTipMessageWithStatus:[Tools messageForError:code msg:msg]];
    });
}

@end
