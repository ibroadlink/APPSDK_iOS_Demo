//
//  AppDelegate.h
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BLLetBase/BLLetBase.h>
#import <BLLetCore/BLLetCore.h>
#import <BLLetAccount/BLLetAccount.h>
#import <BLLetIRCode/BLLetIRCode.h>
#import <BLLetPlugins/BLLetPlugins.h>

#import "AppMacro.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BLLet *let;

@end

