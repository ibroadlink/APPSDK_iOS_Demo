//
//  RecoginzeIRCodeViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/14.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "RecoginzeIRCodeViewController.h"
#import "ACControlViewController.h"
#import "TVControllTableViewController.h"
#import "Tools.h"
#import "BLTheme.h"

#import <BLLetCore/BLLetCore.h>
#import <BLLetIRCode/BLLetIRCode.h>
#import <Masonry/Masonry.h>

@interface RecoginzeIRCodeViewController ()

@property (nonatomic, strong) UILabel *resultTxt;
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;
@property (nonatomic, strong) NSMutableArray *tvList;

@end

@implementation RecoginzeIRCodeViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.blcontroller = [BLLet sharedLet].controller;
    self.blircode = [BLIRCode sharedIrdaCode];
    self.tvList = [NSMutableArray arrayWithCapacity:0];

    if (![BLCommonTools isEmpty:self.downloadinfo.name]) {
        self.title = self.downloadinfo.name;
    } else {
        self.title = self.downloadinfo.ircodeid;
    }

    [self buildUI];
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.title;
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    titleLabel.numberOfLines = 0;
    [content addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Download script, inspect base info, then open control UI";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    subtitleLabel.numberOfLines = 0;
    [content addSubview:subtitleLabel];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [content addSubview:accent];

    self.resultTxt = [[UILabel alloc] init];
    self.resultTxt.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.resultTxt.textColor = [BLTheme titleColor];
    self.resultTxt.numberOfLines = 0;
    self.resultTxt.text = @"—";
    [content addSubview:self.resultTxt];

    UIButton *downloadBtn = [BLTheme makePrimaryButtonWithTitle:@"Download IRCode script"
                                                         target:self
                                                         action:@selector(downLoadIRCodeScript:)];
    UIButton *baseInfoBtn = [BLTheme makeSecondaryButtonWithTitle:@"Get IRCode Base Info"
                                                           target:self
                                                           action:@selector(getIRCodeBaseInfo:)];
    UIButton *dataBtn = [BLTheme makePrimaryButtonWithTitle:@"Get IRCode Data"
                                                    target:self
                                                    action:@selector(getIRCodeData:)];

    for (UIButton *btn in @[downloadBtn, baseInfoBtn, dataBtn]) {
        [content addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
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
    [self.resultTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accent.mas_bottom).offset(16);
        make.left.right.equalTo(titleLabel);
    }];
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resultTxt.mas_bottom).offset(20);
        make.left.right.equalTo(titleLabel);
    }];
    [baseInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(downloadBtn.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
    }];
    [dataBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(baseInfoBtn.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
        make.bottom.equalTo(content).offset(-24);
    }];
}

- (IBAction)downLoadIRCodeScript:(id)sender {
    NSString *ircodeid = self.downloadinfo.ircodeid;
    self.downloadinfo.savePath = [self.blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:ircodeid];
    [self downloadIRCodeScript:ircodeid savePath:self.downloadinfo.savePath];
}

- (IBAction)getIRCodeBaseInfo:(id)sender {
    if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_AC) {
        [self queryIRCodeScriptInfoSavePath:self.downloadinfo.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_AC];
    } else if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_TV || self.downloadinfo.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        [self queryCloudCodeScriptInfoSavePath:self.downloadinfo.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_TV];
    }
}

- (IBAction)getIRCodeData:(id)sender {
    if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_AC) {
        ACControlViewController *vc = [ACControlViewController viewController];
        vc.savePath = self.downloadinfo.savePath;
        vc.device = self.device;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_TV || self.downloadinfo.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        TVControllTableViewController *vc = [TVControllTableViewController viewController];
        vc.savePath = self.downloadinfo.savePath;
        vc.device = self.device;
        vc.tvList = self.tvList;
        vc.devtype = _downloadinfo.devtype;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)downloadIRCodeScript:(NSString *_Nonnull)urlString savePath:(NSString *_Nonnull)path randkey:(NSString *_Nullable)randkey {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.blircode downloadIRCodeScriptWithUrl:urlString savePath:path randkey:randkey completionHandler:^(BLDownloadResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
            });
            if ([result succeed]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultTxt.text = result.savePath;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultTxt.text = [Tools messageForError:result.error msg:result.msg];
                });
            }
        }];
    });
}

- (void)downloadIRCodeScript:(NSString *)ircodeid savePath:(NSString *_Nonnull)path {
    NSString *mtag = @"";
    if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_AC) {
        mtag = @"gz";
    }

    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.blircode downloadIRCodeScriptWithIRCodeid:ircodeid mtag:mtag savePath:path completionHandler:^(BLDownloadResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
            });
            if ([result succeed]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultTxt.text = result.savePath;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultTxt.text = [Tools messageForError:result.error msg:result.msg];
                });
            }
        }];
    });
}

- (void)queryIRCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    BLIRCodeInfoResult *result = [self.blircode queryIRCodeInfomationWithScript:savePath deviceType:devicetype];
    if ([result succeed]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTxt.text = result.infomation;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTxt.text = [Tools messageForError:result.error msg:result.msg];
        });
    }
}

- (void)queryCloudCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    NSDictionary *infomation = [NSJSONSerialization JSONObjectWithData:[[NSString stringWithContentsOfFile:savePath usedEncoding:nil error:nil] dataUsingEncoding:NSUTF8StringEncoding] options:NSUTF8StringEncoding error:nil];
    NSArray *infoList = [infomation objectForKey:@"functionList"];
    NSString *function = @"";
    for (NSDictionary *dic in infoList) {
        function = [function stringByAppendingString:[NSString stringWithFormat:@"%@,", dic[@"function"]]];
    }
    [self.tvList removeAllObjects];
    NSArray *funarray = [self matchString:function toRegexString:@"\\w+"];
    [self.tvList addObjectsFromArray:funarray];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultTxt.text = function;
    });
}

- (NSArray *)matchString:(NSString *)string toRegexString:(NSString *)regexStr {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0; i < [match numberOfRanges]; i++) {
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];
            [array addObject:component];
        }
    }
    return array;
}

@end
