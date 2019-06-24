//
//  DataPassthoughViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DataPassthoughViewController.h"
#import "BLDeviceService.h"

@interface DataPassthoughViewController ()<UITextViewDelegate>

@property (nonatomic, strong) BLDNADevice *device;

@end

@implementation DataPassthoughViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    
    _dataInputTextView.delegate = self;
    _dataShowTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)datapassthough {
    NSString *srcString = _dataInputTextView.text;
    NSData *srcData = [self hexString2Bytes:srcString];
    
    [self showIndicatorOnWindowWithMessage:@"Data Passthough..."];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLPassthroughResult *result = [[BLLet sharedLet].controller dnaPassthrough:self.device.ownerId ? self.device.deviceId : [self.device getDid] passthroughData:srcData];
        [self hideIndicatorOnWindow];
        if ([result succeed]) {
            NSString *resStr = [self data2hexString:[result getData]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataShowTextView.text = resStr;
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataShowTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
            });
            
        }
    });
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    if (sender.tag == 101) {
        [self datapassthough];
    }
    
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - private method
- (NSData *)hexString2Bytes:(NSString *)hexStr
{
    const char *hex = [[hexStr lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    int length = (int)strlen(hex);
    int i;
    NSMutableData *result = [[NSMutableData alloc] init];
    
    if (length % 2) {
        NSLog(@"%@ not a valid hex string ,length = %d", hexStr, length);
        return nil;
    }
    
    for (i=0; i<length/2; i++) {
        unsigned int value;
        unsigned char bin;
        NSString *hexCharStr = [hexStr substringWithRange:NSMakeRange(i*2, 2)];
        NSScanner *scanner = [[NSScanner alloc] initWithString:[NSString stringWithFormat:@"0x%@", hexCharStr]];
        
        if (![scanner scanHexInt:&value]) {
            NSLog(@"hexStr: %@, i: %d", hexStr, i);
            NSLog(@"%@ not a valid hex char", hexCharStr);
            return nil;
        }
        
        bin = value & 0xff;
        
        [result appendBytes:&bin length:1];
    }
    
    return result;
}


- (NSString *)data2hexString:(NSData *)data {
    int count = (int)data.length;
    const unsigned char* temp = (const unsigned char*)data.bytes;
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i = 0; i < count; i++)
    {
        [string appendFormat:@"%02x",*(temp+i)];
    }
    return string;
}

@end
