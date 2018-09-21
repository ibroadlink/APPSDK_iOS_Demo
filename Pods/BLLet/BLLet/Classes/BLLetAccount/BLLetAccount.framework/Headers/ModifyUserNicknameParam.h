//
//  ModifyUserNicknameParam.h
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModifyUserNicknameParam : NSObject
/**
 *  昵称
 */
@property (nonatomic, strong, getter=getNickname) NSString *nickname;

/**
 *  初始化并设置昵称
 *
 *  @param nickname 昵称
 *
 *  @return 实例化
 */
- (instancetype)initWithNickname:(NSString *)nickname;

@end
