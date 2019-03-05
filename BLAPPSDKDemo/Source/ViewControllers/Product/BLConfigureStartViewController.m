//
//  BLConfigureStartViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/27.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLConfigureStartViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BLDeviceResetViewController.h"
#import "BLWebViewController.h"
@interface BLConfigureStartViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation BLConfigureStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.model.configPicUrlString]];
    self.label.text = self.model.configText;
}

- (IBAction)deviceReset:(id)sender {
    [self performSegueWithIdentifier:@"deviceReset" sender:self.model];
}

- (IBAction)beforecfgpurl:(id)sender {
    BLWebViewController *webViewVC = [[BLWebViewController alloc]init];
    webViewVC.url = self.model.beforeConfigHtml;
    [self.navigationController pushViewController:webViewVC animated:YES];
}

- (IBAction)cfgfailedurl:(id)sender {
    BLWebViewController *webViewVC = [[BLWebViewController alloc]init];
    webViewVC.url = self.model.failedHtml;
    [self.navigationController pushViewController:webViewVC animated:YES];
}

- (IBAction)introduction:(id)sender {
    NSArray *introductions = self.model.introduction;
    if (introductions.count == 1) {
        BLWebViewController *webViewVC = [[BLWebViewController alloc]init];
        BLDeviceConfigIntroduction *introduction = introductions[0];
        webViewVC.url = introduction.url;
        [self.navigationController pushViewController:webViewVC animated:YES];
    }else {
         UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"分类" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (BLDeviceConfigIntroduction *introduction in introductions) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:introduction.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                BLWebViewController *webViewVC = [[BLWebViewController alloc]init];
                webViewVC.url = introduction.url;
                [self.navigationController pushViewController:webViewVC animated:YES];
            }];
            [alertView addAction:action];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alertView addAction:cancelAction];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"deviceReset"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[BLDeviceResetViewController class]]) {
            BLDeviceResetViewController *vc = (BLDeviceResetViewController *)target;
            vc.model = (BLDeviceConfigureInfo *)sender;
        }
    }
}

@end
