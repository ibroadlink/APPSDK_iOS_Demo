//
//  BLUserDefaults.h
//  BLDNAKitTool
//
//  Created by 朱俊杰 on 16/6/15.
//  Copyright © 2016年 Broadlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLUserDefaults : NSUserDefaults

+ (BLUserDefaults *) shareUserDefaults;

// Get/Set userName
- (void) setUserName: (NSString *)userName;
- (NSString *) getUserName;

// Get/Set userId
- (void) setUserId: (NSString *)userId;
- (NSString *) getUserId;

// Get/Set sessionId
- (void) setSessionId: (NSString *)sessionId;
- (NSString *) getSessionId;

// Get/Set packName
- (void) setPackName: (NSString *)packName;
- (NSString *) getPackName;

// Get/Set license
- (void) setLicense: (NSString *)license;
- (NSString *) getLicense;

// Get/Set Use APPService
- (void)setAppServiceEnable:(NSUInteger)enable;
- (NSUInteger)getAppServiceEnable;

// Get/Set APPService Host
- (void)setAppServiceHost:(NSString *)host;
- (NSString *)getAppServiceHost;

@end
