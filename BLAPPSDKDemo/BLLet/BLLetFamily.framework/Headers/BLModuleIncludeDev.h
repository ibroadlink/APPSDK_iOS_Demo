//
//  BLModuleIncludeDev.h
//  Let
//
//  Created by zhujunjie on 2017/7/10.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLModuleIncludeDev : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)toDictionary;

@property (nonatomic, copy) NSString *did;      //设备Did
@property (nonatomic, copy) NSString *sdid;     //若为子设备，则包含该子设备did
@property (nonatomic, copy) NSString *content;  //设备相关扩展内容，由用户自定义
@property (nonatomic, assign) NSInteger order;  //序号

@end
