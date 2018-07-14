//
//  OauthBindViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2018/3/1.
//  Copyright © 2018年 BroadLink. All rights reserved.
//

#import "OauthBindViewController.h"
#import "AppDelegate.h"
#import <BLLetAccount/BLLetAccount.h>
@interface OauthBindViewController ()
@property (nonatomic,strong)BLAccount *account;
@end

@implementation OauthBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)queryOatuhBind:(id)sender {
    [_account queryOauthBindInfo:^(BLBindInfoResult * _Nonnull result) {
        NSArray *bindinfos = result.bindinfos;
        for (BLBindinfo *bindinfo in bindinfos) {
            NSLog(@"thirdid:%@,thirdtype:%@",bindinfo.thirdid ,bindinfo.thirdtype);
        }
    }];
    
}

- (IBAction)bindOauth:(id)sender {
    [_account bindOauthAccount:@"taobao" thirdID:@"AAHGZHIXAELmMHck_oygC-Ad" accesstoken:@"6100311fe5dd99c512512692f3d70b465c49c66861944b83577385934" topSign:@"access_token=6100311fe5dd99c512512692f3d70b465c49c66861944b83577385934&token_type=Bearer&expires_in=7776000&refresh_token=6102a114835176b8dae11980d61259ac352be09896e304c3577385934&re_expires_in=0&r1_expires_in=1800&r2_expires_in=0&taobao_open_uid=AAG1ZHIXAELmMHck_ox3bO_B&taobao_user_nick=tb30850741&w1_expires_in=1800&w2_expires_in=0&state=1212&top_sign=475945EDCB47901BD10192FFDCF10D98" completionHandler:^(BLBaseResult * _Nonnull result) {
        NSLog(@"%@",result.msg);
    }];
}

- (IBAction)unBindOauth:(id)sender {
    [_account unbindOauthAccount:@"taobao" thirdID:@"AAHGZHIXAELmMHck_oygC-Ad" topSign:@"access_token=6100311fe5dd99c512512692f3d70b465c49c66861944b83577385934&token_type=Bearer&expires_in=7776000&refresh_token=6102a114835176b8dae11980d61259ac352be09896e304c3577385934&re_expires_in=0&r1_expires_in=1800&r2_expires_in=0&taobao_open_uid=AAG1ZHIXAELmMHck_ox3bO_B&taobao_user_nick=tb30850741&w1_expires_in=1800&w2_expires_in=0&state=1212&top_sign=475945EDCB47901BD10192FFDCF10D98" completionHandler:^(BLBaseResult * _Nonnull result) {
        NSLog(@"%@",result.msg);
    }];
}

- (void)sendDestroyCode{
        [_account sendDestroyCodeWithPhoneOrEmail:@"13567165451" countryCode:@"0086" completionHandler:^(BLBaseResult * _Nonnull result) {
            NSLog(@"sendDestroyCode result:%@",result);
        }];
    //    [_account destroyAccountWithPhoneOrEmail:@"13567165451" countryCode:@"0086" vcode:@"123" completionHandler:^(BLBaseResult * _Nonnull result) {
    //        NSLog(@"result:%@",result);
    //    }];
    //    [_account destroyUnBindAccountCompletionHandler:^(BLBaseResult * _Nonnull result) {
    //        NSLog(@"result:%@",result);
    //    }];
}

@end
