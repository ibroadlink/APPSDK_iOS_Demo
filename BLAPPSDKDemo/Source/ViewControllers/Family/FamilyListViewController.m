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
#import "DropDownList.h"
#import "BLTheme.h"
#import "Tools.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface FamilyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<BLSFamilyInfo *> *familyInfos;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIView *tableHeader;

@end

@implementation FamilyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Family";
    self.familyInfos = @[];
    self.view.backgroundColor = [BLTheme backgroundColor];
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
    [self setupTableHeader];
    [self setupEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryFamilyBaseList];
}

+ (instancetype)viewController {
    return [Tools viewControllerFromMainStoryboard:self];
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

    self.tableHeader = header;
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
    return self.familyInfos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FAMILY_LIST_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.clipsToBounds = NO;
    cell.layer.masksToBounds = NO;

    cell.contentView.backgroundColor = [BLTheme cardColor];
    cell.contentView.layer.cornerRadius = [BLTheme cardCornerRadius];
    cell.contentView.layer.masksToBounds = YES;

    cell.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    cell.layer.shadowOpacity = 0.07;
    cell.layer.shadowRadius = 10;
    cell.layer.shadowOffset = CGSizeMake(0, 4);

    BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.section];
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:100];
    headImageView.contentMode = UIViewContentModeScaleAspectFill;
    headImageView.layer.cornerRadius = 12;
    headImageView.layer.masksToBounds = YES;
    headImageView.backgroundColor = [BLTheme primaryLightColor];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:familyInfo.iconpath]
                     placeholderImage:[UIImage imageNamed:@"default_family"]];

    UILabel *familyNameLabel = (UILabel *)[cell viewWithTag:101];
    familyNameLabel.text = familyInfo.name.length ? familyInfo.name : @"Untitled Family";
    familyNameLabel.textColor = [BLTheme titleColor];
    familyNameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];

    UILabel *familyIdLabel = (UILabel *)[cell viewWithTag:102];
    familyIdLabel.text = familyInfo.familyid;
    familyIdLabel.textColor = [BLTheme subtitleColor];
    familyIdLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];

    UIImageView *chevron = [cell.contentView viewWithTag:901];
    if (!chevron) {
        chevron = [[UIImageView alloc] init];
        chevron.tag = 901;
        chevron.tintColor = [BLTheme subtitleColor];
        if (@available(iOS 13.0, *)) {
            chevron.image = [UIImage systemImageNamed:@"chevron.right"];
        }
        [cell.contentView addSubview:chevron];
        [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView).offset(-16);
            make.centerY.equalTo(cell.contentView);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(14);
        }];
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 14;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *spacer = [[UIView alloc] init];
    spacer.backgroundColor = [UIColor clearColor];
    return spacer;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat margin = 16.0;
    CGRect frame = UIEdgeInsetsInsetRect(cell.bounds, UIEdgeInsetsMake(0, margin, 0, margin));
    cell.contentView.frame = frame;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:[BLTheme cardCornerRadius]].CGPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.section];
    [self performSegueWithIdentifier:@"FamilyDetailView" sender:familyInfo];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.section];
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

#pragma mark - private method

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

- (IBAction)addFamilyBtnClick:(UIBarButtonItem *)sender {
    NSArray *keyList = @[@"创建家庭", @"加入家庭"];
    CGFloat drop_X = CGRectGetMaxX(self.navigationController.navigationBar.frame) - 100;
    CGFloat drop_Y = 5;
    CGFloat drop_W = 100;
    CGFloat drop_H = keyList.count * 40 + 10;

    DropDownList *dropList = [[DropDownList alloc] initWithFrame:CGRectMake(drop_X, drop_Y, drop_W, drop_H) dataArray:keyList onTheView:self.view];
    dropList.myBlock = ^(NSInteger row, NSString *title) {
        if (row == 0) {
            [self performSegueWithIdentifier:@"CreateFamilyView" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"JoinFamilyView" sender:nil];
        }
    };
    [self.view addSubview:dropList];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FamilyDetailView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[FamilyDetailViewController class]]) {
            [BLSFamilyManager sharedFamily].familyid = ((BLSFamilyInfo *)sender).familyid;
            FamilyDetailViewController *vc = (FamilyDetailViewController *)target;
            vc.familyInfo = (BLSFamilyInfo *)sender;
        }
    }
}

@end
