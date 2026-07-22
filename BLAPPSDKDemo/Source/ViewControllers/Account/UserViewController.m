//
//  UserViewController.m
//  BLAPPSDKDemo
//

#import "UserViewController.h"
#import "ModifyPhoneViewController.h"
#import "ModifyEmailViewController.h"
#import "BLUserDefaults.h"
#import "BLSystemImage.h"
#import "BLStatusBar.h"
#import "Tools.h"
#import "UIImage+BDL.h"
#import "BLTheme.h"
#import <BLLetAccount/BLLetAccount.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

@interface UserViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;

@property (nonatomic, strong) UIView *profileHeader;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@end

@implementation UserViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Profile";
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Home"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(viewBack)];

    [self buildTableView];
    [self buildProfileHeader];
    [self getUserInfo];
}

- (void)buildTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorColor = [BLTheme separatorColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 52;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LogoutCell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)buildProfileHeader {
    self.profileHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 180)];
    self.profileHeader.backgroundColor = [UIColor clearColor];

    UIView *card = [[UIView alloc] init];
    [BLTheme styleCardView:card];
    [self.profileHeader addSubview:card];

    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.backgroundColor = [BLTheme primaryLightColor];
    self.avatarView.layer.cornerRadius = 36;
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.layer.borderWidth = 2;
    self.avatarView.layer.borderColor = [BLTheme primaryLightColor].CGColor;
    self.avatarView.userInteractionEnabled = YES;
    [self.avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAvatar)]];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:28 weight:UIImageSymbolWeightMedium];
        self.avatarView.image = [UIImage systemImageNamed:@"person.fill" withConfiguration:cfg];
        self.avatarView.tintColor = [BLTheme primaryColor];
    }
    [card addSubview:self.avatarView];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    self.nameLabel.textColor = [BLTheme titleColor];
    self.nameLabel.text = @"—";
    [card addSubview:self.nameLabel];

    self.userIdLabel = [[UILabel alloc] init];
    self.userIdLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.userIdLabel.textColor = [BLTheme subtitleColor];
    self.userIdLabel.text = @"ID —";
    self.userIdLabel.numberOfLines = 2;
    [card addSubview:self.userIdLabel];

    UILabel *hint = [[UILabel alloc] init];
    hint.text = @"Tap avatar to change";
    hint.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    hint.textColor = [BLTheme subtitleColor];
    [card addSubview:hint];

    [card mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileHeader).offset(12);
        make.left.equalTo(self.profileHeader).offset(16);
        make.right.equalTo(self.profileHeader).offset(-16);
        make.bottom.equalTo(self.profileHeader).offset(-8);
    }];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(card).offset(20);
        make.centerY.equalTo(card);
        make.width.height.mas_equalTo(72);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(16);
        make.right.equalTo(card).offset(-16);
        make.top.equalTo(card).offset(36);
    }];
    [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(6);
    }];
    [hint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.nameLabel);
        make.top.equalTo(self.userIdLabel.mas_bottom).offset(6);
    }];

    self.tableView.tableHeaderView = self.profileHeader;
}

- (void)refreshHeader {
    self.nameLabel.text = self.name.length ? self.name : @"BroadLink User";
    self.userIdLabel.text = self.userid.length ? [NSString stringWithFormat:@"ID  %@", self.userid] : @"ID  —";

    if (![BLCommonTools isEmpty:self.iconUrl]) {
        NSString *iconUrl = self.iconUrl;
        if ([BLConfigParam sharedConfigParam].appServiceEnable) {
            iconUrl = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:self.iconUrl];
        }
        __weak typeof(self) weakSelf = self;
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:iconUrl]
                           placeholderImage:self.avatarView.image
                                  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                weakSelf.avatarView.tintColor = nil;
            }
        }];
    }
}

