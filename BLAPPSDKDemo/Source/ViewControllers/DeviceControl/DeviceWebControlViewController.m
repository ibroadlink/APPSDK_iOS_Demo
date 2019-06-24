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

@implementation DeviceWebControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadContents];
    //获取通知中心单例对象
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(notice:) name:BL_SDK_H5_NAVI object:nil];
    [center addObserver:self selector:@selector(h5Param:) name:BL_SDK_H5_PARAM_BACK object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)loadContents {
    //h5文件的相对路径
    NSString *uiPath = [[[BLLet sharedLet].controller queryUIPath:[_selectDevice getPid]] stringByAppendingPathComponent:[self getPreferredLanguage]]; //  ../Let/ui/pid/zh-cn/
    BOOL isDir = FALSE;
    if ([[NSFileManager defaultManager] fileExistsAtPath:uiPath isDirectory:&isDir]) {
        if (isDir) {
            BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
            deviceService.selectDevice = _selectDevice;
            
            NSString *appHtml = [uiPath stringByAppendingPathComponent:DNAKIT_DEFAULTH5PAGE_NAME]; //  ../Let/ui/pid/zh-cn/app.html
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:appHtml]];
            [self.webViewEngine loadRequest:request];
        }
    }
}

- (void)notice:(NSNotification *)notification {
    //设置页面当前标题栏
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

/*
 *  @brief      获取本机语言代码
 *  @return     返回本机语言代码
 */
- (NSString*)getPreferredLanguage {
    //使用ios标准的语言格式，如："zh-Hans"
    NSMutableString *languageStr = [NSMutableString stringWithCapacity:0];
    [languageStr setString:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLocale"]];
    [languageStr replaceOccurrencesOfString:@"_" withString:@"-" options:0 range:NSMakeRange(0, [languageStr length] - 1)];
    NSString *preferredLang = [languageStr lowercaseString];
    
    return preferredLang;
}

@end

#pragma mark CDVCommandDelegate implementation
@implementation DeviceControlIndexCommandDelegate
/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className {
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath {
    return [super pathForResource:resourcepath];
}

@end


@implementation DeviceControlIndexCommandQueue

/* To override, uncomment the line in the init function(s)
 in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command {
    return [super execute:command];
}


@end

