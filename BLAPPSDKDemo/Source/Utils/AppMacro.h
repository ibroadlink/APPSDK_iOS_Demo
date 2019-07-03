//
//  AppMacro.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 16/8/1.
//  copyright © 2016年 BroadLink. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h

#define SDK_PACKAGE_ID  @"com.broadlink.blappsdkdemo"
#define SDK_LICENSE     @"4oQxAHVFYnnY7HPuDlYnm0I6pGcRvFTh/Ct2Vv+/5qZDpJJiIweBn2RUUA6oE8InRDV+XAAAAABz4LOxmXdGndIQ0J762DN4lXimLcoYN1h90T3OlpYrQrNgvm0/7+Kdmrgfawtr+QWBY+UBaf8hxk19tobFrLsFsEkbxXTfoUSQjDzWcfVjcAAAAAA="

#define DISABLE_PUSH_NOTIFICATIONS 1    //不使能推送功能

#define PROBE_DEVICES_CHANGED   @"Probe_Devices_Changed"

#define SMART_SP              @"4.1.50"
#define SMART_RM              @"1.1.5"
#define SMART_A1              @"188.1.224"

#define IOSVersion                              [[[UIDevice currentDevice] systemVersion] floatValue]
#define IsiOS7Later                             !(IOSVersion < 7.0)
#define IsiOS8Later                             !(IOSVersion < 8.0)
#define IsiOS9Later                             !(IOSVersion < 9.0)
#define IsiOS10Later                            !(IOSVersion < 10.0)
#define IsiOS11Later                            !(IOSVersion < 11.0)

#define DNAKIT_DEFAULTH5PAGE_NAME                   @"app.html"                     //产品h5控制首页面名称
#define DNAKIT_CORVODA_JS_FILE                      @"cordova.js"                   //cordova默认ios的js文件
#define DNAKIT_CORVODA_PLUGIN_JS_FILE               @"cordova_plugins.js"           //cordova plugin默认js文件

#define BL_SDK_H5_NAVI                              @"h5Navi"                       //navi from js
#define BL_SDK_H5_PARAM                             @"h5Param"                      //param from h5
#define BL_SDK_H5_PARAM_BACK                        @"h5ParamBack"                  //param to h5

#define SPmini3 @"0000000000000000000000003e750000"
#define SPmini  @"00000000000000000000000028270000"
#define RMmini3 @"0000000000000000000000008f270000"
#define RMpro @"0000000000000000000000002a270000"

#define BLE_SERVICE_UUID                            @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
#define BLE_CHARACTERISTIC_NOTIFY_UUID              @"49535343-1E4D-4BD9-BA61-23C647249616"
#define BLE_CHARACTERISTIC_WRITE_UUID               @"49535343-8841-43F4-A8D4-ECBE34729BB3"

#endif /* AppMacro_h */
