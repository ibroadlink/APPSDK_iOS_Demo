//
//  MatchTreeTestController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/3.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "MatchTreeTestController.h"
#import "RecoginzeIRCodeViewController.h"

#import "IRCodeMatchTreeInfo.h"
#import "IRCodeDownloadInfo.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import "Tools.h"
#import <BLLetCore/BLLetCore.h>
#import <Masonry/Masonry.h>

@interface MatchTreeTestController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *keyLabel;
@property (nonatomic, strong) UITableView *ircodeIdTabel;
@property (nonatomic, strong) UITextView *resultText;

@end

@implementation MatchTreeTestController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Match Tree Test";
    self.view.backgroundColor = [BLTheme backgroundColor];

    UILabel *keyTitle = [[UILabel alloc] init];
    keyTitle.text = @"Tree Key";
    keyTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    keyTitle.textColor = [BLTheme subtitleColor];
    [self.view addSubview:keyTitle];

    self.keyLabel = [[UILabel alloc] init];
    self.keyLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.keyLabel.textColor = [BLTheme titleColor];
    self.keyLabel.numberOfLines = 0;
    self.keyLabel.text = self.treeInfo.key;
    [self.view addSubview:self.keyLabel];

    UILabel *listTitle = [[UILabel alloc] init];
    listTitle.text = @"Tap a code to send and confirm";
    listTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    listTitle.textColor = [BLTheme subtitleColor];
    [self.view addSubview:listTitle];

    self.ircodeIdTabel = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.ircodeIdTabel.delegate = self;
    self.ircodeIdTabel.dataSource = self;
    self.ircodeIdTabel.backgroundColor = [BLTheme backgroundColor];
    self.ircodeIdTabel.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 15.0, *)) {
        self.ircodeIdTabel.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.ircodeIdTabel];
    [self.view addSubview:self.ircodeIdTabel];

    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = @"Selected Node";
    resultTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    resultTitle.textColor = [BLTheme subtitleColor];
    [self.view addSubview:resultTitle];

    self.resultText = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.resultText];
    self.resultText.editable = NO;
    self.resultText.selectable = YES;
    self.resultText.text = [self.treeInfo BLS_modelToJSONString];
    [self.view addSubview:self.resultText];

    [keyTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(keyTitle.mas_bottom).offset(6);
        make.left.right.equalTo(keyTitle);
    }];
    [listTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.keyLabel.mas_bottom).offset(16);
        make.left.right.equalTo(keyTitle);
    }];
    [self.ircodeIdTabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(listTitle.mas_bottom).offset(8);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(180);
    }];
    [resultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ircodeIdTabel.mas_bottom).offset(12);
        make.left.right.equalTo(keyTitle);
    }];
    [self.resultText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultTitle.mas_bottom).offset(8);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-12);
    }];
}

- (NSString *)changeCodeArrayToHexString:(NSArray *)codeList {
    if (![BLCommonTools isEmptyArray:codeList]) {
        NSUInteger dataLen = codeList.count;
        char *ircodeByte = (char *)malloc(sizeof(char) * (2 * dataLen));
        if (ircodeByte == NULL) {
            BLLogError(@"ircode data malloc failed!");
        } else {
            for (int i = 0; i < dataLen; i++) {
                ircodeByte[i] = [codeList[i] charValue];
            }

            NSData *irdata = [NSData dataWithBytes:ircodeByte length:dataLen];
            free(ircodeByte);
            return [BLCommonTools data2hexString:irdata];
        }
    }
    return nil;
}

- (void)sendIRCode:(NSString *)code {
    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:code forParam:@"irda"];

    BLController *blcontroller = [BLLet sharedLet].controller;
    BLStdControlResult *studyResult = [blcontroller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdStudyData action:@"set"];
    if ([studyResult succeed]) {
        [BLStatusBar showTipMessageWithStatus:@"Send Success"];
    } else {
        [self showErrorCode:studyResult.error msg:studyResult.msg];
    }
}

- (void)showConfirmAlertWithInfo:(NSDictionary *)info {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:@"Does device work as the function ?" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *ircodeid = info[@"ircodeid"];

        if ([BLCommonTools isEmpty:ircodeid]) {
            NSDictionary *chirdren = info[@"chirdren"];
            TreeInfo *chirdTreeInfo = [TreeInfo BLS_modelWithJSON:chirdren];

            MatchTreeTestController *vc = [MatchTreeTestController viewController];
            vc.devtype = self.devtype;
            vc.device = self.device;
            vc.treeInfo = chirdTreeInfo;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            IRCodeDownloadInfo *info = [[IRCodeDownloadInfo alloc] init];
            info.ircodeid = ircodeid;
            info.devtype = self.devtype;

            RecoginzeIRCodeViewController *vc = [RecoginzeIRCodeViewController viewController];
            vc.downloadinfo = info;
            vc.device = self.device;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];

    [alertController addAction:action];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.treeInfo && self.treeInfo.codeList) {
        return self.treeInfo.codeList.count;
    }
    return 0;
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

    NSDictionary *info = self.treeInfo.codeList[indexPath.row];
    titleLabel.text = info[@"ircodeid"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = self.treeInfo.codeList[indexPath.row];

    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    self.resultText.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSArray *code = info[@"code"];
    NSString *ircode = [self changeCodeArrayToHexString:code];
    if (ircode) {
        [self sendIRCode:ircode];
    }

    [self showConfirmAlertWithInfo:info];
}

@end
