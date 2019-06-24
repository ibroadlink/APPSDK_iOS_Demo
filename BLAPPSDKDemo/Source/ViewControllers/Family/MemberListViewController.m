//
//  MemberListViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "MemberListViewController.h"
#import "BLNewFamilyManager.h"
#import "ShareFamilyViewController.h"
#import <BLLetAccount/BLLetAccount.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface MemberListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *memberTable;
- (IBAction)barButtonClick:(UIBarButtonItem *)sender;

@property (nonatomic, copy)NSArray<BLSFamilyMember *> *memberList;
@property (nonatomic, copy)NSArray<BLUserInfo *> *userInfo;

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.memberList = [[NSArray alloc] init];
    self.memberTable.delegate = self;
    self.memberTable.dataSource = self;
    [self setExtraCellLineHidden:self.memberTable];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyMemberList];
}

- (void)showInviteQrcode:(NSString *)qrcode {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Family Invite Qrcode" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = qrcode;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)getFamilyMemberList {
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    [manager getFamilyMembersWithCompletionHandler:^(BLSFamilyMembersResult * _Nonnull result) {
        if ([result succeed]) {
            self.memberList = result.memberList;
            NSMutableArray *userids = [NSMutableArray arrayWithCapacity:self.memberList.count];
            for (int i = 0; i < self.memberList.count; i++) {
                BLSFamilyMember *member = self.memberList[i];
                [userids addObject:member.userid];
            }
            
            [[BLAccount sharedAccount] getUserInfo:userids completionHandler:^(BLGetUserInfoResult * _Nonnull result) {
                if ([result succeed]) {
                    self.userInfo = result.info;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.memberTable reloadData];
                });
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });
    }];
}

- (void)getFamilyMemberInviteQrcode {
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    [manager getFamilyInvitedQrcodeWithCompletionHandler:^(BLSInvitedQrcodeResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });
        
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showInviteQrcode: result.qrcode];
            });
        }
    }];
    
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"MEMBER_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BLSFamilyMember *member = self.memberList[indexPath.row];
    BLUserInfo *info = self.userInfo[indexPath.row];
    
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:100];
    headImageView.contentMode = UIViewContentModeCenter;
    [headImageView sd_setImageWithURL:[NSURL URLWithString:info.iconUrl] placeholderImage:[UIImage imageNamed:@"icon_me"]];
    
    UILabel *useridLabel = (UILabel *)[cell viewWithTag:101];
    useridLabel.font = [UIFont systemFontOfSize:12];
    useridLabel.text = member.userid;
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:102];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.text = [@"UserName:" stringByAppendingString:info.nickname ? info.nickname : @"name"];
    
    UILabel *roleLabel = (UILabel *)[cell viewWithTag:103];
    roleLabel.font = [UIFont systemFontOfSize:12];
    roleLabel.text = [NSString stringWithFormat:@"Role: %ld", (long)member.type];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSFamilyMember *member = self.memberList[indexPath.row];
        NSArray *userids = @[member.userid];
        
        BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
        [self showIndicatorOnWindow];
        
        [manager deleteFamilyMembersWithUserids:userids completionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
            });
            
            [self getFamilyMemberList];
            
        }];
    }
}


- (IBAction)barButtonClick:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"ShareFamilyView" sender:nil];
//    [self getFamilyMemberInviteQrcode];
}


@end
