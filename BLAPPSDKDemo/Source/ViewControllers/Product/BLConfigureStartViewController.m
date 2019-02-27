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
@interface BLConfigureStartViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation BLConfigureStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.model.configPicUrlString]];
    self.label.text = self.model.configText;
}

- (IBAction)deviceReset:(id)sender {
    [self performSegueWithIdentifier:@"deviceReset" sender:self.model];
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
