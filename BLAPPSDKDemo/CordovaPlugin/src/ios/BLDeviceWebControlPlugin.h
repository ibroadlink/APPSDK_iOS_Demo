//
//  BLDeviceWebControlPlugin.h
//  Let
//
//  Created by junjie.zhu on 2016/10/31.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Cordova/CDV.h>

@interface BLDeviceWebControlPlugin : CDVPlugin
//获取当前家庭信息
- (void)getFamilyInfo:(CDVInvokedUrlCommand *)command;
//获取设备的Profile
- (void)getDeviceProfile:(CDVInvokedUrlCommand *)command;
//获取设备信息
- (void)deviceinfo:(CDVInvokedUrlCommand*)command;
//设备控制通用接口
- (void)devicecontrol:(CDVInvokedUrlCommand*)command;
//通知接口
- (void)notification:(CDVInvokedUrlCommand*)command;
//自定义导航栏
- (void)custom:(CDVInvokedUrlCommand *)command;
//http request
- (void)httpRequest:(CDVInvokedUrlCommand *)command;
//获取用户信息
- (void)getUserInfo:(CDVInvokedUrlCommand *)command;
//获取网关子设备列表
- (void)getGetwaySubDeviceList:(CDVInvokedUrlCommand *)command;
//关闭页面
- (void)closeWebView:(CDVInvokedUrlCommand *)command;
//获取Wi-Fi信息
- (void)wifiInfo:(CDVInvokedUrlCommand *)command;
//发送验证码
- (void)accountSendVCode:(CDVInvokedUrlCommand *)command;
//打开指定页面
- (void)openUrl:(CDVInvokedUrlCommand *)command;
//添加设备到SDK
- (void)addDeviceToNetworkInit:(CDVInvokedUrlCommand *)command;

@end
