//
//  DoraemonAppInfoViewController.m
//  DoraemonKit-DoraemonKit
//
//  Created by yixiang on 2018/4/13.
//

#import "DoraemonAppInfoViewController.h"
#import "DoraemonAppInfoCell.h"
#import "DoraemonDefine.h"
#import "DoraemonAppInfoUtil.h"
#import "Doraemoni18NUtil.h"
#import "UIView+Doraemon.h"
#import "UIColor+Doraemon.h"

#import <BLLet/BLLetBase/BLConfigParam.h>

@interface DoraemonAppInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy) NSString *authority;

@end

@implementation DoraemonAppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (BOOL)needBigTitleView{
    return YES;
}

- (void)initUI
{
    self.title = DoraemonLocalizedString(@"App基本信息");

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bigTitleView.doraemon_bottom, self.view.doraemon_width, self.view.doraemon_height-self.bigTitleView.doraemon_bottom) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 0.;
    self.tableView.estimatedSectionFooterHeight = 0.;
    self.tableView.estimatedSectionHeaderHeight = 0.;
    [self.view addSubview:self.tableView];
}

#pragma mark - default data

- (void)initData
{
    // 获取设备名称
    NSString *iphoneName = [DoraemonAppInfoUtil iphoneName];
    // 获取当前系统版本号
    NSString *iphoneSystemVersion = [DoraemonAppInfoUtil iphoneSystemVersion];
    
    //获取手机型号
    NSString *iphoneType = [DoraemonAppInfoUtil iphoneType];
    
    //获取Lid & License
    NSString *lid = [BLConfigParam sharedConfigParam].licenseId;
    NSString *companyid = [BLConfigParam sharedConfigParam].companyId;
    
    NSArray *dataArray = @[
                           @{
                               @"title":DoraemonLocalizedString(@"手机信息"),
                               @"array":@[
                                       @{
                                           @"title":DoraemonLocalizedString(@"设备名称"),
                                           @"value":iphoneName
                                           },
                                       @{
                                           @"title":DoraemonLocalizedString(@"手机型号"),
                                           @"value":iphoneType
                                           },
                                       @{
                                           @"title":DoraemonLocalizedString(@"系统版本"),
                                           @"value":iphoneSystemVersion
                                           }
                                       ]
                               },
                           @{
                               @"title":DoraemonLocalizedString(@"App信息"),
                               @"array":@[@{
                                              @"title":@"SDK Version",
                                              @"value":@"2.10.1"
                                              },
                                          @{
                                              @"title":@"lid",
                                              @"value":lid
                                              },
                                          @{
                                              @"title":@"uid",
                                              @"value":companyid
                                              }
                                          ]
                               },
                           @{
                               @"title":DoraemonLocalizedString(@"云端信息"),
                               @"array":@[@{
                                              @"title":DoraemonLocalizedString(@"集群名称"),
                                              @"value":@"international 中国集群"
                                              },
                                          @{
                                              @"title":DoraemonLocalizedString(@"集群名称版本号"),
                                              @"value":@"v5.2.1"
                                              },
                                          @{
                                              @"title":DoraemonLocalizedString(@"域名地址"),
                                              @"value":[NSString stringWithFormat:@"appservice.ibroadlink.com"]
                                              }
                                          ]
                               }
                           ];
    _dataArray = dataArray;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = _dataArray[section][@"array"];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DoraemonAppInfoCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kDoraemonSizeFrom750(120);
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.doraemon_width, kDoraemonSizeFrom750(120))];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDoraemonSizeFrom750(32), 0, DoraemonScreenWidth-kDoraemonSizeFrom750(32), kDoraemonSizeFrom750(120))];
    NSDictionary *dic = _dataArray[section];
    titleLabel.text = dic[@"title"];
    titleLabel.font = [UIFont systemFontOfSize:kDoraemonSizeFrom750(28)];
    titleLabel.textColor = [UIColor doraemon_black_3];
    [sectionView addSubview:titleLabel];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifer = @"httpcell";
    DoraemonAppInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[DoraemonAppInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    NSArray *array = _dataArray[indexPath.section][@"array"];
    NSDictionary *item = array[indexPath.row];
    if (indexPath.section == 2 && indexPath.row == 1 && self.authority) {
        NSMutableDictionary *tempItem = [item mutableCopy];
        [tempItem setValue:self.authority forKey:@"value"];
        [cell renderUIWithData:tempItem];
    }else{
       [cell renderUIWithData:item];
    }
    return cell;
}



@end
