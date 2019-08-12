//
//  EndpointListViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "EndpointListViewController.h"
#import "EndpointDetailController.h"
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
            
            if ([result succeed]) {
                self.endpointList = result.endpoints;
                for (BLSEndpointInfo *info in self.endpointList) {
                    [[BLLet sharedLet].controller addDevice:[info toDNADevice]];
                }
                
                [self.endpointListTable reloadData];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Get Family Endpoints Failed. Code:%ld MSG:%@", (long)result.status, result.msg]];
            }
        });
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EndpointDetail"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[EndpointDetailController class]]) {
            EndpointDetailController* vc = (EndpointDetailController *)target;
            vc.isNeedDeviceControl = YES;
            vc.endpoint = (BLSEndpointInfo *)sender;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLSEndpointInfo *info = self.endpointList[indexPath.row];
    [self performSegueWithIdentifier:@"EndpointDetail" sender:info];
}

- (IBAction)barButtonClick:(UIBarButtonItem *)sender {
     [self performSegueWithIdentifier:@"EndpointAddView" sender:nil];
}
@end
