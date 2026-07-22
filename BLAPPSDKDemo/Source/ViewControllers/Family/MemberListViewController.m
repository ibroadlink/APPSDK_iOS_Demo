//
//  MemberListViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "MemberListViewController.h"
#import "ShareFamilyViewController.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <BLLetAccount/BLLetAccount.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface MemberListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *memberTable;
@property (nonatomic, copy) NSArray<BLSFamilyMember *> *memberList;
@property (nonatomic, copy) NSArray<BLUserInfo *> *userInfo;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation MemberListViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Members";
    self.memberList = @[];
    self.userInfo = @[];
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                          target:self
                                                                                          action:@selector(shareFamilyButtonClick)];

    self.memberTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.memberTable.delegate = self;
    self.memberTable.dataSource = self;
    self.memberTable.backgroundColor = [BLTheme backgroundColor];
    self.memberTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.memberTable.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.memberTable.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.memberTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.memberTable];
    [self.view addSubview:self.memberTable];
    [self.memberTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self setupTableHeader];
    [self setupEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyMemberList];
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Family Members";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Invite and manage members in this home";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    subtitleLabel.numberOfLines = 2;
    [header addSubview:subtitleLabel];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [header addSubview:accent];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(header).offset(12);
        make.left.equalTo(header).offset(20);
        make.right.equalTo(header).offset(-20);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.left.right.equalTo(titleLabel);
    }];
    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(12);
        make.left.equalTo(titleLabel);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(3);
        make.bottom.equalTo(header).offset(-8);
    }];

    self.memberTable.tableHeaderView = header;
}

- (void)setupEmptyState {
    UILabel *empty = [[UILabel alloc] init];
    empty.text = @"No members yet\nTap the share button to invite";
    empty.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    empty.textColor = [BLTheme subtitleColor];
    empty.textAlignment = NSTextAlignmentCenter;
    empty.numberOfLines = 0;
    empty.hidden = YES;
    [self.view addSubview:empty];
    self.emptyLabel = empty;

    [empty mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
}

- (void)updateEmptyState {
    BOOL empty = self.memberList.count == 0;
    self.emptyLabel.hidden = !empty;
    self.memberTable.hidden = empty;
}

- (void)shareFamilyButtonClick {
    ShareFamilyViewController *vc = [ShareFamilyViewController viewController];
    [self.navigationController pushViewController:vc animated:YES];
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
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
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
                    [self updateEmptyState];
                });
            }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });
    }];
}

- (void)getFamilyMemberInviteQrcode {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    [manager getFamilyInvitedQrcodeWithCompletionHandler:^(BLSInvitedQrcodeResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });

        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showInviteQrcode:result.qrcode];
            });
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MEMBER_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UIImageView *avatar;
    UILabel *nameLabel;
    UILabel *useridLabel;
    UILabel *roleLabel;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        UIView *iconBg = [[UIView alloc] init];
        iconBg.backgroundColor = [BLTheme primaryLightColor];
        iconBg.layer.cornerRadius = 16;
        iconBg.tag = 210;
        [card addSubview:iconBg];

        avatar = [[UIImageView alloc] init];
        avatar.tag = 211;
        avatar.contentMode = UIViewContentModeScaleAspectFill;
        avatar.clipsToBounds = YES;
        avatar.layer.cornerRadius = 12;
        [iconBg addSubview:avatar];

        nameLabel = [[UILabel alloc] init];
        nameLabel.tag = 201;
        nameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        nameLabel.textColor = [BLTheme titleColor];
        [card addSubview:nameLabel];

        useridLabel = [[UILabel alloc] init];
        useridLabel.tag = 202;
        useridLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        useridLabel.textColor = [BLTheme subtitleColor];
        useridLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [card addSubview:useridLabel];

        roleLabel = [[UILabel alloc] init];
        roleLabel.tag = 203;
        roleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        roleLabel.textColor = [BLTheme primaryColor];
        [card addSubview:roleLabel];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(6);
            make.bottom.equalTo(cell.contentView).offset(-6);
            make.left.equalTo(cell.contentView).offset(16);
            make.right.equalTo(cell.contentView).offset(-16);
        }];
        [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.centerY.equalTo(card);
            make.width.height.mas_equalTo(52);
        }];
        [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(iconBg).insets(UIEdgeInsetsMake(4, 4, 4, 4));
        }];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.top.equalTo(iconBg).offset(4);
            make.right.equalTo(card).offset(-14);
        }];
        [useridLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(nameLabel);
            make.top.equalTo(nameLabel.mas_bottom).offset(4);
        }];
        [roleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(nameLabel);
            make.top.equalTo(useridLabel.mas_bottom).offset(2);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        avatar = (UIImageView *)[card viewWithTag:211];
        nameLabel = (UILabel *)[card viewWithTag:201];
        useridLabel = (UILabel *)[card viewWithTag:202];
        roleLabel = (UILabel *)[card viewWithTag:203];
    }

    BLSFamilyMember *member = self.memberList[indexPath.row];
    BLUserInfo *info = (indexPath.row < self.userInfo.count) ? self.userInfo[indexPath.row] : nil;

    nameLabel.text = info.nickname.length ? info.nickname : @"Unknown User";
    useridLabel.text = member.userid ?: @"--";
    roleLabel.text = [NSString stringWithFormat:@"Role %ld", (long)member.type];
    [avatar sd_setImageWithURL:[NSURL URLWithString:info.iconUrl]
              placeholderImage:[UIImage imageNamed:@"icon_me"]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96.f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSFamilyMember *member = self.memberList[indexPath.row];
        NSArray *userids = @[member.userid];

        BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
        [self showIndicatorOnWindow];

        [manager deleteFamilyMembersWithUserids:userids completionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
            });

            [self getFamilyMemberList];
        }];
    }
}

@end
