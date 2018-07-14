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
#import <BLLetPlugins/BLLetPlugins.h>
#import <BLLetCloud/BLLetCloud.h>
#import <BLLetAccount/BLLetAccount.h>
#import <BLLetFamily/BLLetFamily.h>

#import "AppMacro.h"
#import "BLStatusBar.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, BLControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BLLet *let;
@property (strong, nonatomic) BLOAuth *blOauth;
@property (strong, nonatomic) BLAccount *account;
@property (strong, nonatomic) BLFamilyController *familyController;
@property (strong, nonatomic) NSMutableArray<BLDNADevice*> *scanDevices;
@property (strong, nonatomic) BLCloudScene *blCloudScene;
@property (strong, nonatomic) BLCloudTime *blCloudTime;
@property (strong, nonatomic) BLCloudLinkage *blCloudLinkage;
@property (strong, nonatomic) BLApiUrls *apiUrls;
@end

