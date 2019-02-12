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

#import "AppMacro.h"
#import "BLStatusBar.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BLControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BLLet *let;
@property (strong, nonatomic) NSMutableArray<BLDNADevice*> *scanDevices;
@end

