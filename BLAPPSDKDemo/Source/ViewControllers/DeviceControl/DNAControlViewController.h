//
//  DNAControlViewController.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import <BLLetCore/BLLetCore.h>


@interface DNAControlViewController : BaseViewController

@property (nonatomic, strong) BLDNADevice *device;

@property (weak, nonatomic) IBOutlet UITextField *valInputTextField;
@property (weak, nonatomic) IBOutlet UITextField *paramInputTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

- (IBAction)buttonClick:(UIButton *)sender;
@end
