//
//  FamilyDetailViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/17.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyDetailViewController.h"
#import "OperateViewController.h"
#import "ACControlViewController.h"

#import "BLNewFamilyManager.h"

#import "BLStatusBar.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FamilyDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *familyIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyCreateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyCreateUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyMasterLabel;

- (IBAction)buttonClick:(UIButton *)sender;
- (IBAction)barButtonClick:(UIBarButtonItem *)sender;

@end

@implementation FamilyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubViews {
    
    if (self.familyInfo) {
        self.familyIdLabel.text = [@"FamilyId:" stringByAppendingString:self.familyInfo.familyid];
        self.familyNameLabel.text = [@"FamilyName:" stringByAppendingString:self.familyInfo.name];
        self.familyAddressLabel.text = [@"FamilyAddress:" stringByAppendingString:[NSString stringWithFormat:@"%@ %@ %@", self.familyInfo.countryCode, self.familyInfo.provinceCode, self.familyInfo.cityCode]];
        self.familyCreateTimeLabel.text = [@"FamilyCreateTime:" stringByAppendingString:self.familyInfo.createTime];
        self.familyCreateUserLabel.text = [@"FamilyCreateUser:" stringByAppendingString:self.familyInfo.createUser];
        self.familyMasterLabel.text = [@"FamilyMaster:" stringByAppendingString:self.familyInfo.master];
    }
    
    //获取房间列表
    [self queryRoomList];
}

#pragma mark - Navigation
- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
            [self modifyFamilyInfo];
            break;
        case 101:
            [self showMemberListView];
            break;
        case 102:
            [self showRoomListView];
            break;
        case 103:
            [self showEndpointListView];
            break;
        case 104:
            [self showSceneListView];
            break;
        default:
            break;
    }
    
}

- (IBAction)barButtonClick:(UIBarButtonItem *)sender {
    
    
}

- (void)modifyFamilyInfo {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Modify Family Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input new family name";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alertController.textFields.firstObject.text;
        BLSFamilyInfo *info = self.familyInfo;
        info.name = name;
        
        [self showIndicatorOnWindow];
        BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
        [manager modifyFamilyInfo:info completionHandler:^(BLBaseResult * _Nonnull result) {
            if ([result succeed]) {
                self.familyInfo.name = name;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self initSubViews];
            });
        }];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)queryRoomList {
    [[BLNewFamilyManager sharedFamily] getFamilyRoomsWithCompletionHandler:^(BLSManageRoomResult * _Nonnull result) {
        NSLog(@"Query Rooms Msg: %@", result.msg);
    }];
}

- (void)showMemberListView {
    [self performSegueWithIdentifier:@"MemberListView" sender:nil];
}

- (void)showRoomListView {
    [self performSegueWithIdentifier:@"RoomListView" sender:nil];
}

- (void)showEndpointListView {
    [self performSegueWithIdentifier:@"EndpointListView" sender:nil];
}

- (void)showSceneListView {
    [self performSegueWithIdentifier:@"SceneListView" sender:nil];
}

- (void)setFamilyInfo:(BLSFamilyInfo *)familyInfo {
    _familyInfo = familyInfo;
    [BLNewFamilyManager sharedFamily].currentFamilyInfo = familyInfo;
}

@end
