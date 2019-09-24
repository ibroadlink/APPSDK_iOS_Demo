//
//  APConfigTableViewController.m
//  SDKDemo
//
//  Created by 白洪坤 on 2017/7/25.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import "APConfigTableViewController.h"
#import "BLStatusBar.h"

@interface APConfigTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *pubkeyTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableDictionary *apDict;

@end

@implementation APConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.pubkeyTextField.delegate = self;
    
    self.apDict = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (IBAction)buttonClick:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 100: {
            [self getDeviceAPPubkey];
        } break;
        case 101: {
            [self refresh];
        } break;
        default:
            break;
    }
    
}

- (void)getDeviceAPPubkey {
    [self showIndicatorOnWindow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLAPConfigPubkeyResult *result = [[BLLet sharedLet].controller deviceAPConfigPubkey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                self.pubkeyTextField.text = result.pubkey;
            }else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"getDeviceAPPubkey staus:%ld,msg:%@",(long)result.status,result.msg]];
            }
        });
    });
}

- (void)refresh {
    [self showIndicatorOnWindow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLGetAPListResult *apconfigResult = [[BLLet sharedLet].controller deviceAPList:7000];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([apconfigResult succeed]) {
                NSArray *apList = apconfigResult.list;
                
                for (BLAPInfo *info in apList) {
                    [self.apDict setObject:info forKey:info.ssid];
                }

                [self.tableView reloadData];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"deviceAPList staus:%ld,msg:%@",(long)apconfigResult.status,apconfigResult.msg]];
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSArray *apListArray = [self.apDict allValues];
    BLAPInfo *APinfo = apListArray[indexPath.row];
    
    NSString *ssidtxt = APinfo.ssid;
    NSInteger ssidType = APinfo.type;
    cell.textLabel.text = ssidtxt;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)ssidType];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = @"APConfig";
    NSString *acceptTitle = @"Config";
    NSString *cancelTitle = @"Cancel";
    
    NSArray *apListArray = [self.apDict allValues];
    BLAPInfo *APinfo = apListArray[indexPath.row];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text =  APinfo.ssid;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:acceptTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *ssidtxt = alertController.textFields.firstObject;
        UITextField *passwordtxt = alertController.textFields.lastObject;

        BLAPConfigProtocolEnum protocol = BL_AP_CONFIG_DEFAULT;
        NSString *pubkey = self.pubkeyTextField.text;
//        NSString *pubkey = @"2fe57da347cd62431528daac5fbb290730fff684afc4cfc2ed90995f58cb3b74";
        if (pubkey.length > 0) {
            protocol = BL_AP_CONFIG_ENCRYPT;
        }
        
        NSLog(@"apconfigResult start");
        [self showIndicatorOnWindow];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BLAPConfigResult *apconfigResult;

            if (protocol == BL_AP_CONFIG_ENCRYPT) {
                apconfigResult = [[BLLet sharedLet].controller deviceAPConfig:ssidtxt.text password:passwordtxt.text type:APinfo.type timeout:10*1000 protocol:protocol pubkey:pubkey desc:nil];
            } else {
                apconfigResult = [[BLLet sharedLet].controller deviceAPConfig:ssidtxt.text password:passwordtxt.text type:APinfo.type];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                
                if ([apconfigResult succeed]) {
                    NSLog(@"apconfig success:did--%@,pid--%@,devkey--%@",apconfigResult.did,apconfigResult.pid,apconfigResult.devkey);
                    [self viewBack];
                } else {
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"deviceAPConfig staus:%ld,msg:%@",(long)apconfigResult.status,apconfigResult.msg]];
                }
            });
        });
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}


@end
