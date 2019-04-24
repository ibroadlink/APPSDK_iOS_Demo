//
//  BLOAuthBlockResult.h
//  Let
//
//  Created by zhujunjie on 2017/8/1.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>

@interface BLOAuthBlockResult : BLBaseResult

@property (nonatomic, copy) NSString *accessToken;

@property (nonatomic, assign) NSInteger expires;

/**
 Judge result is success or not.
 
 @return Success or not.
 */
- (Boolean)succeed;

@end
