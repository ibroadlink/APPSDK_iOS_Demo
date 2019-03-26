//
//  TVBoxAreaSelectController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "TVBoxAreaSelectController.h"
#import "CateGoriesTableViewController.h"

#import "BLStatusBar.h"
#import <BLLetIRCode/BLLetIRCode.h>

@interface TVBoxAreaSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *areasTable;

@property (strong, nonatomic) NSMutableArray *areaInfos;

@end


@implementation TVBoxAreaSelectController

+ (instancetype)viewController {
    TVBoxAreaSelectController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.areaInfos = [NSMutableArray arrayWithCapacity:0];
    self.areasTable.delegate = self;
    self.areasTable.dataSource = self;
    [self setExtraCellLineHidden:self.areasTable];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self querySubAreas];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)querySubAreas {
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    
    if (self.currentArea.isleaf != 1) {
        [blircode requestSubAreaWithLocateid:self.currentArea.locateid completionHandler:^(BLBaseBodyResult * _Nonnull result) {

            if ([result succeed]) {
                [self.areaInfos removeAllObjects];
                
                NSData *jsonData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseBodydic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:nil];

                for (NSDictionary *dic in responseBodydic[@"subareainfo"]) {
                    SubAreaInfo *info = [SubAreaInfo BLS_modelWithDictionary:dic];
                    [self.areaInfos addObject:info];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = self.currentArea.name;
                    [self.areasTable reloadData];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [BLStatusBar showTipMessageWithStatus:result.msg];
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            CateGoriesTableViewController *vc = [CateGoriesTableViewController viewController];
            vc.subAreainfo = self.currentArea;
            vc.devtype = BL_IRCODE_DEVICE_TV_BOX;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.areaInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"TV_BOX_AREA_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    SubAreaInfo *info = self.areaInfos[indexPath.row];
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Locateid : %ld", info.locateid];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.currentArea = self.areaInfos[indexPath.row];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self querySubAreas];
    });
}

@end
