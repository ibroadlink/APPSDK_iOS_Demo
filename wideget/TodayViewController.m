//
//  TodayViewController.m
//  wideget
//
//  Created by hongkun.bai on 2019/11/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <BLLetBase/BLLetBase.h>
#import <BLLetCore/BLLetCore.h>


@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, assign) NSInteger val;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self sdkInit];
    
    

}

- (void)initView {
    self.btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    self.btn.backgroundColor = [UIColor purpleColor];
    self.btn.layer.cornerRadius = 30;
    self.btn.layer.masksToBounds = YES;
    [self.btn addTarget:self action:@selector(switchOn) forControlEvents:UIControlEventTouchUpInside];
    [self.btn setTitle:@"开关" forState:UIControlStateNormal];
    [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.btn];
}

- (void)sdkInit {
    NSUserDefaults *shareData = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.com.broadlink"];
    // Do any additional setup after loading the view.
    [BLConfigParam sharedConfigParam].packName = [shareData objectForKey:@"packName"];                // Set Package ID
    [BLLet sharedLetWithLicense:[shareData objectForKey:@"sdkLicense"]];                        // Init APPSDK
    [BLConfigParam sharedConfigParam].appServiceEnable = 1;
    [[BLLet sharedLet] setDebugLog:BL_LEVEL_DEBUG];                                            // Set APPSDK debug log level
    [[BLLet sharedLet].controller setSDKRawDebugLevel:BL_LEVEL_DEBUG];                       // Set DNASDK debug log level
    [BLConfigParam sharedConfigParam].userid = [shareData objectForKey:@"userid"];
    [BLConfigParam sharedConfigParam].loginSession = [shareData objectForKey:@"loginSession"];
    [BLConfigParam sharedConfigParam].controllerScriptDownloadVersion = 1;          // 脚本下载平台
    

    NSString *deviceStr = [shareData objectForKey:@"widgetDevice"];
    self.device = [BLDNADevice BLS_modelWithJSON:deviceStr];
    [[BLLet sharedLet].controller addDevice:self.device];
    BLStdData *stdData = [[BLStdData alloc] initDataWithParams:@[@"pwr"] vals:@[]];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:self.device.did stdData:stdData action:@"get"];
    if ([result succeed]) {
        self.val = [[[result getData] valueForParam:@"pwr"] intValue];
        [self.btn setTitle:self.val ? @"关": @"开" forState:UIControlStateNormal];
    }
}

- (void)switchOn {
    BLStdData *stdData = [[BLStdData alloc] initDataWithParams:@[@"pwr"] vals:@[@[@{@"val":@(self.val?0:1),@"idx":@(1)}]]];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:self.device.did stdData:stdData action:@"set"];
    if ([result succeed]) {
        self.val = [[[result getData] valueForParam:@"pwr"] intValue];
        [self.btn setTitle:self.val ? @"关": @"开" forState:UIControlStateNormal];
    }
    NSLog(@"widget result:%@",[result BLS_modelToJSONString]);
}

- (void)viewWillAppear:(BOOL)animated {
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 105);
    }else {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 180);
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}


@end
