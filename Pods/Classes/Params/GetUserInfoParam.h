//
//  GetUserInfoParam.h
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetUserInfoParam : NSObject

/**
 用户user id列表
 */
@property (nonatomic, strong, getter=getUseridArray) NSArray<NSString *> *useridArray;

/**
 *  初始化并设置id列表
 *
 *  @param useridArray id列表
 *
 *  @return 实例化
 */
- (instancetype)initWithUseridArray:(NSArray<NSString *> *)useridArray;

/**
 *  添加一个id
 *
 *  @param userid id
 */
- (void)addUserid:(NSString *)userid;

@end