- (void)viewBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)logout {
    [[BLUserDefaults shareUserDefaults] clearLoginSession];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)changeAvatar {
    BLSystemImage *systemImage = [[BLSystemImage alloc] init];
    [systemImage getImageWithActionSheetAllowsEditing:YES showGallery:NO inViewController:self block:^(UIImage *image) {
        if (!image) { return; }
        [BLStatusBar showTipMessageWithStatus:@"Uploading..."];
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"myHeadIcon.png"];
        if ([image writeToFileAtPath:imagePath withMaxLimitDataSize:@(1024 * 256)]) {
            [self modifyUserIcon:imagePath];
        }
    }];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { return 3; }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) { return @"Account"; }
    if (section == 1) { return @"Security"; }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogoutCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Sign Out";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [BLTheme dangerColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        cell.backgroundColor = [BLTheme cardColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    }

    static NSString *infoId = @"InfoCellValue1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:infoId];
    }
    cell.backgroundColor = [BLTheme cardColor];
    cell.textLabel.textColor = [BLTheme titleColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.detailTextLabel.textColor = [BLTheme subtitleColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Nickname";
                cell.detailTextLabel.text = self.name.length ? self.name : @"Set nickname";
                break;
            case 1:
                cell.textLabel.text = @"Phone";
                cell.detailTextLabel.text = self.phone.length ? self.phone : @"Not bound";
                break;
            default:
                cell.textLabel.text = @"Email";
                cell.detailTextLabel.text = self.email.length ? self.email : @"Not bound";
                break;
        }
    } else {
        cell.textLabel.text = @"Password";
        cell.detailTextLabel.text = @"Change";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 2 ? 24 : 36;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]]) { return; }
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    header.textLabel.textColor = [BLTheme subtitleColor];
    header.contentView.backgroundColor = [BLTheme backgroundColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 2) {
        [self logout];
        return;
    }

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                __weak typeof(self) weakSelf = self;
                [Tools presentAlertOn:self
                                title:@"Update nickname"
                               fields:@[@{@"text": self.name ?: @"", @"placeholder": @"Nickname"}]
                              handler:^(NSArray<UITextField *> *textFields) {
                                  [weakSelf modifyUserNickname:textFields.firstObject.text];
                              }];
                break;
            }
            case 1:
                [self.navigationController pushViewController:[ModifyPhoneViewController viewController] animated:YES];
                break;
            case 2:
                [self.navigationController pushViewController:[ModifyEmailViewController viewController] animated:YES];
                break;
            default:
                break;
        }
        return;
    }

    __weak typeof(self) weakSelf = self;
    [Tools presentAlertOn:self
                    title:@"Change password"
                   fields:@[
                       @{@"placeholder": @"Current password", @"secure": @YES},
                       @{@"placeholder": @"New password", @"secure": @YES},
                       @{@"placeholder": @"Confirm new password", @"secure": @YES}
                   ]
                  handler:^(NSArray<UITextField *> *textFields) {
                      NSString *newPassword = textFields[1].text;
                      if (![newPassword isEqualToString:textFields.lastObject.text]) {
                          [BLStatusBar showTipMessageWithStatus:@"Passwords do not match"];
                          return;
                      }
                      [weakSelf modifyPassword:textFields.firstObject.text newPassword:newPassword];
                  }];
}

#pragma mark - Network

- (void)getUserInfo {
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    if (!userDefault.getUserId) {
        [BLStatusBar showTipMessageWithStatus:@"Not logged in"];
        return;
    }

    [[BLAccount sharedAccount] getUserInfo:@[userDefault.getUserId] completionHandler:^(BLGetUserInfoResult * _Nonnull result) {
        if (![BLCommonTools isEmptyArray:result.info]) {
            BLUserInfo *info = result.info[0];
            self.name = [info getNickname];
            self.userid = [info getUserid];
            self.iconUrl = [info getIconUrl];
            [self getPhoneOrEmail];
        }
    }];
}

- (void)getPhoneOrEmail {
    [[BLAccount sharedAccount] getUserPhoneAndEmailWithCompletionHandler:^(BLGetUserPhoneAndEmailResult * _Nonnull result) {
        self.email = result.email;
        self.phone = result.phone;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshHeader];
            [self.tableView reloadData];
        });
    }];
}

- (void)modifyUserIcon:(NSString *)imagePath {
    [[BLAccount sharedAccount] modifyUserIcon:imagePath completionHandler:^(BLModifyUserIconResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed) {
                [self getUserInfo];
                [BLStatusBar showTipMessageWithStatus:@"Avatar updated"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[Tools messageForSDKResult:result]];
            }
        });
    }];
}

- (void)modifyUserNickname:(NSString *)nickname {
    [[BLAccount sharedAccount] modifyUserNickname:nickname completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed) {
                [self getUserInfo];
                [BLStatusBar showTipMessageWithStatus:@"Nickname updated"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[Tools messageForSDKResult:result]];
            }
        });
    }];
}

- (void)modifyPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword {
    [[BLAccount sharedAccount] modifyPassword:oldPassword newPassword:newPassword completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed) {
                [BLStatusBar showTipMessageWithStatus:@"Password updated"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[Tools messageForSDKResult:result]];
            }
        });
    }];
}

@end
