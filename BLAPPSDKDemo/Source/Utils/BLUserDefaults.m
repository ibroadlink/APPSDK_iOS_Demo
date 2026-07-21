//
//  BLUserDefaults.m
//  BLDNAKitTool
//
//  Created by 朱俊杰 on 16/6/15.
//  Copyright © 2016年 Broadlink. All rights reserved.
//

#import "BLUserDefaults.h"
#import <BLSFamily/BLSFamily.h>

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

- (void)bl_setObject:(id)object forKey:(NSString *)key {
    if (object) {
        [userDefaults setObject:object forKey:key];
    } else {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
}

// Get/Set userName
- (void) setUserName:(NSString *)userName {
    [self bl_setObject:userName forKey:@"userName"];
}
- (NSString *) getUserName {
    return [userDefaults objectForKey:@"userName"];
}

// Get/Set userId
- (void) setUserId: (NSString *)userId {
    [self bl_setObject:userId forKey:@"userId"];
}
- (NSString *) getUserId {
    return [userDefaults objectForKey:@"userId"];
}

// Get/Set sessionId
- (void) setSessionId: (NSString *)sessionId {
    [self bl_setObject:sessionId forKey:@"sessionId"];
}
- (NSString *) getSessionId {
    return [userDefaults objectForKey:@"sessionId"];
}

// Get/Set packName
- (void) setPackName: (NSString *)packName {
    [self bl_setObject:packName forKey:@"packName"];
}
- (NSString *) getPackName {
    return [userDefaults objectForKey:@"packName"];
}

// Get/Set licenseId
- (void) setLicense: (NSString *)license {
    [self bl_setObject:license forKey:@"license"];
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
    [self bl_setObject:host forKey:@"appServiceHost"];
}

- (NSString *)getAppServiceHost {
    return [userDefaults objectForKey:@"appServiceHost"];
}

- (void)applyLoginWithUserName:(NSString *)userName userId:(NSString *)userId sessionId:(NSString *)sessionId {
    if (userName.length > 0) {
        [self setUserName:userName];
    }
    if (userId.length > 0) {
        [self setUserId:userId];
    }
    if (sessionId.length > 0) {
        [self setSessionId:sessionId];
    }
}

- (void)clearLoginSession {
    [self setUserId:nil];
    [self setSessionId:nil];
}

@end
