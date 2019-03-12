//
//  SceneAddController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/11.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "SceneAddController.h"
#import "BLNewFamilyManager.h"

#import "BLStatusBar.h"

@interface SceneAddController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)NSArray *endpointList;
@property (nonatomic, strong)NSMutableArray *selectDevListList;

@property (weak, nonatomic) IBOutlet UITableView *endpointListTable;
@property (weak, nonatomic) IBOutlet UITableView *selectDevListTable;

@end

@implementation SceneAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.endpointList = [[NSArray alloc] init];
    self.endpointListTable.delegate = self;
    self.endpointListTable.dataSource = self;
    [self setExtraCellLineHidden:self.endpointListTable];
    
    self.selectDevListList = [NSMutableArray arrayWithCapacity:0];
    self.selectDevListTable.delegate = self;
    self.selectDevListTable.dataSource = self;
    [self setExtraCellLineHidden:self.selectDevListTable];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyEndpoints];
}

- (IBAction)barBtnClick:(UIBarButtonItem *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Scene" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input new scene name";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alertController.textFields.firstObject.text;
        [self addScene:name];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)addScene:(NSString *)name {
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    
    BLSSceneInfo *info = [[BLSSceneInfo alloc] init];
    info.friendlyName = name;
    info.familyId = manager.currentFamilyInfo.familyid;
    info.extend = @"";
    info.order = 1;
    info.scenedev = [self.selectDevListList copy];
    
    [self showIndicatorOnWindow];
    [manager addScene:info completionHandler:^(BLSAddSceneResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            
            if ([result succeed]) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Get Family Endpoints Failed. Code:%ld MSG:%@", (long)result.status, result.msg]];
            }
        });
    }];
}

- (void)getFamilyEndpoints {
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    
    [manager getEndpointsWithCompletionHandler:^(BLSQueryEndpointsResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            
            if ([result succeed]) {
                self.endpointList = result.endpoints;
                [self.endpointListTable reloadData];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Get Family Endpoints Failed. Code:%ld MSG:%@", (long)result.status, result.msg]];
            }
        });
    }];
}


- (void)showSelectEndpointView:(NSUInteger)index {
    BLSEndpointInfo *info = self.endpointList[index];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Scene Dev Info" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input command param";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input command val";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input name";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input delay time";
    }];
    
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *param = alertController.textFields[0].text;
        NSString *val = alertController.textFields[1].text;
        NSString *name = alertController.textFields[2].text;
        NSString *delay = alertController.textFields[3].text;

        BLSSceneDev *scendev = [[BLSSceneDev alloc] init];
        scendev.endpointId = info.endpointId;
        scendev.order = self.selectDevListList.count;
        
        BLSSceneDevContent *content = [[BLSSceneDevContent alloc] init];
        content.name = name;
        content.delay = [delay integerValue];
        
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setValue:val forParam:param forIdx:1];
        NSDictionary *dataDic = [stdData toDictionary];
        NSString *cmdParam = [BLCommonTools serializeMessage:dataDic];
        content.cmdParamList = @[cmdParam];
        scendev.content = [content BLS_modelToJSONString];
        
        [self.selectDevListList addObject:scendev];
        [self.selectDevListTable reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.endpointListTable) {
        return self.endpointList.count;
    } else {
        return self.selectDevListList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (tableView == self.endpointListTable) {
        static NSString* cellIdentifier = @"SCENE_ENDPOINT_CELL";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        BLSEndpointInfo *info = self.endpointList[indexPath.row];
        cell.textLabel.text = info.friendlyName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"ID: %@", info.endpointId];
        return cell;

    } else {
        static NSString* cellIdentifier = @"SCENE_DEV_CELL";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        BLSSceneDev *sceneDev = self.selectDevListList[indexPath.row];
        
        UILabel *endpointIdLabel = (UILabel *)[cell viewWithTag:100];
        endpointIdLabel.font = [UIFont systemFontOfSize:12];
        endpointIdLabel.text = sceneDev.endpointId;
        
        NSDictionary *dic = [BLCommonTools deserializeMessageJSON:sceneDev.content];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
        nameLabel.font = [UIFont systemFontOfSize:12];
        nameLabel.text = [NSString stringWithFormat:@"name: %@", dic[@"name"]];
        
        UILabel *delayLabel = (UILabel *)[cell viewWithTag:102];
        delayLabel.font = [UIFont systemFontOfSize:12];
        delayLabel.text = [NSString stringWithFormat:@"delay: %ld s start", [dic[@"delay"] integerValue]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.endpointListTable) {
        [self showSelectEndpointView:indexPath.row];
    } else {
        
    }
    
}
                                          
@end
