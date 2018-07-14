//
//  LoginByOauthViewController.h
//  BLAPPSDKDemo
//
//  Created by zhujunjie on 2017/7/26.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginByOauthViewController : BaseViewController

+ (instancetype)viewController;

@property (weak, nonatomic) IBOutlet UIWebView *loginWebView;

@end
