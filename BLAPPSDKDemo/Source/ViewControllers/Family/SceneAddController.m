//
//  SceneAddController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/11.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "SceneAddController.h"
#import "BLFamilyDefult.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>

@interface SceneAddController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *endpointList;
@property (nonatomic, strong) NSMutableArray *selectDevListList;
@property (nonatomic, strong) UITableView *endpointListTable;
@property (nonatomic, strong) UITableView *selectDevListTable;
@property (nonatomic, assign) CGFloat endpointTableHeight;
@property (nonatomic, assign) CGFloat selectedTableHeight;

@end

@implementation SceneAddController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Add Scene";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.endpointList = @[];
    self.selectDevListList = [NSMutableArray arrayWithCapacity:0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(barBtnClick:)];
    [self buildUI];
}

- (void)buildUI {
    [BLTheme hideStoryboardSubviewsIn:self.view];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    [scrollView addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"New Scene";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [content addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Pick endpoints and configure scene actions";
    subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    subtitleLabel.numberOfLines = 0;
    [content addSubview:subtitleLabel];

    UILabel *endpointTitle = [[UILabel alloc] init];
    endpointTitle.text = @"Available Endpoints";
    endpointTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    endpointTitle.textColor = [BLTheme subtitleColor];
    [content addSubview:endpointTitle];

    self.endpointListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.endpointListTable.delegate = self;
    self.endpointListTable.dataSource = self;
    self.endpointListTable.backgroundColor = [UIColor clearColor];
    self.endpointListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.endpointListTable.scrollEnabled = NO;
    if (@available(iOS 15.0, *)) {
        self.endpointListTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.endpointListTable];
    [content addSubview:self.endpointListTable];

    UILabel *selectedTitle = [[UILabel alloc] init];
    selectedTitle.text = @"Selected Scene Devices";
    selectedTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    selectedTitle.textColor = [BLTheme subtitleColor];
    [content addSubview:selectedTitle];

    self.selectDevListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.selectDevListTable.delegate = self;
    self.selectDevListTable.dataSource = self;
    self.selectDevListTable.backgroundColor = [UIColor clearColor];
    self.selectDevListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.selectDevListTable.scrollEnabled = NO;
    if (@available(iOS 15.0, *)) {
        self.selectDevListTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.selectDevListTable];
    [content addSubview:self.selectDevListTable];

    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(16);
        make.left.equalTo(content).offset(20);
        make.right.equalTo(content).offset(-20);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.left.right.equalTo(titleLabel);
    }];
    [endpointTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(20);
        make.left.right.equalTo(titleLabel);
    }];
    self.endpointTableHeight = 80;
    [self.endpointListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(endpointTitle.mas_bottom).offset(8);
        make.left.right.equalTo(content);
        make.height.mas_equalTo(self.endpointTableHeight);
    }];
    [selectedTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.endpointListTable.mas_bottom).offset(20);
        make.left.right.equalTo(titleLabel);
    }];
    self.selectedTableHeight = 80;
    [self.selectDevListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(selectedTitle.mas_bottom).offset(8);
        make.left.right.equalTo(content);
        make.bottom.equalTo(content).offset(-24);
        make.height.mas_equalTo(self.selectedTableHeight);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyEndpoints];
}

- (void)updateTableHeights {
    self.endpointTableHeight = MAX(self.endpointList.count, 1) * 80.0;
    self.selectedTableHeight = MAX(self.selectDevListList.count, 1) * 80.0;
    [self.endpointListTable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.endpointTableHeight);
    }];
    [self.selectDevListTable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.selectedTableHeight);
    }];
}

- (void)barBtnClick:(UIBarButtonItem *)sender {
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
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    BLFamilyDefult *familyDefult = [BLFamilyDefult sharedFamily];

    BLSSceneInfo *info = [[BLSSceneInfo alloc] init];
    info.friendlyName = name;
    info.familyId = familyDefult.currentFamilyInfo.familyid;
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
                [self showErrorCode:result.status msg:result.msg];
            }
        });
    }];
}

- (void)getFamilyEndpoints {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];

    [manager getEndpointsWithCompletionHandler:^(BLSQueryEndpointsResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];

            if ([result succeed]) {
                self.endpointList = result.endpoints;
                [self.endpointListTable reloadData];
                [self updateTableHeights];
            } else {
                [self showErrorCode:result.status msg:result.msg];
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
        [self updateTableHeights];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.endpointListTable) {
        return self.endpointList.count;
    }
    return self.selectDevListList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.endpointListTable) {
        static NSString *cellIdentifier = @"SCENE_ENDPOINT_CELL";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
            cell.textLabel.textColor = [BLTheme titleColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
            cell.detailTextLabel.textColor = [BLTheme subtitleColor];
        }

        BLSEndpointInfo *info = self.endpointList[indexPath.row];
        cell.textLabel.text = info.friendlyName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"ID: %@", info.endpointId];
        return cell;
    }

    static NSString *cellIdentifier = @"SCENE_DEV_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        cell.detailTextLabel.textColor = [BLTheme subtitleColor];
        cell.detailTextLabel.numberOfLines = 0;
    }

    BLSSceneDev *sceneDev = self.selectDevListList[indexPath.row];
    NSDictionary *dic = [BLCommonTools deserializeMessageJSON:sceneDev.content];
    cell.textLabel.text = sceneDev.endpointId;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"name: %@ · delay: %ld s start", dic[@"name"], (long)[dic[@"delay"] integerValue]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.endpointListTable) {
        [self showSelectEndpointView:indexPath.row];
    }
}

@end
