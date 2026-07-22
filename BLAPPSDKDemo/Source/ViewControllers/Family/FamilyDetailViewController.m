//
//  FamilyDetailViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/17.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyDetailViewController.h"
#import "MemberListViewController.h"
#import "RoomListViewController.h"
#import "EndpointListViewController.h"
#import "SceneListController.h"
#import "GroupDeviceViewController.h"
#import "BLFamilyDefult.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, FamilyDetailAction) {
    FamilyDetailActionModify = 100,
    FamilyDetailActionMembers,
    FamilyDetailActionRooms,
    FamilyDetailActionEndpoints,
    FamilyDetailActionScenes,
    FamilyDetailActionGroupDevices,
};

@interface FamilyDetailViewController ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIStackView *infoRows;

@end

@implementation FamilyDetailViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Family Detail";
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self buildUI];
    [self refreshInfoCard];
    [self queryRoomList];
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    scroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    UIView *infoCard = [[UIView alloc] init];
    [BLTheme styleCardView:infoCard];
    [content addSubview:infoCard];

    UIView *iconBg = [[UIView alloc] init];
    iconBg.backgroundColor = [BLTheme primaryLightColor];
    iconBg.layer.cornerRadius = 18;
    [infoCard addSubview:iconBg];

    UIImageView *icon = [[UIImageView alloc] init];
    icon.tintColor = [BLTheme primaryColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        icon.image = [UIImage systemImageNamed:@"house.fill"];
    }
    [iconBg addSubview:icon];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.nameLabel.textColor = [BLTheme titleColor];
    [infoCard addSubview:self.nameLabel];

    self.infoRows = [[UIStackView alloc] init];
    self.infoRows.axis = UILayoutConstraintAxisVertical;
    self.infoRows.spacing = 8;
    [infoCard addSubview:self.infoRows];

    UILabel *opsTitle = [[UILabel alloc] init];
    opsTitle.text = @"Manage";
    opsTitle.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    opsTitle.textColor = [BLTheme titleColor];
    [content addSubview:opsTitle];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [content addSubview:accent];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    [content addSubview:stack];

    NSArray *items = @[
        @{@"title": @"Modify Info", @"desc": @"Rename this family", @"symbol": @"pencil", @"tag": @(FamilyDetailActionModify)},
        @{@"title": @"Members", @"desc": @"Invite and manage members", @"symbol": @"person.2.fill", @"tag": @(FamilyDetailActionMembers)},
        @{@"title": @"Rooms", @"desc": @"Organize rooms in this home", @"symbol": @"square.split.2x1", @"tag": @(FamilyDetailActionRooms)},
        @{@"title": @"Endpoints", @"desc": @"Devices bound to this family", @"symbol": @"cpu", @"tag": @(FamilyDetailActionEndpoints)},
        @{@"title": @"Scenes", @"desc": @"Scene automation shortcuts", @"symbol": @"sparkles", @"tag": @(FamilyDetailActionScenes)},
        @{@"title": @"Group Devices", @"desc": @"Virtual / group device tools", @"symbol": @"rectangle.3.group", @"tag": @(FamilyDetailActionGroupDevices)},
    ];
    for (NSDictionary *item in items) {
        UIButton *card = [self menuCardWithItem:item];
        [stack addArrangedSubview:card];
        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(76);
        }];
    }

    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scroll);
        make.width.equalTo(scroll);
    }];
    [infoCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(12);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
    }];
    [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(infoCard).offset(14);
        make.width.height.mas_equalTo(44);
    }];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBg);
        make.width.height.mas_equalTo(22);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconBg.mas_right).offset(12);
        make.centerY.equalTo(iconBg);
        make.right.equalTo(infoCard).offset(-14);
    }];
    [self.infoRows mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconBg.mas_bottom).offset(14);
        make.left.equalTo(infoCard).offset(14);
        make.right.equalTo(infoCard).offset(-14);
        make.bottom.equalTo(infoCard).offset(-14);
    }];
    [opsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoCard.mas_bottom).offset(24);
        make.left.equalTo(content).offset(20);
        make.right.equalTo(content).offset(-20);
    }];
    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(opsTitle.mas_bottom).offset(10);
        make.left.equalTo(opsTitle);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(3);
    }];
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accent.mas_bottom).offset(16);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
        make.bottom.equalTo(content).offset(-24);
    }];
}

