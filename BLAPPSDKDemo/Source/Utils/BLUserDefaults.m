//
//  BLUserDefaults.m
//  BLDNAKitTool
//
//  Created by 朱俊杰 on 16/6/15.
//  Copyright © 2016年 Broadlink. All rights reserved.
//

#import "BLUserDefaults.h"

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

// Get/Set
- (void) setPassword:(NSString *)password {
    [userDefaults setObject:password forKey:@"password"];
    [userDefaults synchronize];
}
- (NSString *) getPassword {
    return [userDefaults objectForKey:@"password"];
}

// Get/Set userId
- (void) setUserId: (NSString *)userId {
    [userDefaults setObject:userId forKey:@"userId"];
    [userDefaults synchronize];
}
- (NSString *) getUserId {
    return [userDefaults objectForKey:@"userId"];
}

// Get/Set sessionId
- (void) setSessionId: (NSString *)sessionId {
    [userDefaults setObject:sessionId forKey:@"sessionId"];
    [userDefaults synchronize];
}
- (NSString *) getSessionId {
    return [userDefaults objectForKey:@"sessionId"];
}



@end
