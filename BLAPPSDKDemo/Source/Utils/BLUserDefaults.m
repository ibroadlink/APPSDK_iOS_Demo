//
//  BLUserDefaults.m
//  BLDNAKitTool
//
//  Created by 朱俊杰 on 16/6/15.
//  Copyright © 2016年 Broadlink. All rights reserved.
//

#import "BLUserDefaults.h"
#import "BLNewFamilyManager.h"

@implementation BLUserDefaults {
    NSUserDefaults *userDefaults ;
}

+ (BLUserDefaults *) shareUserDefaults {
    static dispatch_once_t onceToken;
    static BLUserDefaults *user ;
    dispatch_once(&onceToken, ^{
        if (user == nil) {
            user = [[self alloc]init];
        }
    });
    return user;
}

- (instancetype) init {
    userDefaults = [NSUserDefaults standardUserDefaults];
    return self;
}

// Get/Set userName
- (void) setUserName:(NSString *)userName {
    [userDefaults setObject:userName forKey:@"userName"];
    [userDefaults synchronize];
}
- (NSString *) getUserName {
    return [userDefaults objectForKey:@"userName"];
}

// Get/Set userId
- (void) setUserId: (NSString *)userId {
    [userDefaults setObject:userId forKey:@"userId"];
    [userDefaults synchronize];
    
    [BLNewFamilyManager sharedFamily].userid = userId;
}
- (NSString *) getUserId {
    return [userDefaults objectForKey:@"userId"];
}

// Get/Set sessionId
- (void) setSessionId: (NSString *)sessionId {
    [userDefaults setObject:sessionId forKey:@"sessionId"];
    [userDefaults synchronize];
    
    [BLNewFamilyManager sharedFamily].loginsession = sessionId;
}
- (NSString *) getSessionId {
    return [userDefaults objectForKey:@"sessionId"];
}

// Get/Set packName
- (void) setPackName: (NSString *)packName {
    [userDefaults setObject:packName forKey:@"packName"];
    [userDefaults synchronize];
}
- (NSString *) getPackName {
    return [userDefaults objectForKey:@"packName"];
}

// Get/Set licenseId
- (void) setLicense: (NSString *)license {
    [userDefaults setObject:license forKey:@"license"];
    [userDefaults synchronize];
}
- (NSString *) getLicense {
    return [userDefaults objectForKey:@"license"];
}

- (void)setAppServiceEnable:(NSUInteger)enable {
    [userDefaults setObject:@(enable) forKey:@"enableAppService"];
    [userDefaults synchronize];
}

- (NSUInteger)getAppServiceEnable {
    NSNumber *enable = [userDefaults objectForKey:@"enableAppService"];
    if (enable) {
        return [enable unsignedIntegerValue];
    } else {
        return 1;
    }
}

- (void)setAppServiceHost:(NSString *)host {
    [userDefaults setObject:host forKey:@"appServiceHost"];
    [userDefaults synchronize];
}

- (NSString *)getAppServiceHost {
    return [userDefaults objectForKey:@"appServiceHost"];
}

@end
