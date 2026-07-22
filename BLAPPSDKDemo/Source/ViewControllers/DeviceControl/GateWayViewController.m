//
//  GateWayViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/31.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "GateWayViewController.h"
#import "DeviceWebControlViewController.h"
#import <BLSFamily/BLSFamily.h>
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "SSZipArchive.h"
#import "AppMacro.h"
#import "BLFamilyDefult.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface GateWayViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) BLDNADevice *subDevice;
@property (nonatomic, strong) NSMutableDictionary *privateDataCache;
@property (nonatomic, strong) NSMutableArray<BLDNADevice *> *subDevicelist;
@property (nonatomic, assign) BOOL isAdd;
@property (nonatomic, strong) NSString *spid;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GateWayViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Gateway Functions";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.subDevicelist = [NSMutableArray arrayWithCapacity:0];
    self.privateDataCache = [NSMutableDictionary dictionaryWithCapacity:0];

    NSString *familyId = [BLFamilyDefult sharedFamily].currentFamilyInfo.familyid;
    if (familyId.length > 0) {
        [BLConfigParam sharedConfigParam].familyId = familyId;
    }

    [self buildUI];
    [self write];
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    UIButton *startBtn = [BLTheme makePrimaryButtonWithTitle:@"SubDev Scanning Start" target:self action:@selector(subDevStart)];
    UIButton *stopBtn = [BLTheme makeSecondaryButtonWithTitle:@"SubDev Scanning Stop" target:self action:@selector(subDevStop)];
    UIButton *newListBtn = [BLTheme makeSecondaryButtonWithTitle:@"Get NewSubDev List" target:self action:@selector(getNewSubDevList)];
    UIButton *queryBtn = [BLTheme makeSecondaryButtonWithTitle:@"Query SubDev List" target:self action:@selector(querySubDevList)];

    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[startBtn, stopBtn, newListBtn, queryBtn]];
    actions.axis = UILayoutConstraintAxisVertical;
    actions.spacing = 10;
    [content addSubview:actions];

    for (UIButton *btn in @[startBtn, stopBtn, newListBtn, queryBtn]) {
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
        }];
    }

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorColor = [BLTheme separatorColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.tableView];
    [content addSubview:self.tableView];

    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scroll);
        make.width.equalTo(scroll);
    }];
    [actions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(12);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(actions.mas_bottom).offset(12);
        make.left.right.equalTo(actions);
        make.height.mas_equalTo(400);
        make.bottom.equalTo(content).offset(-24);
    }];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subDevicelist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SUB_DEVICE_LIST_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        cell.detailTextLabel.textColor = [BLTheme subtitleColor];
    }
    BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
    cell.textLabel.text = subDevice.did;
    cell.detailTextLabel.text = subDevice.pid;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
    if (self.isAdd) {
        [self addSubDev:subDevice];
    } else {
        [[BLLet sharedLet].controller addDevice:subDevice];
        [self showIndicatorOnWindowWithMessage:@"Download Script and UI..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *scriptFile = [[BLLet sharedLet].controller queryScriptFileName:subDevice.pid];
            NSString *uiPath = [[BLLet sharedLet].controller queryUIPath:subDevice.pid];
            NSString *uiFile = [uiPath stringByAppendingString:subDevice.pid];
            __block BOOL isDownloadScript = YES;
            __block BOOL isDownloadUI = YES;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            dispatch_group_t group = dispatch_group_create();

            if (![fileManager fileExistsAtPath:scriptFile]) {
                dispatch_group_enter(group);
                [[BLLet sharedLet].controller downloadScript:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {
                    dispatch_group_leave(group);
                    if ([result succeed]) {
                        isDownloadScript = YES;
                        NSLog(@"downloadScript savepath:%@", result.savePath);
                    } else {
                        isDownloadScript = NO;
                        NSLog(@"downloadScript failed: %@", result.msg);
                    }
                }];
            }

            if (![fileManager fileExistsAtPath:uiFile]) {
                dispatch_group_enter(group);
                [[BLLet sharedLet].controller downloadUI:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {
                    if ([result succeed]) {
                        isDownloadUI = YES;
                        NSLog(@"downloadUI savepath:%@", result.savePath);
                        [SSZipArchive unzipFileAtPath:result.savePath toDestination:uiPath];
                    } else {
                        isDownloadUI = NO;
                        NSLog(@"downloadUI failed: %@", result.msg);
                    }
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (isDownloadScript && isDownloadUI) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[BLDeviceService sharedDeviceService] addNewDeivce:subDevice];
                        if ([Tools copyCordovaJsNamed:DNAKIT_CORVODA_JS_FILE forPid:subDevice.pid]) {
                            DeviceWebControlViewController *vc = [DeviceWebControlViewController viewController];
                            vc.selectDevice = subDevice;
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                        [self hideIndicatorOnWindow];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [BLStatusBar showTipMessageWithStatus:@"Download script or ui failed!!!"];
                        [self hideIndicatorOnWindow];
                    });
                }
            });
        });
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
        [self deleteSubDev:subDevice];
    }
}

