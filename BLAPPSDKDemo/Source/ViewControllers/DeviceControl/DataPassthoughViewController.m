//
//  DataPassthoughViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DataPassthoughViewController.h"
#import "BLDeviceService.h"
#import "Tools.h"
#import "BLTheme.h"
#import <Masonry/Masonry.h>

@interface DataPassthoughViewController () <UITextViewDelegate>

@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) UITextView *dataInputTextView;
@property (nonatomic, strong) UITextView *dataShowTextView;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation DataPassthoughViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Passthrough";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    [self buildUI];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)buildUI {
    NSString *deviceName = self.device.getName.length ? self.device.getName : @"Selected Device";
    NSString *subtitle = [NSString stringWithFormat:@"%@ · Send hex payload to device", deviceName];

    UILabel *inputTitle = [self sectionLabel:@"Request (Hex)"];
    self.dataInputTextView = [self makeEditorTextView];
    self.dataInputTextView.editable = YES;
    self.dataInputTextView.delegate = self;
    self.dataInputTextView.text = @"";
    [self.dataInputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(140);
    }];

    UILabel *outputTitle = [self sectionLabel:@"Response"];
    self.dataShowTextView = [self makeEditorTextView];
    self.dataShowTextView.editable = NO;
    self.dataShowTextView.delegate = self;
    self.dataShowTextView.text = @"Response hex will appear here.";
    [self.dataShowTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(140);
    }];

    self.sendButton = [BLTheme makePrimaryButtonWithTitle:@"Send"
                                                   target:self
                                                   action:@selector(buttonClick:)];
    self.sendButton.tag = 101;

    [BLTheme installAuthFormOnView:self.view
                             title:@"Data Passthrough"
                          subtitle:subtitle
                         formViews:@[inputTitle, self.dataInputTextView, outputTitle, self.dataShowTextView]
                     primaryButton:self.sendButton
                       footerViews:nil];
}

- (UILabel *)sectionLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    label.textColor = [BLTheme subtitleColor];
    return label;
}

- (UITextView *)makeEditorTextView {
    UITextView *textView = [[UITextView alloc] init];
    [BLTheme styleResultTextView:textView];
    textView.font = [UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightRegular];
    textView.returnKeyType = UIReturnKeyDone;
    return textView;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)datapassthough {
    NSString *srcString = self.dataInputTextView.text;
    if (srcString.length == 0) {
        [self showTextOnly:@"Please enter hex data"];
        return;
    }

    NSData *srcData = [self hexString2Bytes:srcString];
    if (!srcData) {
        [self showTextOnly:@"Invalid hex string"];
        return;
    }

    [self showIndicatorOnWindowWithMessage:@"Sending..."];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLPassthroughResult *result = [[BLLet sharedLet].controller dnaPassthrough:[Tools controlDidForDevice:self.device]
                                                                   passthroughData:srcData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                self.dataShowTextView.text = [self data2hexString:[result getData]];
            } else {
                self.dataShowTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
            }
        });
    });
}

- (void)buttonClick:(UIButton *)sender {
    if (sender.tag == 101) {
        [self datapassthough];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - private

- (NSData *)hexString2Bytes:(NSString *)hexStr {
    NSString *cleaned = [[hexStr lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    cleaned = [cleaned stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    const char *hex = [cleaned cStringUsingEncoding:NSUTF8StringEncoding];
    int length = (int)strlen(hex);
    NSMutableData *result = [[NSMutableData alloc] init];

    if (length % 2) {
        NSLog(@"%@ not a valid hex string ,length = %d", hexStr, length);
        return nil;
    }

    for (int i = 0; i < length / 2; i++) {
        unsigned int value;
        NSString *hexCharStr = [cleaned substringWithRange:NSMakeRange(i * 2, 2)];
        NSScanner *scanner = [[NSScanner alloc] initWithString:[NSString stringWithFormat:@"0x%@", hexCharStr]];
        if (![scanner scanHexInt:&value]) {
            return nil;
        }
        unsigned char bin = value & 0xff;
        [result appendBytes:&bin length:1];
    }
    return result;
}

- (NSString *)data2hexString:(NSData *)data {
    int count = (int)data.length;
    const unsigned char *temp = (const unsigned char *)data.bytes;
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i = 0; i < count; i++) {
        [string appendFormat:@"%02x", *(temp + i)];
    }
    return string;
}

@end
