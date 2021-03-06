//
//  SceneListController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/11.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "SceneListController.h"
#import <BLSFamily/BLSFamily.h>

#import "BLStatusBar.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SceneListController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *sceneList;

@property (weak, nonatomic) IBOutlet UITableView *sceneListTable;

@end

@implementation SceneListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sceneList = [[NSArray alloc] init];
    self.sceneListTable.delegate = self;
    self.sceneListTable.dataSource = self;
    [self setExtraCellLineHidden:self.sceneListTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryAllSceneList];
}

- (void)queryAllSceneList {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    
    [self showIndicatorOnWindow];
    [manager getScenesWithCompletionHandler:^(BLSQueryScenesResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                self.sceneList = result.scenes;
                [self.sceneListTable reloadData];
            } else {
                NSLog(@"ERROR :%@", result.msg);
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Get Family SceneList Failed. Code:%ld MSG:%@", (long)result.status, result.msg]];
            }
        });
    }];
}

- (void)delScene:(BLSSceneInfo *)info {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    
    [self showIndicatorOnWindow];
    [manager delScene:info.sceneId completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
             [self queryAllSceneList];
        });
    }];
}

- (IBAction)barBtnClick:(UIBarButtonItem *)sender {
     [self performSegueWithIdentifier:@"SceneAddView" sender:nil];
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([BLCommonTools isEmptyArray:self.sceneList]) {
        return 0;
    } else {
        return self.sceneList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"SCENE_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BLSSceneInfo *info = self.sceneList[indexPath.row];
    
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:100];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:info.icon] placeholderImage:[UIImage imageNamed:@"default_module_icon"]];
    
    UILabel *useridLabel = (UILabel *)[cell viewWithTag:101];
    useridLabel.font = [UIFont systemFontOfSize:12];
    useridLabel.text = info.sceneId;
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:102];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.text = [@"Name:" stringByAppendingString:info.friendlyName];
    
    UILabel *roleLabel = (UILabel *)[cell viewWithTag:103];
    roleLabel.font = [UIFont systemFontOfSize:12];
    roleLabel.text = [NSString stringWithFormat:@"Order: %ld", (long)info.order];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSSceneInfo *info = self.sceneList[indexPath.row];
        [self delScene:info];
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    BLSSceneInfo *info = self.sceneList[indexPath.row];
//    BLLinkagedevices *linkagedevices = [[BLLinkagedevices alloc] init];
//    BLDev *dev = [[BLDev alloc] init];
//    BLSSceneDev *sceneDev = info.scenedev[0];
//    dev.endpointID = sceneDev.endpointId;
//    dev.gatewayID = @"";
//    dev.order = 1;
//    dev.content = @"";
//    linkagedevices.devs = @[dev];
//    linkagedevices.name = @"123";
//    linkagedevices.linkagedevicesExtern = @"";
//    linkagedevices.linkagetype = @"1";
//    BLSubscribe *subscribe = [[BLSubscribe alloc] init];
//    subscribe.endpointID = sceneDev.endpointId;
//    
//    
//    BLLinkageInfo *linkageInfo = [[BLLinkageInfo alloc]init];
//    linkageInfo.rulename = info.friendlyName;
//    linkageInfo.ruletype = 1;
//    linkageInfo.enable = 1;
//    linkageInfo.locationinfo = @"";
//    linkageInfo.characteristicinfo = @"{}";
//    linkageInfo.familyid = info.familyId;
//    linkageInfo.sceneIDS = @[info.sceneId];
//    linkageInfo.linkagedevices = linkagedevices;
//    linkageInfo.subscribe = @[subscribe];
//    linkageInfo.source = @"";
//    linkageInfo.delay = 1;
//    
//    [[BLSFamilyManager sharedFamily] addCloudLinkage:linkageInfo completionHandler:^(BLBaseResult * _Nonnull result) {
//        
//    }];
//    
//    [[BLSFamilyManager sharedFamily] queryCloudLinkageInfoWithCompletionHandler:^(BLBaseResult * _Nonnull result) {
//        
//    }];
//}

@end
