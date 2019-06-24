//
//  ModifyPasswordParam.h
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModifyPasswordParam : NSObject

/**
 *  老密码
 */
@property (nonatomic, strong, getter=getTheOldPassword) NSString *theOldPassword;

/**
 *  新密码
 */
@property (nonatomic, strong, getter=getTheNewPassword) NSString *theNewPassword;


/**
 *  初始化并设置新密码与老密码
 *
 *  @param theNewPassword 新密码
 *  @param theOldPassword 老密码
 *
 *  @return 实例化
 */
- (instancetype)initWithNewPassword:(NSString *)theNewPassword oldPassword:(NSString *)theOldPassword;

@end
