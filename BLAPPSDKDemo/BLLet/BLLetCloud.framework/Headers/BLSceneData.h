//
//  BLSceneData.h
//  Let
//
//  Created by 白洪坤 on 2017/12/12.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLSceneData : NSObject
@property (nonatomic, strong, getter=getTaskid) NSString *taskid;
@property (nonatomic, strong, getter=getTasktime) NSString *tasktime;
@property (nonatomic, strong, getter=getMotduleid) NSString *moduleid;
@property (nonatomic, strong, getter=getName) NSString *name;
@property (nonatomic, strong, getter=getResult) NSString *result;
@property (nonatomic, assign) NSInteger nextdelay;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
