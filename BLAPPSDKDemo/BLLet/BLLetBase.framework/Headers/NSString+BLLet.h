//
//  NSString+BLLet.h
//  Let
//
//  Created by junjie.zhu on 2016/11/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BLLet)

+ (BOOL)isEmpty:(NSString *)str;

// 处理空字符串
+ (NSString *)convertNullOrNil:(NSString *)str;

// 序列化JSON
+ (NSString *)serializeMessage:(id)message;

// 反序列化JSON
+ (id)deserializeMessageJSON:(NSString *)messageJSON;

// 截取URL中的参数
- (NSMutableDictionary *)getURLParameters;
@end
