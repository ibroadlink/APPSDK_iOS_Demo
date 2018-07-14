//
//  DeviceDB.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetCore/BLLetCore.h>
#import <sqlite3.h>

@interface DeviceDB : NSObject

+ (instancetype)sharedOperateDB;

- (NSArray *)readAllDevicesFromSql;
- (NSInteger)insertSqlWithDevice:(BLDNADevice *)device;
- (void)updateSqlWithDevice:(BLDNADevice *)device;
- (void)deleteWithinfo:(BLDNADevice *)device;
@end
