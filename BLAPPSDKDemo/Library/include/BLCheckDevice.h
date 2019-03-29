//
//  BLCheckDevice.h
//  BLCheckDevice
//
//  Created by admin on 2019/3/28.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCheckDevice : NSObject

- (instancetype)initWithDeviceMac:(NSString *)mac devType:(NSUInteger)type;;

- (NSInteger)createDeviceCheckSocket;
- (void)closedDeviceCheckSocket;

- (NSString *)queryServerList;
- (NSString *)sendHeartbeatToHostIP:(NSString *)ip port:(NSUInteger)port;

@end
