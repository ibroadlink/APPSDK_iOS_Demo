//
//  GetUserPhoneAndEmailResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLGetUserPhoneAndEmailResult : BLBaseResult

/** 
 User ID
 */
@property (nonatomic, strong, getter=getUserid) NSString *userid;

/** 
 User Email
 */
@property (nonatomic, strong, getter=getEmail) NSString *email;

/** 
 User Phone
 */
@property (nonatomic, strong, getter=getPhone) NSString *phone;

@end
