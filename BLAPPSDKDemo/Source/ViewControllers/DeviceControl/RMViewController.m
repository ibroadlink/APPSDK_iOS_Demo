//
//  RMViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/1.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "RMViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
//#import "BroadLinkRFSwitch.h"

@interface RMViewController (){
    NSString *_irdaCodeStr;
//    BLTC1_2 *_rfCode;
}
@property (weak, nonatomic) IBOutlet UILabel *IrdaCode;

@end

@implementation RMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_IrdaCode sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (IBAction)learnButton:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:nil forParam:@"irdastudy"];
    BLStdControlResult *studyResult = [[BLLet sharedLet].controller dnaControl:[_device getDid] stdData:stdData action:@"get"];
    if ([studyResult succeed]) {
        _IrdaCode.text = @"进入学习状态";
    }
}

- (IBAction)GetIrdaCode:(id)sender {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:nil forParam:@"irda"];
    BLStdControlResult *irdaResult = [[BLLet sharedLet].controller dnaControl:[_device getDid] stdData:stdData action:@"get"];
    NSDictionary *dic = [[irdaResult getData] toDictionary];
    if ([dic[@"vals"] count] != 0) {
        _irdaCodeStr = dic[@"vals"][0][0][@"val"];
        _IrdaCode.text = _irdaCodeStr;
    }else{
        _IrdaCode.text = @"未学习红码";
    }
    
}

- (IBAction)SendIrdaCode:(id)sender {
    _irdaCodeStr = @"26008c00959115351535153515111411141114111411143614361436141114111411141114111436143614361436141114111411141114111411141114111436153515351535150005f295921535153515351510151015101510151015351535153515101510151015101510153515351535153515101510151015101510151015101510153515351535153515000d05000000000000000000000000";
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:_irdaCodeStr forParam:@"irda"];
    BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:[_device getDid] stdData:stdData action:@"set"];
    if ([sendResult succeed]) {
        _IrdaCode.text = @"红码发射成功";
    }
}

- (IBAction)TimerBtn:(id)sender {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@"0|1|19|30|1|打开电视|2|32:100@64:500|2600f000636463911312150f1510150f153415331534150f15341632143514351410170e160e1533151015331510150f1534150f15341533150f150f160f150f1633153415331632160f150f160f150f15341533163315331534150f1534150f160f1533160f1533150f160f150f150f1633153415331633150004fc6562658e160f150f160f150f153415331633150f1534153415331534150f160f150f153315101533160f150f1534150f15341533150f160f150f150f1633153415341533150f150f160f150f15341533163315331633150f1633150f160f1533160f1533150f160f150f1510153315341534153315000d050000000000000000" forParam:@"rmtimer"];
    BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:[_device getDid] stdData:stdData action:@"set"];
    if ([sendResult succeed]) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setValue:nil forParam:@"rmtimer"];
        BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:[_device getDid] stdData:stdData action:@"get"];
        _IrdaCode.text = [NSString stringWithFormat:@"%@",[[sendResult getData] toDictionary][@"vals"][0]];
    }
}

- (IBAction)TC2PairBtn:(id)sender {
//    BroadLinkRFSwitch *rfSwitch = [[BroadLinkRFSwitch alloc] init];
//    _rfCode = [rfSwitch BLTC1_2LearningCodeWithFrequency:433 repeat:20];
//    NSString *rfStr = [self convertDataToHexStr:_rfCode.learningData];
//    BLStdData *stdData = [[BLStdData alloc] init];
//    [stdData setValue:rfStr forParam:@"irda"];
//    BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:[_device getDid] stdData:stdData action:@"set"];
//    if ([sendResult succeed]) {
//        _IrdaCode.text = @"配对码发射成功";
//    }
}
- (IBAction)TC2ControllerBtn:(id)sender {
//    BroadLinkRFSwitch *rfSwitch = [[BroadLinkRFSwitch alloc] init];
//    NSData *allRfCode = [rfSwitch BLTC1SwitchControlWithData:_rfCode.firstOnData frequency:433 repeat:20];
//    NSString *rfStr = [self convertDataToHexStr:allRfCode];
//    BLStdData *stdData = [[BLStdData alloc] init];
//    [stdData setValue:rfStr forParam:@"irda"];
//    BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:[_device getDid] stdData:stdData action:@"set"];
//    if ([sendResult succeed]) {
//        _IrdaCode.text = @"控制码发射成功";
//    }
}

- (NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

@end
