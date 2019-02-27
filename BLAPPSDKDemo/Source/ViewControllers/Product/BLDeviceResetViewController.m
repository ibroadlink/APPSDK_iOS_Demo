//
//  BLDeviceResetViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/27.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLDeviceResetViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface BLDeviceResetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *resetImageView;
@property (weak, nonatomic) IBOutlet UILabel *resetIntroductionLabel;

@end

@implementation BLDeviceResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.resetImageView sd_setImageWithURL:[NSURL URLWithString:self.model.resetPic]];
    self.resetIntroductionLabel.text = self.model.resetText;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
