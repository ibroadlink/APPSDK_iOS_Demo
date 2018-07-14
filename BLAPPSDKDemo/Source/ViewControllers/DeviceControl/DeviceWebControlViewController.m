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

@implementation DeviceWebControlViewController {
    BLController *_blController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _blController = delegate.let.controller;
    [self loadContents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)loadContents {
    //h5文件的相对路径
    NSString *uiPath = [[_blController queryUIPath:[_selectDevice getPid]] stringByAppendingPathComponent:[self getPreferredLanguage]]; //  ../Let/ui/pid/zh-cn/
    BOOL isDir = FALSE;
    if ([[NSFileManager defaultManager] fileExistsAtPath:uiPath isDirectory:&isDir]) {
        if (isDir) {
            BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
            BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
            deviceService.selectDevice = _selectDevice;
            deviceService.blController = _blController;
            deviceService.accountName = [userDefault getUserName];
            
            NSString *appHtml = [uiPath stringByAppendingPathComponent:DNAKIT_DEFAULTH5PAGE_NAME]; //  ../Let/ui/pid/zh-cn/app.html
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:appHtml]];
            [self.webViewEngine loadRequest:request];
        }
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

