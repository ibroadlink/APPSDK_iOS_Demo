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
//获取当前家庭场景列表
- (void)getFamilySceneList:(CDVInvokedUrlCommand *)command;
//获取设备所在的房间
- (void)getDeviceRoom:(CDVInvokedUrlCommand *)command;
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
//请求云端服务
- (void)cloudServices:(CDVInvokedUrlCommand *)command;
//http request
- (void)httpRequest:(CDVInvokedUrlCommand *)command;
//获取用户信息
- (void)getUserInfo:(CDVInvokedUrlCommand *)command;
//获取家庭下设备列表
- (void)getDeviceList:(CDVInvokedUrlCommand *)command;
//获取网关子设备列表
- (void)getGetwaySubDeviceList:(CDVInvokedUrlCommand *)command;
//关闭页面
- (void)closeWebView:(CDVInvokedUrlCommand *)command;
//获取Wi-Fi信息
- (void)wifiInfo:(CDVInvokedUrlCommand *)command;
/*gpsLocation*/
- (void)gpsLocation:(CDVInvokedUrlCommand *)command;
//发送验证码
- (void)accountSendVCode:(CDVInvokedUrlCommand *)command;
//打开指定页面
- (void)openUrl:(CDVInvokedUrlCommand *)command;
//添加设备到SDK
- (void)addDeviceToNetworkInit:(CDVInvokedUrlCommand *)command;
//添加设备到家庭
- (void)addDeviceToFamily:(CDVInvokedUrlCommand *)command;
//从家庭里面删除
- (void)deleteFamilyDeviceList:(CDVInvokedUrlCommand *)command;
//打开设备属性页，跳转到 Native 页面
- (void)openDevicePropertyPage:(CDVInvokedUrlCommand *)command;
//打开添加网关下子设备产品分类页面
- (void)openGatewaySubProductCategoryListPage:(CDVInvokedUrlCommand *) command;
//设备授权
- (void)deviceAuth:(CDVInvokedUrlCommand *)command;
//设备授权检查
- (void)checkDeviceAuth:(CDVInvokedUrlCommand *)command;
//获取当前设备分组信息(负载信息)
- (void)getDeviceVirtualGroups:(CDVInvokedUrlCommand *)command;
//设备联动触发条件或者执行指令选择
- (void)deviceLinkageParamsSet:(CDVInvokedUrlCommand *)command;
//打开产品(设备)添加页面
- (void)openProductAddPage:(CDVInvokedUrlCommand *)command;
//设备参数选择
- (void)saveSceneCmds:(CDVInvokedUrlCommand *)command;
@end
