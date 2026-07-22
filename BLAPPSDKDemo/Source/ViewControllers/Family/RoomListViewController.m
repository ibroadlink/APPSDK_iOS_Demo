//
//  RoomListViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "RoomListViewController.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>

@interface RoomListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *roomListTable;
@property (nonatomic, copy) NSArray *roomList;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation RoomListViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Rooms";
    self.roomList = @[];
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(addRoomButtonClick)];

    self.roomListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.roomListTable.delegate = self;
    self.roomListTable.dataSource = self;
    self.roomListTable.backgroundColor = [BLTheme backgroundColor];
    self.roomListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.roomListTable.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.roomListTable.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.roomListTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.roomListTable];
    [self.view addSubview:self.roomListTable];
    [self.roomListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self setupTableHeader];
    [self setupEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyRooms];
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Family Rooms";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Organize rooms in this home";
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

    self.roomListTable.tableHeaderView = header;
}

- (void)setupEmptyState {
    UILabel *empty = [[UILabel alloc] init];
    empty.text = @"No rooms yet\nTap + to add one";
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
    BOOL empty = self.roomList.count == 0;
    self.emptyLabel.hidden = !empty;
    self.roomListTable.hidden = empty;
}

- (void)addRoomButtonClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Family Room" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input new room name";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLSRoomInfo *info = [[BLSRoomInfo alloc] init];

        info.name = alertController.textFields.firstObject.text;
        info.action = @"add";
        info.order = self.roomList.count + 1;

        [self manageRoom:info];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)getFamilyRooms {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];

    [manager getFamilyRoomsWithCompletionHandler:^(BLSManageRoomResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];

            if ([result succeed]) {
                self.roomList = result.roomInfos;
                [self.roomListTable reloadData];
                [self updateEmptyState];
            } else {
                [self showErrorCode:result.status msg:result.msg];
                [self updateEmptyState];
            }
        });
    }];
}

- (void)manageRoom:(BLSRoomInfo *)info {
    NSArray *infos = @[info];
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];

    [manager manageRooms:infos completionHandler:^(BLSManageRoomResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];

            if ([result succeed]) {
                [self getFamilyRooms];
            } else {
                [self showErrorCode:result.status msg:result.msg];
            }
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ROOM_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
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

        UIImageView *icon = [[UIImageView alloc] init];
        icon.tag = 211;
        icon.tintColor = [BLTheme primaryColor];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        if (@available(iOS 13.0, *)) {
            icon.image = [UIImage systemImageNamed:@"square.split.2x1"];
        }
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
            make.center.equalTo(iconBg);
            make.width.height.mas_equalTo(24);
        }];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.top.equalTo(iconBg).offset(6);
            make.right.equalTo(card).offset(-14);
        }];
        [idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(nameLabel);
            make.top.equalTo(nameLabel.mas_bottom).offset(4);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        nameLabel = (UILabel *)[card viewWithTag:201];
        idLabel = (UILabel *)[card viewWithTag:202];
    }

    BLSRoomInfo *info = self.roomList[indexPath.row];
    nameLabel.text = info.name.length ? info.name : @"Untitled Room";
    idLabel.text = info.roomid ?: @"--";

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSRoomInfo *info = self.roomList[indexPath.row];
        info.action = @"del";
        [self manageRoom:info];
    }
}

@end
