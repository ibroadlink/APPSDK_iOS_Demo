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

// Get/Set Password
- (void) setPassword:(NSString *)password;
- (NSString *) getPassword;

// Get/Set userId
- (void) setUserId: (NSString *)userId;
- (NSString *) getUserId;

// Get/Set sessionId
- (void) setSessionId: (NSString *)sessionId;
- (NSString *) getSessionId;

@end
