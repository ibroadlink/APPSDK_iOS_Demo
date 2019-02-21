//
//  BLSEndpointInfo.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSEndpointInfo.h"

@implementation BLSEndpointInfo

- (instancetype)initWithBLDevice:(BLDNADevice *)device {
    self = [super init];
    if (self) {
        
        self.endpointId = device.did;
        self.mac = device.mac;
        self.productId = device.pid;
        if (device.pDid) {
            self.gatewayId = device.pDid;
        } else {
            self.gatewayId = @"";
        }
        
        NSDictionary *dic = @{
                              @"password":@(device.password),
                              @"devtype":@(device.type),
                              @"devname":device.name,
                              @"lock": [NSNumber numberWithBool:device.lock], // bool
                              @"aeskey":device.controlKey,
                              @"terminalid":@(device.controlId),
                              @"extend":device.extendInfo ? [BLCommonTools serializeMessage:self.extend] : @""
                              };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        self.cookie = [[NSString alloc] initWithData:[jsonData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
    }
    
    return self;
}

@end
