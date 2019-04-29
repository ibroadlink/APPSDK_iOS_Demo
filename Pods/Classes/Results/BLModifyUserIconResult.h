//
//  ModifyUserIconResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLModifyUserIconResult : BLBaseResult

/**
 User icon store url.
 */
@property (nonatomic, strong, getter=getIconUrl) NSString *iconUrl;

@end
