//
//  BLFamilyMemberInfo.h
//  Let
//
//  Created by zjjllj on 2017/2/8.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLFamilyMemberInfo : NSObject

@property (nonatomic, copy) NSString *familyId;
/*!
 * @brief id of the user.
 */
@property (nonatomic, copy) NSString *userId;

/*!
 * @brief nickname of the user.
 */
@property (nonatomic, copy) NSString *nickName;

/*!
 * @brief type of the member. 0:管理员；1:普通成员
 */
@property (nonatomic, assign) NSUInteger type;

/*!
 * @brief url of the user header icon.
 */
@property (nonatomic, copy) NSString *iconPath;

@end
