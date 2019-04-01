//
//  BaseViewController.m
//  BLDNAKitTool
//
//  Created by junjie.zhu on 16/6/15.
//  Copyright © 2016年 Broadlink. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"

@interface BaseViewController () <MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD* progressHUD;
@property (nonatomic, strong) UIView* progressHUDBackView;

@property (nonatomic, strong) NSTimer *overTimer;
@property (nonatomic, assign) NSInteger downCount;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        [self setViewEdgeInset];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(viewBack)];
    self.navigationItem.backBarButtonItem = item;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - public method
- (void)showIndicatorOnWindowWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initProgressHUD];
        
       self.progressHUD.label.text = message;
        [self.progressHUD showAnimated:YES];
        
        self.downCount = 240;
        self.overTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(overTimer:) userInfo:nil repeats:YES];
    });
}

- (void)showIndicatorOnWindow
{
    [self showIndicatorOnWindowWithMessage:@"Loding..."];
}

- (void)hideIndicatorOnWindow
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.overTimer invalidate];
        self.overTimer = nil;
        [self.progressHUDBackView removeFromSuperview];
        self.progressHUDBackView = nil;
        [self.progressHUD hideAnimated:YES];
    });
}

- (void)showTextOnly:(NSString *)text
{
    _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _progressHUD.mode = MBProgressHUDModeText;
    _progressHUD.label.text = text;
    _progressHUD.margin = 10.f;
    _progressHUD.removeFromSuperViewOnHide = YES;
    
    [_progressHUD hideAnimated:YES afterDelay:2.0f];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - private method
-(void)setViewEdgeInset{   
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)initProgressHUD
{
    if (_progressHUD == nil) {
        _progressHUDBackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 45.0f, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height - 45.0f)];
        [self.view addSubview:_progressHUDBackView];
        
        _progressHUD = [[MBProgressHUD alloc] initWithView:_progressHUDBackView];
        _progressHUD.delegate = self;
        [_progressHUDBackView addSubview:_progressHUD];
    }
}

- (void)overTimer:(NSTimer *)timer
{
    _downCount--;
    if (_downCount == 0) {
        [self hideIndicatorOnWindow];
    }
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [_progressHUD removeFromSuperview];
    _progressHUD = nil;
}
@end
