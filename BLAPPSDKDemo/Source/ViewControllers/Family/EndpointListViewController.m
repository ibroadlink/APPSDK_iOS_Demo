//
//  EndpointListViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "EndpointListViewController.h"
#import "OperateViewController.h"
#import "BLNewFamilyManager.h"

#import "BLStatusBar.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EndpointListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *endpointListTable;
- (IBAction)barButtonClick:(UIBarButtonItem *)sender;

@property (nonatomic, copy)NSArray *endpointList;

@end

@implementation EndpointListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.endpointList = [[NSArray alloc] init];
    self.endpointListTable.delegate = self;
    self.endpointListTable.dataSource = self;
    [self setExtraCellLineHidden:self.endpointListTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyEndpoints];
}

- (void)getFamilyEndpoints {
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    
    [manager getEndpointsWithCompletionHandler:^(BLSQueryEndpointsResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });
        
        if ([result succeed]) {
            self.endpointList = result.endpoints;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.endpointListTable reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Get Family Endpoints Failed. Code:%ld MSG:%@", result.status, result.msg]];
            });
        }
    }];
}

- (void)deleteEndpoint:(NSString *)endpointId {
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    
    [manager delEndpoint:endpointId completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });
        
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getFamilyEndpoints];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Delete Endpoints Failed. Code:%ld MSG:%@", result.status, result.msg]];
            });
        }
    }];
    
}


#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.endpointList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"ENDPOINT_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BLSEndpointInfo *info = self.endpointList[indexPath.row];
    
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:100];
    headImageView.contentMode = UIViewContentModeScaleAspectFit;
    [headImageView sd_setImageWithURL:[NSURL URLWithString:info.icon] placeholderImage:[UIImage imageNamed:@"default_module_icon"]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.text = info.friendlyName;
    
    UILabel *endpointidLabel = (UILabel *)[cell viewWithTag:102];
    endpointidLabel.font = [UIFont systemFontOfSize:12];
    endpointidLabel.text = [NSString stringWithFormat:@"ID: %@", info.endpointId];
    
    UILabel *productLabel = (UILabel *)[cell viewWithTag:103];
    productLabel.font = [UIFont systemFontOfSize:12];
    productLabel.text = [NSString stringWithFormat:@"PID: %@", info.productId];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSEndpointInfo *info = self.endpointList[indexPath.row];
        NSString *endpointId = info.endpointId;
        
        [self deleteEndpoint:endpointId];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"OperateView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[OperateViewController class]]) {
            OperateViewController* opVC = (OperateViewController *)target;
            opVC.device = (BLDNADevice *)sender;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLSEndpointInfo *info = self.endpointList[indexPath.row];
    BLDNADevice *device = [info toDNADevice];
    [[BLLet sharedLet].controller addDevice:device];
    
    [self performSegueWithIdentifier:@"OperateView" sender:device];
}

- (IBAction)barButtonClick:(UIBarButtonItem *)sender {
     [self performSegueWithIdentifier:@"EndpointAddView" sender:nil];
}
@end
