//
//  FamilyListViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyListViewController.h"
#import "FamilyDetailViewController.h"
#import "CreateFamilyViewController.h"
#import "JoinFamilyViewController.h"
#import "BLStatusBar.h"
#import "DropDownList.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface FamilyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *familyListTableView;
@property (nonatomic, strong) NSArray<BLSFamilyInfo *> *familyInfos;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation FamilyListViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Family";
    self.familyInfos = @[];
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(addFamilyBtnClick)];

    self.familyListTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.familyListTableView.delegate = self;
    self.familyListTableView.dataSource = self;
    self.familyListTableView.backgroundColor = [BLTheme backgroundColor];
    self.familyListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.familyListTableView.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.familyListTableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.familyListTableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.familyListTableView];
    [self.view addSubview:self.familyListTableView];
    [self.familyListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self setupTableHeader];
    [self setupEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryFamilyBaseList];
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"My Homes";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Select a family to manage rooms and devices";
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

    self.familyListTableView.tableHeaderView = header;
}

- (void)setupEmptyState {
    UILabel *empty = [[UILabel alloc] init];
    empty.text = @"No family yet\nTap + to create or join one";
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
    BOOL empty = self.familyInfos.count == 0;
    self.emptyLabel.hidden = !empty;
    self.familyListTableView.hidden = empty;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.familyInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FAMILY_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UIImageView *icon;
    UILabel *nameLabel;
    UILabel *idLabel;

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

        icon = [[UIImageView alloc] init];
        icon.tag = 211;
        icon.contentMode = UIViewContentModeScaleAspectFill;
        icon.clipsToBounds = YES;
        icon.layer.cornerRadius = 12;
        [iconBg addSubview:icon];

        nameLabel = [[UILabel alloc] init];
        nameLabel.tag = 201;
        nameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        nameLabel.textColor = [BLTheme titleColor];
        [card addSubview:nameLabel];

        idLabel = [[UILabel alloc] init];
        idLabel.tag = 202;
        idLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        idLabel.textColor = [BLTheme subtitleColor];
        idLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [card addSubview:idLabel];

        UIImageView *chevron = [[UIImageView alloc] init];
        chevron.tintColor = [BLTheme subtitleColor];
        if (@available(iOS 13.0, *)) {
            chevron.image = [UIImage systemImageNamed:@"chevron.right"];
        }
        [card addSubview:chevron];

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
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(iconBg).insets(UIEdgeInsetsMake(4, 4, 4, 4));
        }];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.top.equalTo(iconBg).offset(6);
            make.right.equalTo(chevron.mas_left).offset(-8);
        }];
        [idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(nameLabel);
            make.top.equalTo(nameLabel.mas_bottom).offset(4);
        }];
        [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(14);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        icon = (UIImageView *)[card viewWithTag:211];
        nameLabel = (UILabel *)[card viewWithTag:201];
        idLabel = (UILabel *)[card viewWithTag:202];
    }

    BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.row];
    nameLabel.text = familyInfo.name.length ? familyInfo.name : @"Untitled Family";
    idLabel.text = familyInfo.familyid ?: @"--";
    [icon sd_setImageWithURL:[NSURL URLWithString:familyInfo.iconpath]
            placeholderImage:[UIImage imageNamed:@"default_family"]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.row];
    [BLSFamilyManager sharedFamily].familyid = familyInfo.familyid;
    FamilyDetailViewController *vc = [FamilyDetailViewController viewController];
    vc.familyInfo = familyInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.row];
        BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];

        [self showIndicatorOnWindow];
        [manager delFamilyWithFamilyid:familyInfo.familyid completionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                if ([result succeed]) {
                    [BLStatusBar showTipMessageWithStatus:@"Delete Family success!"];
                    [self queryFamilyBaseList];
                } else {
                    [self showErrorCode:result.error msg:result.msg];
                }
            });
        }];
    }
}

#pragma mark - private

- (void)queryFamilyBaseList {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
        [manager queryFamilyBaseInfoListWithCompletionHandler:^(BLSFamilyListResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                if ([result succeed]) {
                    self.familyInfos = result.familyList ?: @[];
                    [self.familyListTableView reloadData];
                    [self updateEmptyState];
                } else {
                    [self showErrorCode:result.error msg:result.msg];
                    [self updateEmptyState];
                }
            });
        }];
    });
}

- (void)addFamilyBtnClick {
    NSArray *keyList = @[@"Create Family", @"Join Family"];
    CGFloat drop_X = CGRectGetMaxX(self.navigationController.navigationBar.frame) - 120;
    CGFloat drop_Y = 5;
    CGFloat drop_W = 120;
    CGFloat drop_H = keyList.count * 40 + 10;

    DropDownList *dropList = [[DropDownList alloc] initWithFrame:CGRectMake(drop_X, drop_Y, drop_W, drop_H) dataArray:keyList onTheView:self.view];
    dropList.myBlock = ^(NSInteger row, NSString *title) {
        UIViewController *vc = (row == 0)
            ? [CreateFamilyViewController viewController]
            : [JoinFamilyViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    };
    [self.view addSubview:dropList];
}

@end
