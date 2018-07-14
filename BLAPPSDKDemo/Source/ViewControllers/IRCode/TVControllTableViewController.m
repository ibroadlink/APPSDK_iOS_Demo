//
//  TVControllTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/15.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "TVControllTableViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
@interface TVControllTableViewController ()
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;
@end

@implementation TVControllTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.tvList);
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    self.blircode = delegate.let.ircode;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tvList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"TVControllCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = _tvList[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取的ircode使用RM发射接口发射
    if (_devtype == BL_IRCODE_DEVICE_TV) {
        BLIRCodeDataResult *result = [self.blircode queryTVIRCodeDataWithScript:self.savePath deviceType:BL_IRCODE_DEVICE_TV funcname:self.tvList[indexPath.row]];
        NSString *ircode = result.ircode;
        NSLog(@"ircode----%@",ircode);
        [BLStatusBar showTipMessageWithStatus:ircode];
    }else if (_devtype == BL_IRCODE_DEVICE_TV_BOX){
        BLIRCodeDataResult *result = [self.blircode queryTVIRCodeDataWithScript:self.savePath deviceType:BL_IRCODE_DEVICE_TV_BOX funcname:self.tvList[indexPath.row]];
        NSString *ircode = result.ircode;
        NSLog(@"ircode----%@",ircode);
        [BLStatusBar showTipMessageWithStatus:ircode];

    }
    
    
}

@end
