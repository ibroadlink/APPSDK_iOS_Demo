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
#import "IRCodeBrandInfo.h"
#import "BLDeviceService.h"
#import "IRCodeDownloadInfo.h"
#import "IRCodeMatchTreeInfo.h"

#import <BLLetIRCode/BLLetIRCode.h>

@interface MatchTreeController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *hotIRCodeTable;
@property (weak, nonatomic) IBOutlet UITextView *resultText;

@property (nonatomic, strong) NSMutableArray *hotIRCodes;
@property (nonatomic, strong) TreeInfo *treeInfo;

@end

@implementation MatchTreeController

+ (instancetype)viewController {
    MatchTreeController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hotIRCodes = [NSMutableArray arrayWithCapacity:0];
    self.hotIRCodeTable.delegate = self;
    self.hotIRCodeTable.dataSource = self;
    [self setExtraCellLineHidden:self.hotIRCodeTable];
    
    [self queryMatchTreeInfos];

}

- (IBAction)buttonClick:(UIButton *)sender {
    
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
            [self hideIndicatorOnWindow];

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
                    
                    if (result.respbody) {
                        NSData *data = [NSJSONSerialization dataWithJSONObject:result.respbody options:NSJSONWritingPrettyPrinted error:nil];
                        self.resultText.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultText.text = [NSString stringWithFormat:@"QueryMatchTreeInfos Status:%ld Msg:%@", (long)result.status, result.msg];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IRCODE_HOT_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    NSString *ircodeid = self.hotIRCodes[indexPath.row];
    cell.textLabel.text = ircodeid;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
