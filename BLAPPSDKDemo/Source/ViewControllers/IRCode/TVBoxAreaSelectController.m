//
//  TVBoxAreaSelectController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "TVBoxAreaSelectController.h"
#import "CateGoriesTableViewController.h"
#import "IRCodeLocationInfo.h"

#import "BLStatusBar.h"
#import <BLLetIRCode/BLLetIRCode.h>

@interface TVBoxAreaSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *areasTable;

@property (strong, nonatomic) NSMutableArray *locationInfos;
@property (strong, nonatomic) NSMutableArray *areaInfos;

@property (assign, nonatomic) NSUInteger step;
@property (strong, nonatomic) IRCodeLocationInfo *currentLocation;

@end


@implementation TVBoxAreaSelectController

+ (instancetype)viewController {
    TVBoxAreaSelectController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationInfos = [NSMutableArray arrayWithCapacity:0];
    self.areaInfos = [NSMutableArray arrayWithCapacity:0];
    self.areasTable.delegate = self;
    self.areasTable.dataSource = self;
    [self setExtraCellLineHidden:self.areasTable];
    
    self.currentLocation = [IRCodeLocationInfo new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryAllLocations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryAllLocations {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLIRCode *blircode = [BLIRCode sharedIrdaCode];
        
        [blircode getLocateListCompletionHandler:^(BLLocateInfoResult * _Nonnull result) {
            if ([result succeed]) {
                [self.locationInfos removeAllObjects];
                [self.locationInfos addObjectsFromArray:result.data];
                
                [self.areaInfos removeAllObjects];
                [self.areaInfos addObjectsFromArray:self.locationInfos];
                
                self.step = 0;
            } else {
                [BLStatusBar showTipMessageWithStatus:result.msg];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.areasTable reloadData];
                self.title = @"Please Select Country";
            });
        }];
    });
}

//- (void)querySubAreas {
//    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
//
//    if (self.currentArea.isleaf != 1) {
//        [self showIndicatorOnWindow];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [blircode requestSubAreaWithLocateid:self.currentArea.locateid completionHandler:^(BLBaseBodyResult * _Nonnull result) {
//                if ([result succeed]) {
//                    [self.areaInfos removeAllObjects];
//
//                    if (result.respbody) {
//                        NSArray *infos = result.respbody[@"subareainfo"];
//
//                        if (![BLCommonTools isEmptyArray:infos]) {
//                            for (NSDictionary *dic in infos) {
//                                IRCodeSubAreaInfo *info = [IRCodeSubAreaInfo BLS_modelWithDictionary:dic];
//                                [self.areaInfos addObject:info];
//                            }
//                        }
//                    }
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self hideIndicatorOnWindow];
//                        self.title = self.currentArea.name;
//                        [self.areasTable reloadData];
//                    });
//
//                } else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self hideIndicatorOnWindow];
//                        [BLStatusBar showTipMessageWithStatus:result.msg];
//                    });
//                }
//            }];
//        });
//    } else {
//        CateGoriesTableViewController *vc = [CateGoriesTableViewController viewController];
//        vc.subAreainfo = self.currentArea;
//        vc.devtype = BL_IRCODE_DEVICE_TV_BOX;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//}

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
    
    if (self.step == 0) {
        //选择国家
        BLDatum *info = self.areaInfos[indexPath.row];
        cell.textLabel.text = info.country;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"code : %@", info.code];
    } else if (self.step == 1) {
        //选择省份
        BLChild *info = self.areaInfos[indexPath.row];
        cell.textLabel.text = info.province;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"code : %@", info.code];
    } else if (self.step == 2) {
        //选择城市
        BLSubchild *info = self.areaInfos[indexPath.row];
        cell.textLabel.text = info.city;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"code : %@", info.code];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.step == 0) {
        //选择国家
        BLDatum *info = self.areaInfos[indexPath.row];
        self.currentLocation.country = info.country;
        self.currentLocation.countryCode = info.code;

        [self.areaInfos removeAllObjects];
        [self.areaInfos addObjectsFromArray:info.children];
        self.step++;
        
        self.title = @"Please Select Province";
        [self.areasTable reloadData];
    } else if (self.step == 1) {
        //选择省份
        BLChild *info = self.areaInfos[indexPath.row];
        self.currentLocation.province = info.province;
        self.currentLocation.provinceCode = info.code;
        
        [self.areaInfos removeAllObjects];
        [self.areaInfos addObjectsFromArray:info.subchildren];
        self.step++;
        
        self.title = @"Please Select City";
        [self.areasTable reloadData];
    } else if (self.step == 2) {
        //选择城市
        BLSubchild *info = self.areaInfos[indexPath.row];
        self.currentLocation.city = info.city;
        self.currentLocation.cityCode = info.code;
        
        CateGoriesTableViewController *vc = [CateGoriesTableViewController viewController];
        vc.currentLocation = self.currentLocation;
        vc.devtype = BL_IRCODE_DEVICE_TV_BOX;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
