//
//  GetUserInfoResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLUserInfo : NSObject

/** 
 User ID
 */
@property (nonatomic, strong, getter=getUserid) NSString *userid;

/** 
 User nickname
 */
@property (nonatomic, strong, getter=getNickname) NSString *nickname;

/** 
 User icon store url
 */
@property (nonatomic, strong, getter=getIconUrl) NSString *iconUrl;

@end

@interface BLGetUserInfoResult : BLBaseResult

/** 
 User info list
 */
@property (nonatomic, strong, getter=getInfo) NSArray<BLUserInfo *> *info;

@end
