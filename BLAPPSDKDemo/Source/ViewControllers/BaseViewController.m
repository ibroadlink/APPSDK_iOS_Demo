//
//  BaseViewController.m
//  BLDNAKitTool
//
//  Created by junjie.zhu on 16/6/15.
//  Copyright © 2016年 Broadlink. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "BLTheme.h"
#import "Tools.h"

@interface BaseViewController () <MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *progressHUDBackView;
@property (nonatomic, strong) NSTimer *overTimer;
@property (nonatomic, assign) NSInteger downCount;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewEdgeInset];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [BLTheme primaryColor];
}

- (void)dealloc {
    [self.overTimer invalidate];
    self.overTimer = nil;
}

- (void)viewBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - HUD

- (void)showIndicatorOnWindowWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initProgressHUD];
        self.progressHUD.label.text = message;
        [self.progressHUD showAnimated:YES];

        [self.overTimer invalidate];
        self.downCount = 240;
        __weak typeof(self) weakSelf = self;
        self.overTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                [timer invalidate];
                return;
            }
            strongSelf.downCount--;
            if (strongSelf.downCount <= 0) {
                [strongSelf hideIndicatorOnWindow];
            }
        }];
    });
}

- (void)showIndicatorOnWindow {
    [self showIndicatorOnWindowWithMessage:@"Loading..."];
}

- (void)hideIndicatorOnWindow {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.overTimer invalidate];
        self.overTimer = nil;
        [self.progressHUDBackView removeFromSuperview];
        self.progressHUDBackView = nil;
        [self.progressHUD hideAnimated:YES];
        self.progressHUD = nil;
    });
}

- (void)showTextOnly:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = text;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:2.0f];
    });
}

- (void)setExtraCellLineHidden:(UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)runInBackgroundWithHUD:(NSString *)message
                         block:(void (^)(void))block
                    completion:(void (^)(void))completion {
    if (message.length > 0) {
        [self showIndicatorOnWindowWithMessage:message];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (block) { block(); }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (message.length > 0) {
                [self hideIndicatorOnWindow];
            }
            if (completion) { completion(); }
        });
    });
}

- (void)resignFirstResponderForTextFields:(NSArray<UITextField *> *)fields {
    for (UITextField *field in fields) {
        [field resignFirstResponder];
    }
}

#pragma mark - private

- (void)setViewEdgeInset {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)initProgressHUD {
    if (self.progressHUD) { return; }

    self.progressHUDBackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 45.0f, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height - 45.0f)];
    [self.view addSubview:self.progressHUDBackView];

    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.progressHUDBackView];
    self.progressHUD.delegate = self;
    self.progressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.progressHUD.bezelView.color = [[BLTheme titleColor] colorWithAlphaComponent:0.85];
    self.progressHUD.contentColor = [UIColor whiteColor];
    self.progressHUD.bezelView.layer.cornerRadius = 14.0;
    [self.progressHUDBackView addSubview:self.progressHUD];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.progressHUD removeFromSuperview];
    self.progressHUD = nil;
}

@end
