//
//  BaseResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLBaseResult : NSObject

/**
 Result status. 0--success, others--failed.
 */
@property (nonatomic, assign, getter=getError) NSInteger error;

/**
 Result Message.
 */
@property (nonatomic, strong, getter=getMsg) NSString *msg;


/**
 Judge result is success or not.

 @return Success or not.
 */
- (Boolean)succeed;

@end
