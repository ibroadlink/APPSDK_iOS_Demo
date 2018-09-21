//
//  BLSceneDeteailData.h
//  Let
//
//  Created by 白洪坤 on 2017/12/13.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLSceneData.h"

@interface BLSceneDeteail :NSObject
- (instancetype)initWithDictionary:(NSDictionary *)dic;

@property (nonatomic, strong, getter=getOrder) NSString *order;
@property (nonatomic, assign) NSInteger delay;
@property (nonatomic, strong, getter=getName) NSString *name;
@property (nonatomic, strong, getter=getResult) NSString *result;
@property (nonatomic, strong, getter=getExecuttime) NSString *executtime;

@end


@interface BLSceneDeteailData : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@property (nonatomic, strong, getter=getSceneData) BLSceneData *sceneData;
@property (nonatomic, strong)NSMutableArray<BLSceneDeteail *> *deteail;
@end



