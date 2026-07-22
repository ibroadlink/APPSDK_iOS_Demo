//
//  MatchTreeController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/3.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "MatchTreeController.h"
#import "RecoginzeIRCodeViewController.h"
#import "MatchTreeTestController.h"

#import "BLStatusBar.h"
#import "BLTheme.h"
#import "IRCodeBrandInfo.h"
#import "BLDeviceService.h"
#import "IRCodeDownloadInfo.h"
#import "IRCodeMatchTreeInfo.h"
#import "Tools.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import <Masonry/Masonry.h>

@interface MatchTreeController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *hotIRCodeTable;
@property (nonatomic, strong) UITextView *resultText;
@property (nonatomic, strong) NSMutableArray *hotIRCodes;
@property (nonatomic, strong) TreeInfo *treeInfo;

@end

@implementation MatchTreeController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Match Tree";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.hotIRCodes = [NSMutableArray arrayWithCapacity:0];

    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"Click to download ircode script:";
    hintLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    hintLabel.textColor = [BLTheme titleColor];
    [self.view addSubview:hintLabel];

    self.hotIRCodeTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.hotIRCodeTable.delegate = self;
    self.hotIRCodeTable.dataSource = self;
    self.hotIRCodeTable.backgroundColor = [BLTheme backgroundColor];
    self.hotIRCodeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.hotIRCodeTable.scrollEnabled = NO;
    if (@available(iOS 15.0, *)) {
        self.hotIRCodeTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.hotIRCodeTable];
    [self.view addSubview:self.hotIRCodeTable];

    UIButton *matchBtn = [BLTheme makePrimaryButtonWithTitle:@"Match Tree"
                                                      target:self
                                                      action:@selector(buttonClick:)];
    [self.view addSubview:matchBtn];

    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = @"Match Tree JSON";
    resultTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    resultTitle.textColor = [BLTheme subtitleColor];
    [self.view addSubview:resultTitle];

    self.resultText = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.resultText];
    self.resultText.editable = NO;
    self.resultText.selectable = YES;
    [self.view addSubview:self.resultText];

    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    [self.hotIRCodeTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hintLabel.mas_bottom).offset(12);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    [matchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hotIRCodeTable.mas_bottom).offset(16);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(44);
    }];
    [resultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(matchBtn.mas_bottom).offset(16);
        make.left.right.equalTo(matchBtn);
    }];
    [self.resultText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultTitle.mas_bottom).offset(8);
        make.left.right.equalTo(matchBtn);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-12);
    }];

    [self queryMatchTreeInfos];
}

- (void)buttonClick:(UIButton *)sender {
    if (self.treeInfo) {
        if ([BLCommonTools isEmpty:self.treeInfo.key]) {
            [BLStatusBar showTipMessageWithStatus:@"Match Tree key is empty!"];
        } else {
            MatchTreeTestController *vc = [MatchTreeTestController viewController];
            vc.device = self.device;
            vc.treeInfo = self.treeInfo;
            vc.devtype = self.devtype;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Match Tree is empty!"];
    }
}

- (void)queryMatchTreeInfos {
    BLIRCode *ircode = [BLIRCode sharedIrdaCode];

    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ircode getMatchTreeWithCountry:@"1" devtypeid:self.devtype brandid:self.brand.brandid completionHandler:^(BLBaseBodyResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
            });

            if ([result succeed]) {
                [self.hotIRCodes removeAllObjects];
                if (result.respbody) {
                    IRCodeMatchTreeInfo *info = [IRCodeMatchTreeInfo BLS_modelWithJSON:result.respbody];
                    self.treeInfo = info.matchtree;

                    if (![BLCommonTools isEmptyArray:info.hotircode]) {
                        [self.hotIRCodes addObjectsFromArray:info.hotircode];
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hotIRCodeTable reloadData];
                    CGFloat rowH = 52;
                    CGFloat h = MAX(52, self.hotIRCodes.count * rowH);
                    [self.hotIRCodeTable mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(MIN(h, 240));
                    }];

                    if (result.respbody) {
                        NSData *data = [NSJSONSerialization dataWithJSONObject:result.respbody options:NSJSONWritingPrettyPrinted error:nil];
                        self.resultText.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultText.text = [Tools messageForError:result.error msg:result.msg];
                });
            }
        }];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hotIRCodes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IRCODE_HOT_CELL";
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
        titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
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

    titleLabel.text = self.hotIRCodes[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *ircodeid = self.hotIRCodes[indexPath.row];

    IRCodeDownloadInfo *info = [[IRCodeDownloadInfo alloc] init];
    info.ircodeid = ircodeid;
    info.devtype = self.devtype;

    RecoginzeIRCodeViewController *vc = [RecoginzeIRCodeViewController viewController];
    vc.downloadinfo = info;
    vc.device = self.device;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
