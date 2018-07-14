//
//  LoginViewController.h
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import "BLLoadingButton.h"
@interface LoginViewController : BaseViewController <UITextFieldDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet BLLoadingButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *scrolView;

@property (strong, nonatomic)  NSArray *spreadArry;
@property(nonatomic,strong) UIScrollView *bannerView;
@property(nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic, retain)NSTimer* rotateTimer;

- (IBAction)loginButtonClick:(UIButton *)sender;

@end
