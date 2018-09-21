//
//  ModifyUserIconParam.h
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModifyUserIconParam : NSObject

/**
 用户iconPath
 */
@property (nonatomic, strong, getter=getIconPath) NSString *iconPath;

/**
 *  初始化并设置icon
 *
 *  @param iconPath icon
 *
 *  @return 实例化
 */
- (instancetype)initWithIconPath:(NSString *)iconPath;

@end
