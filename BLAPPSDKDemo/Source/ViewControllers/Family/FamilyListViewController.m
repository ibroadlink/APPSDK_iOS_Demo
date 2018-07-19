//
//  FamilyListViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyListViewController.h"
#import "FamilyDetailViewController.h"
#import "BLStatusBar.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DropDownList.h"

@interface FamilyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)NSArray<BLFamilyInfoBase *> *familyIds;
@property (nonatomic, strong)BLFamilyController *familyController;
@property (nonatomic, strong)NSArray<BLUserInfo *> *infoArray;
@end

@implementation FamilyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _infoArray = [NSArray array];
    _familyController = [BLFamilyController sharedManager];
    
    self.familyListTableView.delegate = self;
    self.familyListTableView.dataSource = self;
    [self setExtraCellLineHidden:self.familyListTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryFamilyIdListInAccount];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.familyIds.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"FAMILY_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    BLFamilyInfo *familyInfo = self.familyIds[indexPath.section].familyInfo;
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:100];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:familyInfo.familyIconPath] placeholderImage:[UIImage imageNamed:@"default_family"]];
    
    UILabel *familyNameLabel = (UILabel *)[cell viewWithTag:101];
    familyNameLabel.text = familyInfo.familyName;
    
    UILabel *nicknameLabel = (UILabel *)[cell viewWithTag:102];
    if (_infoArray && [_infoArray isKindOfClass:[NSArray class]] && [_infoArray count] > 0) {
        NSString *userid = self.familyIds[indexPath.section].createUser;
        for (BLUserInfo *userinfo in self.infoArray) {
            if ([userid isEqualToString:userinfo.userid]) {
                nicknameLabel.text = [NSString stringWithFormat:@"创建者：%@",userinfo.nickname];
            }
        }
        
    }
    
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLFamilyInfo *familyInfo = self.familyIds[indexPath.section].familyInfo;
    NSString *familyId = familyInfo.familyId;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"FamilyDetailView" sender:familyId];
    });
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLFamilyInfo *familyInfo = self.familyIds[indexPath.row].familyInfo;
        NSString *delId = familyInfo.familyId;
        NSString *delVersion = familyInfo.familyVersion;
        
        [_familyController delFamilyWithFamilyId:delId familyVersion:delVersion completionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([result succeed]) {
                    [BLStatusBar showTipMessageWithStatus:@"Delete Family success!"];
                    [self queryFamilyIdListInAccount];
                } else {
                    NSLog(@"ERROR :%@", result.msg);
                    [BLStatusBar showTipMessageWithStatus:[@"Delete Family failed! " stringByAppendingString:result.msg]];
                }
            });
        }];
    }
}

#pragma mark - private method
- (void)queryFamilyIdListInAccount {
    NSLog(@"userid:%@------loginSession:%@",_familyController.loginUserid,_familyController.loginSession);
    [_familyController queryLoginUserFamilyBaseInfoListWithCompletionHandler:^(BLFamilyBaseInfoListResult * _Nonnull result) {
        if ([result succeed]) {
            self.familyIds = result.infoList;
            [self getUserInfo:self.familyIds];
            
        } else {
            NSLog(@"error:%ld msg:%@", (long)result.error, result.msg);
            [BLStatusBar showTipMessageWithStatus:result.msg];
        }
    }];
    
//    [_familyController queryLoginUserFamilyIdListWithCompletionHandler:^(BLFamilyIdListGetResult * _Nonnull result) {
//        if ([result succeed]) {
//            self.familyIds = result.idList;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.familyListTableView reloadData];
//            });
//        } else {
//            NSLog(@"error:%ld msg:%@", (long)result.error, result.msg);
//            [BLStatusBar showTipMessageWithStatus:result.msg];
//        }
//    }];
}

- (void)getUserInfo:(NSArray *)familyIds {
    NSMutableArray *useridList = [NSMutableArray arrayWithCapacity:0];
    for (BLFamilyInfoBase *infoBase in familyIds) {
        NSString *userid = infoBase.createUser;
        [useridList addObject:userid];
    }
    __weak typeof(self) weakSelf = self;
    [[BLAccount sharedAccount] getUserInfo:useridList completionHandler:^(BLGetUserInfoResult * _Nonnull result) {
        NSArray<BLUserInfo *> *infoList = result.info;
        if (infoList && [infoList isKindOfClass:[NSArray class]] && [infoList count] > 0) {
            weakSelf.infoArray = infoList;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.familyListTableView reloadData];
            });
        }
    }];
}

- (IBAction)addFamilyBtnClick:(UIBarButtonItem *)sender {
    NSArray *keyList = @[@"创建家庭",@"加入家庭"];
    CGFloat drop_X = CGRectGetMaxX(self.navigationController.navigationBar.frame) - 100;
    CGFloat drop_Y = 5;
    CGFloat drop_W = 100;
    CGFloat drop_H = keyList.count * 40 + 10;
    
    DropDownList *dropList = [[DropDownList alloc] initWithFrame:CGRectMake(drop_X, drop_Y, drop_W, drop_H) dataArray:keyList onTheView:self.view] ;
    
    dropList.myBlock = ^(NSInteger row,NSString *title)
    {
        if (row == 0) {
            [self performSegueWithIdentifier:@"CreateFamilyView" sender:nil];
        }else {
            [self performSegueWithIdentifier:@"JoinFamilyView" sender:nil];
        }
    };
    
    [self.view addSubview:dropList];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FamilyDetailView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[FamilyDetailViewController class]]) {
            FamilyDetailViewController* vc = (FamilyDetailViewController *)target;
            vc.familyId = (NSString *)sender;
        }
    }
}


@end