#pragma mark - Actions

- (void)subDevStart {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"set the subDevice pid" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Please the subDevice pid";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.spid = alertController.textFields.firstObject.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BLBaseResult *result = [[BLLet sharedLet].controller subDevScanStartWithDid:[Tools controlDidForDevice:self.device] subPid:self.spid];
            dispatch_async(dispatch_get_main_queue(), ^{
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            });
        });
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)subDevStop {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLBaseResult *result = [[BLLet sharedLet].controller subDevScanStopWithDid:[Tools controlDidForDevice:self.device]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    });
}

- (void)getNewSubDevList {
    [self showIndicatorOnWindowWithMessage:@"Get new sub devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self subDevNewListQuery:0];
    });
}

- (void)querySubDevList {
    [self showIndicatorOnWindowWithMessage:@"Get sub devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self subDevListQuery:0];
    });
}

- (void)subDevNewListQuery:(NSUInteger)index {
    if (index == 0) {
        self.isAdd = YES;
        [self.subDevicelist removeAllObjects];
    }
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevNewListQueryWithDid:[Tools controlDidForDevice:self.device] index:index count:10 subPid:self.spid];
    if ([result succeed]) {
        if (result.list.count > 0) {
            [self.subDevicelist addObjectsFromArray:result.list];
        }
        if (self.subDevicelist.count < result.total) {
            [self subDevNewListQuery:++index];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.tableView reloadData];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    }
}

- (void)subDevListQuery:(NSUInteger)index {
    if (index == 0) {
        self.isAdd = NO;
        [self.subDevicelist removeAllObjects];
    }
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevListQueryWithDid:[Tools controlDidForDevice:self.device] index:index count:10];
    if ([result succeed]) {
        if (result.list.count > 0) {
            [self.subDevicelist addObjectsFromArray:result.list];
        }
        if (self.subDevicelist.count < result.total) {
            [self subDevListQuery:++index];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.tableView reloadData];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    }
}

- (void)addSubDev:(BLDNADevice *)subDevice {
    BLBaseResult *result = [[BLLet sharedLet].controller subDevAddWithDid:[Tools controlDidForDevice:self.device] subDevInfo:subDevice];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"AddSubDev:%@ success", subDevice.getDid]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self showIndicatorOnWindowWithMessage:@"Get sub devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self subDevListQuery:0];
    });
}

- (void)deleteSubDev:(BLDNADevice *)subDevice {
    BLBaseResult *result = [[BLLet sharedLet].controller subDevDelWithDid:[Tools controlDidForDevice:self.device] subDevDid:subDevice.getDid];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"DeleteSubDev:%@ success", subDevice.getDid]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self showIndicatorOnWindowWithMessage:@"Get sub devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self subDevListQuery:0];
    });
}

- (void)write {
    __weak typeof(self) weakSelf = self;
    [[BLLet sharedLet].controller setSDKRawWithReadBlock:^unsigned char * _Nullable(int sync, unsigned char * _Nullable key) {
        NSLog(@"%d,%s", sync, key);
        NSString *pKey = [NSString stringWithUTF8String:(const char *)key];
        NSString *pData = [weakSelf.privateDataCache objectForKey:pKey];
        if (pData) {
            return (unsigned char *)pData.UTF8String;
        }
        return NULL;
    } writeBlock:^unsigned char * _Nullable(int sync, unsigned char * _Nullable key, unsigned char * _Nullable data) {
        NSLog(@"%d,%s,%s", sync, key, data);
        NSString *pKey = [NSString stringWithUTF8String:(const char *)key];
        NSString *pData = [NSString stringWithUTF8String:(const char *)data];
        [weakSelf.privateDataCache setObject:pData forKey:pKey];
        return NULL;
    }];
}

@end
