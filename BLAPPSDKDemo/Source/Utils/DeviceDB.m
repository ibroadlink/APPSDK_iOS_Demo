//
//  DeviceDB.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DeviceDB.h"

@implementation DeviceDB  {
    sqlite3 *_database;
}

static DeviceDB *op = nil;

+ (instancetype)sharedOperateDB {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        op = [[DeviceDB alloc] init];
    });
    
    return op;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createDeviceSql];
    }
    
    return self;
}

- (void)execSql:(NSString *)sql {
    char *err;
    if (sqlite3_exec(_database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        NSLog(@"db exec err = %s", err);
    }
}

- (void)createDeviceSql {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"BLDevice"];
    if (sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
        sqlite3_close(_database);
        NSLog(@"open db failed");
    } else {
        NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS BLDeviceInfo (id integer PRIMARY KEY AUTOINCREMENT, pid text NOT NULL, did text NOT NULL, name text NOT NULL, mac text NOT NULL, type integer NOT NULL, controlId integer NOT NULL, controlKey text NOT NULL, ownerId text NOT NULL, pDid text)";
        [self execSql:sqlCreateTable];
    }
}

- (NSArray *)readAllDevicesFromSql {
    NSString *sqlQuery = @"SELECT * FROM BLDeviceInfo";
    sqlite3_stmt * statement;
    NSMutableArray *allDevices = [NSMutableArray arrayWithCapacity:0];
    
    if (sqlite3_prepare_v2(_database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            @autoreleasepool {
                BLDNADevice *device = [BLDNADevice new];
                const unsigned char *pid = sqlite3_column_text(statement, 1);
                [device setPid:[[NSString alloc] initWithUTF8String:(const char*)pid]];
                
                const unsigned char *did = sqlite3_column_text(statement, 2);
                [device setDid:[[NSString alloc] initWithUTF8String:(const char*)did]];
                
                const unsigned char *name = sqlite3_column_text(statement, 3);
                [device setName:[[NSString alloc] initWithUTF8String:(const char*)name]];
                
                const unsigned char *mac = sqlite3_column_text(statement, 4);
                [device setMac:[[NSString alloc] initWithUTF8String:(const char*)mac]];
                
                int type = sqlite3_column_int(statement, 5);
                [device setType:type];
                
                int controlId = sqlite3_column_int(statement, 6);
                [device setControlId:controlId];
                
                const unsigned char *controlKey = sqlite3_column_text(statement, 7);
                [device setControlKey:[[NSString alloc] initWithUTF8String:(const char*)controlKey]];
                
                const unsigned char *ownerid = sqlite3_column_text(statement, 8);
                if (![[[NSString alloc] initWithUTF8String:(const char*)ownerid] isEqualToString:@"(null)"]) {
                    [device setOwnerId:[[NSString alloc] initWithUTF8String:(const char*)ownerid]];
                }
                
                
                const unsigned char *pDid = sqlite3_column_text(statement, 9);
                [device setPDid:[[NSString alloc] initWithUTF8String:(const char*)pDid]];
                
                
                [allDevices addObject:device];
            }
        }
    }
    
    return [allDevices copy];
}

- (NSInteger)insertSqlWithDevice:(BLDNADevice *)device {
    NSString *sqlQuery = @"SELECT max(id) FROM BLDeviceInfo";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(_database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSInteger sql_id = sqlite3_column_int(statement, 0);
            sql_id++;
            NSString *sqlInsert = [NSString stringWithFormat:
                                   @"INSERT INTO BLDeviceInfo (id, pid, did, name, mac, type, controlId, controlKey, ownerId, pDid) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                                   @(sql_id), device.getPid, device.getDid, device.getName, device.getMac, @(device.getType), @(device.getControlId), device.getControlKey, device.ownerId, device.pDid];
            [self execSql:sqlInsert];
            return sql_id;
        }
    }
    
    return -1;
}

- (void)updateSqlWithDevice:(BLDNADevice *)device {
    NSString *sqlUpdate = [NSString stringWithFormat:
                           @"UPDATE BLDeviceInfo set name = '%@', type = '%lu', controlId = '%lu', controlKey = '%@' where did = '%@'",
                           device.getName, (unsigned long)device.getType,(unsigned long)device.controlId, device.controlKey, device.did];
    
    [self execSql:sqlUpdate];
}

//删除设备
- (void)deleteWithinfo:(BLDNADevice *)device{
    NSString *sqlInsert = [NSString stringWithFormat:@"DELETE FROM BLDeviceInfo WHERE did = '%@';",device.getDid];
    [self execSql:sqlInsert];
}

@end
