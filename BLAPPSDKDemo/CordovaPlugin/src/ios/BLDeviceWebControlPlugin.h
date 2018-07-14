//
//  BLDeviceWebControlPlugin.h
//  Let
//
//  Created by junjie.zhu on 2016/10/31.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Cordova/CDV.h>

@interface BLDeviceWebControlPlugin : CDVPlugin

- (void)deviceinfo:(CDVInvokedUrlCommand*)command;
- (void)devicecontrol:(CDVInvokedUrlCommand*)command;
- (void)notification:(CDVInvokedUrlCommand*)command;

@end
