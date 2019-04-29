/*!
  @header BLTokenBurst.h

  @abstract HTTP接口发送限制

  @author Created by zjjllj on 2017/3/27.

  @version 1.00 2017/3/27Creation

  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
*/


#import <Foundation/Foundation.h>

/*!
  @class HTTP接口发送限制类
  @adstract 关于这个类的一些基本描述
*/
@interface BLTokenBurst : NSObject

+ (instancetype)sharedBurst;

- (BOOL)queryTokenBurstWithUrl:(NSString *)url;

@end