- (UIButton *)menuCardWithItem:(NSDictionary *)item {
    UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
    [BLTheme styleCardView:card];
    card.tag = [item[@"tag"] integerValue];
    [card addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];

    UIView *iconBg = [[UIView alloc] init];
    iconBg.userInteractionEnabled = NO;
    iconBg.backgroundColor = [BLTheme primaryLightColor];
    iconBg.layer.cornerRadius = 14;
    [card addSubview:iconBg];

    UIImageView *icon = [[UIImageView alloc] init];
    icon.userInteractionEnabled = NO;
    icon.tintColor = [BLTheme primaryColor];
    if (@available(iOS 13.0, *)) {
        icon.image = [UIImage systemImageNamed:item[@"symbol"]];
    }
    [iconBg addSubview:icon];

    UILabel *title = [[UILabel alloc] init];
    title.userInteractionEnabled = NO;
    title.text = item[@"title"];
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    title.textColor = [BLTheme titleColor];
    [card addSubview:title];

    UILabel *desc = [[UILabel alloc] init];
    desc.userInteractionEnabled = NO;
    desc.text = item[@"desc"];
    desc.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    desc.textColor = [BLTheme subtitleColor];
    [card addSubview:desc];

    UIImageView *chevron = [[UIImageView alloc] init];
    chevron.userInteractionEnabled = NO;
    chevron.tintColor = [BLTheme subtitleColor];
    if (@available(iOS 13.0, *)) {
        chevron.image = [UIImage systemImageNamed:@"chevron.right"];
    }
    [card addSubview:chevron];

    [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(card).offset(14);
        make.centerY.equalTo(card);
        make.width.height.mas_equalTo(40);
    }];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBg);
        make.width.height.mas_equalTo(20);
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconBg.mas_right).offset(12);
        make.top.equalTo(iconBg).offset(2);
        make.right.equalTo(chevron.mas_left).offset(-8);
    }];
    [desc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(title);
        make.top.equalTo(title.mas_bottom).offset(2);
    }];
    [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(card).offset(-14);
        make.centerY.equalTo(card);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(14);
    }];
    return card;
}

- (UIView *)infoRowWithTitle:(NSString *)title value:(NSString *)value {
    UIView *row = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    titleLabel.textColor = [BLTheme subtitleColor];
    [row addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value.length ? value : @"--";
    valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightMedium];
    valueLabel.textColor = [BLTheme titleColor];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.numberOfLines = 2;
    valueLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [row addSubview:valueLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(row);
        make.width.mas_equalTo(72);
    }];
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(8);
        make.right.top.bottom.equalTo(row);
    }];
    return row;
}

- (void)refreshInfoCard {
    for (UIView *sub in self.infoRows.arrangedSubviews) {
        [self.infoRows removeArrangedSubview:sub];
        [sub removeFromSuperview];
    }
    self.nameLabel.text = self.familyInfo.name.length ? self.familyInfo.name : @"Untitled Family";
    NSString *address = [NSString stringWithFormat:@"%@ %@ %@",
                         self.familyInfo.countryCode ?: @"",
                         self.familyInfo.provinceCode ?: @"",
                         self.familyInfo.cityCode ?: @""];
    NSArray *items = @[
        @[@"Family ID", self.familyInfo.familyid ?: @"--"],
        @[@"Address", [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]],
        @[@"Created", self.familyInfo.createTime ?: @"--"],
        @[@"Creator", self.familyInfo.createUser ?: @"--"],
        @[@"Master", self.familyInfo.master ?: @"--"],
    ];
    for (NSArray *item in items) {
        [self.infoRows addArrangedSubview:[self infoRowWithTitle:item[0] value:item[1]]];
    }
}

- (void)menuAction:(UIButton *)sender {
    switch (sender.tag) {
        case FamilyDetailActionModify:
            [self modifyFamilyInfo];
            break;
        case FamilyDetailActionMembers:
            [self.navigationController pushViewController:[MemberListViewController viewController] animated:YES];
            break;
        case FamilyDetailActionRooms:
            [self.navigationController pushViewController:[RoomListViewController viewController] animated:YES];
            break;
        case FamilyDetailActionEndpoints:
            [self.navigationController pushViewController:[EndpointListViewController viewController] animated:YES];
            break;
        case FamilyDetailActionScenes:
            [self.navigationController pushViewController:[SceneListController viewController] animated:YES];
            break;
        case FamilyDetailActionGroupDevices:
            [self.navigationController pushViewController:[GroupDeviceViewController viewController] animated:YES];
            break;
        default:
            break;
    }
}

- (void)modifyFamilyInfo {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Modify Family Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.familyInfo.name ?: @"";
        textField.placeholder = @"Please input new family name";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alertController.textFields.firstObject.text;
        BLSFamilyInfo *info = self.familyInfo;
        info.name = name;

        [self showIndicatorOnWindow];
        BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
        [manager modifyFamilyInfo:info completionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                if ([result succeed]) {
                    self.familyInfo.name = name;
                    [self refreshInfoCard];
                } else {
                    [self showErrorCode:result.error msg:result.msg];
                }
            });
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)queryRoomList {
    [[BLSFamilyManager sharedFamily] getFamilyRoomsWithCompletionHandler:^(BLSManageRoomResult * _Nonnull result) {
        if (![result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorCode:result.error msg:result.msg];
            });
        }
    }];
}

- (void)setFamilyInfo:(BLSFamilyInfo *)familyInfo {
    _familyInfo = familyInfo;
    [BLFamilyDefult sharedFamily].currentFamilyInfo = familyInfo;
    if (self.isViewLoaded) {
        [self refreshInfoCard];
    }
}

@end
