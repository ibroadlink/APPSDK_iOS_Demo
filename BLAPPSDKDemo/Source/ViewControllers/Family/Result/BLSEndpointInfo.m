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
                              @"devname":device.name ?: @"",
                              @"lock": [NSNumber numberWithBool:device.lock], // bool
                              @"aeskey":device.controlKey ?: @"",
                              @"terminalid":@(device.controlId),
                              @"extend":device.extendInfo ?: @""
                              };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        self.cookie = [[NSString alloc] initWithData:[jsonData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
    }
    
    return self;
}


- (BLDNADevice *)toDNADevice {
    
    BLDNADevice *device = [[BLDNADevice alloc] init];
    
    device.did = self.endpointId;
    device.pid = self.productId;
    device.mac = self.mac;
    device.pDid = self.gatewayId;
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self.cookie options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        device.password = [dic[@"password"] unsignedIntegerValue];
        device.type = [dic[@"devtype"] unsignedIntegerValue];
        device.name = dic[@"devname"];
        device.lock = [dic[@"lock"] boolValue];
        device.controlKey = dic[@"aeskey"];
        device.controlId = [dic[@"terminalid"] unsignedIntegerValue];
        NSString *extend = dic[@"extend"];
        if (![BLCommonTools isEmpty:extend]) {
            device.extendInfo = [BLCommonTools deserializeMessageJSON:extend];
        }
    }
    return device;
}

@end
