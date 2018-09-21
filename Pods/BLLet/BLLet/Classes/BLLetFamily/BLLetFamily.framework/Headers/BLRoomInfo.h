//
//  BLRoomInfo.h
//  Let
//
//  Created by zjjllj on 2017/2/8.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLRoomInfo : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)getBaseDictionary;

- (NSDictionary *)toDictionary;

@property (nonatomic, copy)NSString *familyId;          //房间所在家庭的ID
@property (nonatomic, copy)NSString *roomId;            //房间自身ID
@property (nonatomic, copy)NSString *name;              //房间名称
@property (nonatomic, assign)NSInteger type;            //房间类型
@property (nonatomic, assign)NSInteger order;           //房间序号

@property (nonatomic, copy)NSString *action;            //房间执行操作 add,modify,del

@end
