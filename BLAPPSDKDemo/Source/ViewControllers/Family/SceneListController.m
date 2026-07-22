//
//  SceneListController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/11.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "SceneListController.h"
#import "SceneAddController.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <BLLetBase/BLLetBase.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface SceneListController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *sceneList;
@property (nonatomic, strong) UITableView *sceneListTable;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation SceneListController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scenes";
    self.sceneList = @[];
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(addSceneButtonClick)];

    self.sceneListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.sceneListTable.delegate = self;
    self.sceneListTable.dataSource = self;
    self.sceneListTable.backgroundColor = [BLTheme backgroundColor];
    self.sceneListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sceneListTable.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.sceneListTable.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.sceneListTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.sceneListTable];
    [self.view addSubview:self.sceneListTable];
    [self.sceneListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self setupTableHeader];
    [self setupEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryAllSceneList];
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Family Scenes";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Scene automation shortcuts";
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

    self.sceneListTable.tableHeaderView = header;
}

- (void)setupEmptyState {
    UILabel *empty = [[UILabel alloc] init];
    empty.text = @"No scenes yet\nTap + to create one";
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
    BOOL empty = [BLCommonTools isEmptyArray:self.sceneList];
    self.emptyLabel.hidden = !empty;
    self.sceneListTable.hidden = empty;
}

- (void)addSceneButtonClick {
    SceneAddController *vc = [SceneAddController viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)queryAllSceneList {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];

    [self showIndicatorOnWindow];
    [manager getScenesWithCompletionHandler:^(BLSQueryScenesResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                self.sceneList = result.scenes;
                [self.sceneListTable reloadData];
                [self updateEmptyState];
            } else {
                [self showErrorCode:result.status msg:result.msg];
                [self updateEmptyState];
            }
        });
    }];
}

- (void)delScene:(BLSSceneInfo *)info {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];

    [self showIndicatorOnWindow];
    [manager delScene:info.sceneId completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                [self queryAllSceneList];
            } else {
                [self showErrorCode:result.error msg:result.msg];
            }
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([BLCommonTools isEmptyArray:self.sceneList]) {
        return 0;
    } else {
        return self.sceneList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SCENE_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UIImageView *icon;
    UILabel *nameLabel;
    UILabel *sceneIdLabel;
    UILabel *orderLabel;

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
        icon.contentMode = UIViewContentModeScaleAspectFit;
        [iconBg addSubview:icon];

        nameLabel = [[UILabel alloc] init];
        nameLabel.tag = 201;
        nameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        nameLabel.textColor = [BLTheme titleColor];
        [card addSubview:nameLabel];

        sceneIdLabel = [[UILabel alloc] init];
        sceneIdLabel.tag = 202;
        sceneIdLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        sceneIdLabel.textColor = [BLTheme subtitleColor];
        sceneIdLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [card addSubview:sceneIdLabel];

        orderLabel = [[UILabel alloc] init];
        orderLabel.tag = 203;
        orderLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        orderLabel.textColor = [BLTheme primaryColor];
        [card addSubview:orderLabel];

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
            make.edges.equalTo(iconBg).insets(UIEdgeInsetsMake(8, 8, 8, 8));
        }];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.top.equalTo(iconBg).offset(4);
            make.right.equalTo(card).offset(-14);
        }];
        [sceneIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(nameLabel);
            make.top.equalTo(nameLabel.mas_bottom).offset(4);
        }];
        [orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(nameLabel);
            make.top.equalTo(sceneIdLabel.mas_bottom).offset(2);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        icon = (UIImageView *)[card viewWithTag:211];
        nameLabel = (UILabel *)[card viewWithTag:201];
        sceneIdLabel = (UILabel *)[card viewWithTag:202];
        orderLabel = (UILabel *)[card viewWithTag:203];
    }

    BLSSceneInfo *info = self.sceneList[indexPath.row];
    nameLabel.text = info.friendlyName.length ? info.friendlyName : @"Untitled Scene";
    sceneIdLabel.text = info.sceneId ?: @"--";
    orderLabel.text = [NSString stringWithFormat:@"Order %ld", (long)info.order];
    [icon sd_setImageWithURL:[NSURL URLWithString:info.icon]
            placeholderImage:[UIImage imageNamed:@"default_module_icon"]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96.f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSSceneInfo *info = self.sceneList[indexPath.row];
        [self delScene:info];
    }
}

@end
