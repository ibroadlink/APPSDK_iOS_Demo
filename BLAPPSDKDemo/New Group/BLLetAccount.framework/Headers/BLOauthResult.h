//
//  BLOauthResult.h
//  Let
//
//  Created by zhujunjie on 2017/8/1.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLOauthResult : BLBaseResult

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
//失效时间
@property (nonatomic, assign) NSInteger expires;

@end
