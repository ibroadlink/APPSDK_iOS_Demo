//
//  DeviceWebControlViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/31.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DeviceWebControlViewController.h"
#import "BLDeviceService.h"
#import "BLUserDefaults.h"
#import "AppDelegate.h"
#import "AppMacro.h"
#import "BLTheme.h"

@implementation DeviceWebControlViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self loadContents];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(notice:) name:BL_SDK_H5_NAVI object:nil];
    [center addObserver:self selector:@selector(h5Param:) name:BL_SDK_H5_PARAM_BACK object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)loadContents {
    NSString *uiPath = [[[BLLet sharedLet].controller queryUIPath:[_selectDevice getPid]] stringByAppendingPathComponent:[self getPreferredLanguage]];
    BOOL isDir = FALSE;
    if ([[NSFileManager defaultManager] fileExistsAtPath:uiPath isDirectory:&isDir]) {
        if (isDir) {
            BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
            deviceService.selectDevice = _selectDevice;

            NSString *appHtml = [uiPath stringByAppendingPathComponent:DNAKIT_DEFAULTH5PAGE_NAME];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:appHtml]];
            [self.webViewEngine loadRequest:request];
        }
    }
}

- (void)notice:(NSNotification *)notification {
    if (notification.userInfo) {
        self.navigationController.navigationBarHidden = NO;
        [self.webViewEngine evaluateJavaScript:notification.userInfo[@"rightButtons"] completionHandler:nil];
    }
}

- (void)h5Param:(NSNotification *)notification {
    if (notification.userInfo) {
        [self.webViewEngine evaluateJavaScript:notification.userInfo[@"cancelHandler"] completionHandler:nil];
    }
}

- (NSString *)getPreferredLanguage {
    NSMutableString *languageStr = [NSMutableString stringWithCapacity:0];
    [languageStr setString:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLocale"]];
    [languageStr replaceOccurrencesOfString:@"_" withString:@"-" options:0 range:NSMakeRange(0, [languageStr length] - 1)];
    return [languageStr lowercaseString];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark CDVCommandDelegate implementation
@implementation DeviceControlIndexCommandDelegate

- (id)getCommandInstance:(NSString *)className {
    return [super getCommandInstance:className];
}

- (NSString *)pathForResource:(NSString *)resourcepath {
    return [super pathForResource:resourcepath];
}

@end

@implementation DeviceControlIndexCommandQueue

- (BOOL)execute:(CDVInvokedUrlCommand *)command {
    return [super execute:command];
}

@end
