//
//  AKeyToIdentifyViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2017/8/15.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "AKeyToIdentifyViewController.h"
#import "ACControlViewController.h"

#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import "Tools.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import <Masonry/Masonry.h>

@interface AKeyToIdentifyViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *recoginzeTxt;
@property (nonatomic, strong) UITextView *resultTxt;
@property (strong, nonatomic) BLDNADevice *device;

@end

@implementation AKeyToIdentifyViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"One Key Identify";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Learn"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(RMLearnBtn:)];

    [self buildUI];

    self.recoginzeTxt.delegate = self;
    self.recoginzeTxt.text = @"2600ca008d950c3b0f1410380e3a0d160e160d3b0d150e150e3910150d160d3a0f36101411380d150f3a0e390d3910370f150f38103a0d3a0e1211140f1411121038101310150f3710380e390e150f160d160e1410140f131113101310380e3b0f351137123611ad8e9210370f1511370e390f140f1410380f1311130f39101211130f390f380f150f390f1310380f3810380f380f141038103710380f1411121014101310380f14101310380f3810381013101311121014101211131014101310370f3910361138103710000d05";

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Identify IR Code";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [content addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Paste hex IR data, identify, download and control";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    subtitleLabel.numberOfLines = 0;
    [content addSubview:subtitleLabel];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [content addSubview:accent];

    UILabel *inputTitle = [[UILabel alloc] init];
    inputTitle.text = @"IR Hex Input";
    inputTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    inputTitle.textColor = [BLTheme subtitleColor];
    [content addSubview:inputTitle];

    self.recoginzeTxt = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.recoginzeTxt];
    self.recoginzeTxt.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.recoginzeTxt.editable = YES;
    [content addSubview:self.recoginzeTxt];

    UIButton *identifyBtn = [BLTheme makePrimaryButtonWithTitle:@"Identify The IRCode"
                                                         target:self
                                                         action:@selector(identifyTheIRCode:)];
    UIButton *downloadBtn = [BLTheme makeSecondaryButtonWithTitle:@"Download IRCode script"
                                                           target:self
                                                           action:@selector(downLoadIRCodeScript:)];
    UIButton *baseInfoBtn = [BLTheme makeSecondaryButtonWithTitle:@"Get IRCode Base Info"
                                                           target:self
                                                           action:@selector(getIRCodeBaseInfo:)];
    UIButton *dataBtn = [BLTheme makePrimaryButtonWithTitle:@"Get IRCode Data"
                                                    target:self
                                                    action:@selector(getIRCodeData:)];

    for (UIButton *btn in @[identifyBtn, downloadBtn, baseInfoBtn, dataBtn]) {
        [content addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
        }];
    }

    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = @"Result";
    resultTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    resultTitle.textColor = [BLTheme subtitleColor];
    [content addSubview:resultTitle];

    self.resultTxt = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.resultTxt];
    self.resultTxt.editable = NO;
    self.resultTxt.selectable = YES;
    [content addSubview:self.resultTxt];

    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scroll);
        make.width.equalTo(scroll);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(12);
        make.left.equalTo(content).offset(20);
        make.right.equalTo(content).offset(-20);
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
    }];
    [inputTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accent.mas_bottom).offset(20);
        make.left.right.equalTo(titleLabel);
    }];
    [self.recoginzeTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inputTitle.mas_bottom).offset(8);
        make.left.right.equalTo(titleLabel);
        make.height.mas_equalTo(120);
    }];
    [identifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.recoginzeTxt.mas_bottom).offset(12);
        make.left.right.equalTo(titleLabel);
    }];
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(identifyBtn.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
    }];
    [baseInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(downloadBtn.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
    }];
    [dataBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(baseInfoBtn.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
    }];
    [resultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dataBtn.mas_bottom).offset(20);
        make.left.right.equalTo(titleLabel);
    }];
    [self.resultTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultTitle.mas_bottom).offset(8);
        make.left.right.equalTo(titleLabel);
        make.height.mas_equalTo(160);
        make.bottom.equalTo(content).offset(-24);
    }];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)identifyTheIRCode:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];

    [blircode recognizeIRCodeWithHexString:_recoginzeTxt.text mtag:nil completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        if ([result succeed]) {
            if (result.respbody) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultTxt.text = result.responseBody;
                });

                NSArray *downloadInfos = [result.respbody objectForKey:@"downloadinfo"];
                if (![BLCommonTools isEmptyArray:downloadInfos]) {
                    self.randkey = downloadInfos[0][@"fixkey"];
                    self.downloadUrl = downloadInfos[0][@"downloadurl"];
                    NSString *name = downloadInfos[0][@"name"];

                    BLController *blcontroller = [BLLet sharedLet].controller;
                    self.savePath = [blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:name];
                }
            }
        } else {
            [self showErrorCode:result.error msg:result.msg];
        }
    }];
}

- (IBAction)downLoadIRCodeScript:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    [self downloadIRCodeScript:self.downloadUrl savePath:self.savePath randkey:self.randkey];
}

- (IBAction)getIRCodeBaseInfo:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    [self queryIRCodeScriptInfoSavePath:self.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_AC];
}

- (IBAction)getIRCodeData:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    if (self.savePath == nil) {
        [BLStatusBar showTipMessageWithStatus:@"identifyTheIRCode first!"];
        return;
    }

    ACControlViewController *vc = [ACControlViewController viewController];
    vc.savePath = self.savePath;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)RMLearnBtn:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    BLController *blcontroller = [BLLet sharedLet].controller;

    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:nil forParam:@"irdastudy"];
    BLStdControlResult *studyResult = [blcontroller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdStudyData action:@"get"];
    if ([studyResult succeed]) {
        for (int i = 0; i < 10; i++) {
            sleep(3);

            BLStdData *stdData = [[BLStdData alloc] init];
            [stdData setValue:nil forParam:@"irda"];

            BLStdControlResult *irdaResult = [blcontroller dnaControl:[self.device getDid] stdData:stdData action:@"get"];
            NSDictionary *dic = [[irdaResult getData] toDictionary];
            if ([dic[@"vals"] count] != 0) {
                self.recoginzeTxt.text = dic[@"vals"][0][0][@"val"];
                break;
            } else {
                self.recoginzeTxt.text = @"Can not get learn ircode";
            }
        }
    }
}

- (void)downloadIRCodeScript:(NSString *_Nonnull)urlString savePath:(NSString *_Nonnull)path randkey:(NSString *_Nullable)randkey {
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];

    [blircode downloadIRCodeScriptWithUrl:urlString savePath:path randkey:randkey completionHandler:^(BLDownloadResult * _Nonnull result) {
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTxt.text = result.savePath;
            });
        } else {
            [self showErrorCode:result.error msg:result.msg];
        }
    }];
}

- (void)queryIRCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLIRCode *blircode = [BLIRCode sharedIrdaCode];
        BLIRCodeInfoResult *result = [blircode queryIRCodeInfomationWithScript:savePath deviceType:devicetype];
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTxt.text = result.infomation;
            });
        } else {
            [self showErrorCode:result.error msg:result.msg];
        }
    });
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

@end
