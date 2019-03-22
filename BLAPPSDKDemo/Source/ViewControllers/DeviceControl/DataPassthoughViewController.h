//
//  DataPassthoughViewController.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface DataPassthoughViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextView *dataInputTextView;
@property (weak, nonatomic) IBOutlet UITextView *dataShowTextView;

- (IBAction)buttonClick:(UIButton *)sender;

@end
