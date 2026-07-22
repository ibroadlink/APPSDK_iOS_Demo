//
//  TVControllTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/15.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "TVControllTableViewController.h"
#import <BLLetIRCode/BLLetIRCode.h>

#import "BLStatusBar.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface TVControllTableViewController ()

@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;

@end

@implementation TVControllTableViewController

+ (instancetype)viewController {
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TV Control";
    self.blcontroller = [BLLet sharedLet].controller;
    self.blircode = [BLIRCode sharedIrdaCode];

    self.view.backgroundColor = [BLTheme backgroundColor];
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self setupTableHeader];
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"TV / STB Functions";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Tap a function to query IR code and send via RM";
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

    self.tableView.tableHeaderView = header;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tvList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"TVControllCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    UIView *card;
    UILabel *titleLabel;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 201;
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        titleLabel.textColor = [BLTheme titleColor];
        [card addSubview:titleLabel];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(4);
            make.bottom.equalTo(cell.contentView).offset(-4);
            make.left.equalTo(cell.contentView).offset(16);
            make.right.equalTo(cell.contentView).offset(-16);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        titleLabel = (UILabel *)[card viewWithTag:201];
    }

    titleLabel.text = _tvList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *ircode = [self queryTVIRCodeDataWithScript:self.savePath funcname:self.tvList[indexPath.row]];

    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:ircode forParam:@"irda"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLStdControlResult *studyResult = [self.blcontroller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdStudyData action:@"set"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([studyResult succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Send Success"];
            } else {
                [self showErrorCode:studyResult.error msg:studyResult.msg];
            }
        });
    });
}

- (NSString *)queryTVIRCodeDataWithScript:(NSString *_Nonnull)savePath funcname:(NSString *_Nonnull)funcname {
    NSDictionary *infomation = [NSJSONSerialization JSONObjectWithData:[[NSString stringWithContentsOfFile:savePath usedEncoding:nil error:nil] dataUsingEncoding:NSUTF8StringEncoding] options:NSUTF8StringEncoding error:nil];
    NSArray *infoList = [infomation objectForKey:@"functionList"];

    for (NSDictionary *info in infoList) {
        if (funcname == info[@"function"]) {
            NSArray *dataArray = [info objectForKey:@"code"];
            if (![BLCommonTools isEmptyArray:dataArray]) {
                char *ircodeByte = NULL;
                NSUInteger dataLen = dataArray.count;
                ircodeByte = (char *)malloc(sizeof(char) * (2 * dataLen));
                if (ircodeByte == NULL) {
                    BLLogError(@"ircode data malloc failed!");
                } else {
                    for (int i = 0; i < dataLen; i++) {
                        ircodeByte[i] = [dataArray[i] charValue];
                    }

                    NSData *irdata = [NSData dataWithBytes:ircodeByte length:dataLen];
                    free(ircodeByte);
                    return [BLCommonTools data2hexString:irdata];
                }
            }
        }
    }

    return nil;
}

@end
