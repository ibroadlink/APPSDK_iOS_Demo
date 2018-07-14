//
//  UserViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2018/5/18.
//  Copyright © 2018年 BroadLink. All rights reserved.
//

#import "UserViewController.h"
#import "BLUserDefaults.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BLUserHeadImageCell.h"
#import "BLUserSaftyInfoCell.h"
#import "BLUserLogoutCell.h"
#import "BLSystemImage.h"
#import "BLStatusBar.h"
#import "UIImage+BDL.h"


@interface UserViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self getUserInfo];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1: {
            return 4;
        }
        case 2:
            return 1;
            
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 && indexPath.row == 0) {
        BLUserHeadImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLUserHeadImageCell"];
        cell.titleLabel.text = @"头像";
        [cell.IconUrlImageView sd_setImageWithURL:[NSURL URLWithString:self.iconUrl]];
        return cell;
    } else if (indexPath.section == 2) {
        BLUserLogoutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLUserLogoutCell"];
        cell.titleLabel.text = @"退出登录";
        return cell;
    } else {
        BLUserSaftyInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLUserSaftyInfoCell"];
        switch (indexPath.section) {
            case 0: {
                cell.titleLabel.text = @"昵称";
                cell.rightTitleLabel.text = self.name;
                break;
            }
            case 1: {
                switch (indexPath.row) {
                    case 0: {
                        cell.titleLabel.text = @"手机号";
                        cell.rightTitleLabel.text = self.phone;
                        break;
                    }
                    case 1: {
                        cell.titleLabel.text = @"邮箱地址";
                        cell.rightTitleLabel.text = self.email;
                        break;
                    }
                    case 2: {
                        cell.titleLabel.text = @"修改密码";
                        cell.rightTitleLabel.text = @"修改";
                        break;
                    }
                    case 3: {
                        cell.titleLabel.text = @"userid";
                        cell.rightTitleLabel.text = self.userid;
                        cell.rightTitleLabel.font = [UIFont systemFontOfSize:12];
                        break;
                    }
                        
                    default:
                        break;
                }
                break;
            }
                
            default:
                break;
        }
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 && indexPath.row==0) {
        return 80;
    }
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0 && indexPath.row == 0) {
        //修改头像
        BLSystemImage *systemImage = [[BLSystemImage alloc] init];
        [systemImage getImageWithActionSheetAllowsEditing:YES showGallery:NO inViewController:self block:^(UIImage *image) {
            if (image) {//请求修改用户头像
                [BLStatusBar showTipMessageWithStatus:@"str_common_uploading"];
                //save the image
                NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString * documentsDirectory = [paths objectAtIndex:0];
                NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"myHeadIcon.png"];
                if ([image writeToFileAtPath: imagePath withMaxLimitDataSize: @(1024 * 256)]) {
                    [self modifyUserIcon:imagePath];
                }
            }
        }];
    } else if (indexPath.section == 2) {
        //退出登录
        [self logout];
    } else {
        switch (indexPath.section) {
            case 0: {
                //修改昵称
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请输入新的昵称"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.text = self.name;
                }];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [self modifyUserNickname:alert.textFields.firstObject.text];
                                                                      }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                
                [alert addAction:defaultAction];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
                
                break;
            }
            case 1: {
                switch (indexPath.row) {
                    case 0: {
                        //修改手机号
                        [self performSegueWithIdentifier:@"ModifyPhone" sender:nil];
                        break;
                    }
                    case 1: {
                        //发送修改邮箱验证码
                        
                        //修改邮箱地址
                        break;
                    }
                    case 2: {
                        //修改密码
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"修改密码"
                                                                                       message:nil
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            textField.placeholder = @"原密码";
                        }];
                        
                        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            textField.placeholder = @"新密码";
                        }];
                        
                        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            textField.placeholder = @"新密码";
                        }];
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {
                                                                                  NSString *oldPassword = alert.textFields.firstObject.text;
                                                                                  NSString *newPassword = alert.textFields[1].text;
                                                                                  NSString *secondNewPassword = alert.textFields.lastObject.text;
                                                                                  if ([newPassword isEqualToString:secondNewPassword]) {
                                                                                      [self modifyPassword:oldPassword newPassword:newPassword];
                                                                                  }else {
                                                                                      [BLStatusBar showTipMessageWithStatus:@"新密码不一致!!"];
                                                                                  }
                                                                              }];
                        
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                        
                        [alert addAction:defaultAction];
                        [alert addAction:cancelAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        break;
                    }
                    case 3: {
                       
                        break;
                    }
                        
                    default:
                        break;
                }
                break;
            }
                
            default:
                break;
        }
    }
}


- (void)logout {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
    [userDefault setUserId:nil];
    [userDefault setSessionId:nil];
}

- (void)backFirst {
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)getUserInfo {
    BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLAccount *account = delegate.account;
    if (userDefault.getUserId) {
        [account getUserInfo:@[userDefault.getUserId] completionHandler:^(BLGetUserInfoResult * _Nonnull result) {
            BLUserInfo *info = result.info[0];
            self.name = [info getNickname];
            self.userid = [info getUserid];
            self.iconUrl = [info getIconUrl];
            [self getPhoneOrEmail];
        }];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
        [self.navigationItem setRightBarButtonItem:rightButton];
    }else {
        [BLStatusBar showTipMessageWithStatus:@"未登录!"];
    }
}

- (void)getPhoneOrEmail {
    [[BLAccount sharedAccount] getUserPhoneAndEmailWithCompletionHandler:^(BLGetUserPhoneAndEmailResult * _Nonnull result) {
        self.email = result.email;
        self.phone = result.phone;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)modifyUserIcon:(NSString *)imagePath {
    [[BLAccount sharedAccount] modifyUserIcon:imagePath completionHandler:^(BLModifyUserIconResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [self getUserInfo];
                [BLStatusBar showTipMessageWithStatus:@"头像修改成功"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[result getMsg]?:@""];
            }
        });
    }];
}

- (void)modifyUserNickname:(NSString *)nickname {
    [[BLAccount sharedAccount] modifyUserNickname:nickname completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [self getUserInfo];
                [BLStatusBar showTipMessageWithStatus:@"昵称修改成功"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[result getMsg]?:@""];
            }
        });
    }];
}

- (void)modifyPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword {
    [[BLAccount sharedAccount] modifyPassword:oldPassword newPassword:newPassword completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [self getUserInfo];
                [BLStatusBar showTipMessageWithStatus:@"密码修改成功"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[result getMsg]?:@""];
            }
        });
    }];
}



@end
