//
//  DNAControlViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DNAControlViewController.h"
#import "DeviceWebControlViewController.h"
#import "GeneralTimerControlView.h"
#import "GateWayViewController.h"
#import "FastconViewController.h"
#import "FastconGroupDeviceViewController.h"
#import "SPViewController.h"
#import "A1ViewController.h"
#import "RMViewController.h"

#import "BLDeviceService.h"
#import "AppMacro.h"
#import "Tools.h"
#import "BLTheme.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, DNAMoreAction) {
    DNAMoreActionWebView = 0,
    DNAMoreActionTimer,
    DNAMoreActionGateway,
    DNAMoreActionFastcon,
    DNAMoreActionRM,
    DNAMoreActionSP,
    DNAMoreActionA1,
    DNAMoreActionFastconGroup,
};

@interface DNAControlViewController () <UITextFieldDelegate>

@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSString *resultText;
@property (nonatomic, copy) NSArray *keyList;
@property (nonatomic, strong) BLStdData *stdData;
@property (nonatomic, copy) NSArray<NSDictionary *> *moreItems;
@property (nonatomic, copy) NSString *serviceProfileType;

@end

@implementation DNAControlViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Device Control";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.device = [BLDeviceService sharedDeviceService].selectDevice;

    [self buildTableView];
    [self refreshProfileDependentUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([BLDeviceService sharedDeviceService].gatewayDevice) {
        [BLDeviceService sharedDeviceService].selectDevice = [BLDeviceService sharedDeviceService].gatewayDevice;
        [BLDeviceService sharedDeviceService].gatewayDevice = nil;
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getKeyList];
    [self refreshProfileDependentUI];
}

- (void)buildTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorColor = [BLTheme separatorColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.estimatedRowHeight = 56;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 8;
    }
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Profile / Params

- (void)refreshProfileDependentUI {
    self.serviceProfileType = [self queryServiceProfileType];
    [self rebuildMoreItems];
    [self.tableView reloadData];
}

- (NSString *)queryServiceProfileType {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    if (![result succeed]) { return nil; }
    NSDictionary *dic = [BLCommonTools deserializeMessageJSON:[result getProfile]];
    NSArray *srvStrArray = dic[@"srvs"];
    if ([BLCommonTools isEmptyArray:srvStrArray]) { return nil; }
    return srvStrArray.firstObject;
}

- (void)rebuildMoreItems {
    NSMutableArray *items = [NSMutableArray array];
    void (^add)(NSString *, DNAMoreAction) = ^(NSString *title, DNAMoreAction action) {
        [items addObject:@{@"title": title, @"action": @(action)}];
    };

    add(@"WebView Control", DNAMoreActionWebView);
    add(@"Timer Task Functions", DNAMoreActionTimer);
    add(@"GateWay Functions", DNAMoreActionGateway);
    add(@"Fastcon Functions", DNAMoreActionFastcon);

    if ([self.serviceProfileType isEqualToString:SMART_RM]) {
        add(@"RM Device Demo", DNAMoreActionRM);
    }
    if ([self.serviceProfileType isEqualToString:SMART_SP]) {
        add(@"SP Device Demo", DNAMoreActionSP);
    }
    if ([self.serviceProfileType isEqualToString:SMART_A1]) {
        add(@"A1 Device Demo", DNAMoreActionA1);
    }

    add(@"FastconGroupDevice", DNAMoreActionFastconGroup);
    self.moreItems = [items copy];
}

- (void)getKeyList {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    if (![result succeed]) {
        self.keyList = @[];
        return;
    }
    NSDictionary *profileDic = [Tools dictionaryFromJSONString:[result getProfile]];
    NSArray *suids = [profileDic[@"suids"] isKindOfClass:[NSArray class]] ? profileDic[@"suids"] : nil;
    NSDictionary *firstSuid = [suids.firstObject isKindOfClass:[NSDictionary class]] ? suids.firstObject : nil;
    NSDictionary *intfsDic = [firstSuid[@"intfs"] isKindOfClass:[NSDictionary class]] ? firstSuid[@"intfs"] : nil;
    if (!intfsDic) {
        self.keyList = @[];
        return;
    }
    NSMutableArray *keyArray = [NSMutableArray array];
    [intfsDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [keyArray addObject:@{key: obj}];
    }];
    self.keyList = [keyArray copy];
}

#pragma mark - Actions

- (void)dnaControlWithAction:(NSString *)action {
    [self.view endEditing:YES];
    [self syncParamValuesFromVisibleCells];

    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLStdControlResult *result = nil;
        if ([BLCommonTools isEmpty:self.device.pDid]) {
            result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device]
                                                     stdData:self.stdData
                                                      action:action];
        } else {
            BLDNADevice *fDevice = [[BLLet sharedLet].controller getDevice:[NSString stringWithFormat:@"%@++%@", self.device.pDid, self.device.ownerId]];
            result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:fDevice]
                                                    subDevDid:[Tools controlDidForDevice:self.device]
                                                      stdData:self.stdData
                                                       action:action];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                self.resultText = [Tools jsonStringFromObject:[[result getData] toDictionary]];
            } else {
                self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}

- (void)showDeviceProfile {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    if ([result succeed]) {
        NSDictionary *dic = [BLCommonTools deserializeMessageJSON:[result getProfile]];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        self.resultText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)selectParams {
    if (self.keyList.count == 0) {
        [self showTextOnly:@"No params in profile"];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Param"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSDictionary *paramDic in self.keyList) {
        NSString *param = paramDic.allKeys.firstObject;
        [alert addAction:[UIAlertAction actionWithTitle:param style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.stdData setValue:@"" forParam:param];
            [self.tableView reloadData];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setParams {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Param"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"param";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *param = alert.textFields.firstObject.text;
        if ([BLCommonTools isEmpty:param]) {
            [self showTextOnly:@"param can not be empty"];
            return;
        }
        [self.stdData setValue:@"" forParam:param];
        [self.tableView reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - More tools

- (void)handleMoreAction:(DNAMoreAction)action {
    switch (action) {
        case DNAMoreActionWebView: [self webViewControl]; break;
        case DNAMoreActionTimer: [self generalTimerControl]; break;
        case DNAMoreActionGateway: [self gateWayControl]; break;
        case DNAMoreActionFastcon: [self fastconNoConfig]; break;
        case DNAMoreActionRM: [self openDeviceDemo:SMART_RM class:[RMViewController class]]; break;
        case DNAMoreActionSP: [self openDeviceDemo:SMART_SP class:[SPViewController class]]; break;
        case DNAMoreActionA1: [self openDeviceDemo:SMART_A1 class:[A1ViewController class]]; break;
        case DNAMoreActionFastconGroup: [self fastconGroupDevice]; break;
    }
}

- (void)openDeviceDemo:(NSString *)expectedType class:(Class)cls {
    if (![self.serviceProfileType isEqualToString:expectedType]) {
        [self showTextOnly:[NSString stringWithFormat:@"Not %@ device", expectedType]];
        return;
    }
    if (![cls respondsToSelector:@selector(viewController)]) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    UIViewController *vc = [cls performSelector:@selector(viewController)];
#pragma clang diagnostic pop
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)webViewControl {
    if (![Tools copyCordovaJsNamed:DNAKIT_CORVODA_JS_FILE forPid:self.device.pid] ||
        ![Tools copyCordovaJsNamed:DNAKIT_CORVODA_PLUGIN_JS_FILE forPid:self.device.pid]) {
        [self showTextOnly:@"Copy Cordova JS failed"];
        return;
    }
    DeviceWebControlViewController *vc = [DeviceWebControlViewController viewController];
    vc.selectDevice = self.device;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)generalTimerControl {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please input query device did or sdid"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Device did or sdid";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        GeneralTimerControlView *vc = [GeneralTimerControlView viewController];
        vc.sdid = alert.textFields.firstObject.text;
        [self.navigationController pushViewController:vc animated:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)gateWayControl {
    [self.navigationController pushViewController:[GateWayViewController viewController] animated:YES];
}

- (void)fastconNoConfig {
    [self.navigationController pushViewController:[FastconViewController viewController] animated:YES];
}

- (void)fastconGroupDevice {
    [self.navigationController pushViewController:[FastconGroupDeviceViewController viewController] animated:YES];
}

#pragma mark - Param value sync

- (void)syncParamValuesFromVisibleCells {
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        if (indexPath.section != 0) { continue; }
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *paramField = [cell.contentView viewWithTag:201];
        UITextField *valueField = [cell.contentView viewWithTag:202];
        if (paramField.text.length == 0) { continue; }
        id value = valueField.text ?: @"";
        if ([self isNumber:valueField.text]) {
            value = @([valueField.text doubleValue]);
        }
        [self.stdData setValue:value forParam:paramField.text];
    }
}

- (BOOL)isNumber:(NSString *)strValue {
    if (strValue.length == 0) { return NO; }
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [strValue isEqualToString:filtered];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return MAX(self.stdData.allParams.count, 1);
        case 1:
        case 2: return 1;
        case 3: return self.moreItems.count;
        default: return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Params and Values";
        case 1: return @"Param Tools";
        case 2: return @"Action";
        case 3: return @"More Tools";
        case 4: return @"Result";
        default: return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: return self.stdData.allParams.count == 0 ? 56 : 64;
        case 1: return 64;
        case 2: return 120;
        case 3: return 52;
        default: return 180;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self paramCellAtIndexPath:indexPath];
    }
    if (indexPath.section == 1) {
        return [self toolButtonsCellWithTitles:@[@"Select Params", @"Set Param"]
                                          tags:@[@110, @111]
                                        reuse:@"DNA_PARAM_TOOL_CELL"];
    }
    if (indexPath.section == 2) {
        return [self actionButtonsCell];
    }
    if (indexPath.section == 3) {
        return [self moreCellAtIndexPath:indexPath];
    }
    return [self resultCell];
}

- (UITableViewCell *)paramCellAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cid = @"DNA_PARAM_CELL";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        UIView *card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        UITextField *paramField = [BLTheme makeTextFieldWithPlaceholder:@"param"];
        paramField.tag = 201;
        paramField.enabled = NO;
        [card addSubview:paramField];

        UITextField *valueField = [BLTheme makeTextFieldWithPlaceholder:@"value"];
        valueField.tag = 202;
        valueField.delegate = self;
        valueField.returnKeyType = UIReturnKeyDone;
        [card addSubview:valueField];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(4, 16, 4, 16));
        }];
        [paramField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(12);
            make.centerY.equalTo(card);
            make.width.equalTo(card).multipliedBy(0.38);
            make.height.mas_equalTo(40);
        }];
        [valueField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(paramField.mas_right).offset(10);
            make.right.equalTo(card).offset(-12);
            make.centerY.equalTo(card);
            make.height.mas_equalTo(40);
        }];
    }

    UITextField *paramField = [cell.contentView viewWithTag:201];
    UITextField *valueField = [cell.contentView viewWithTag:202];
    if (self.stdData.allParams.count == 0) {
        paramField.text = @"";
        valueField.text = @"";
        valueField.placeholder = @"Add a param first";
        valueField.enabled = NO;
    } else {
        NSString *param = self.stdData.allParams[indexPath.row];
        id value = (indexPath.row < self.stdData.allValues.count) ? self.stdData.allValues[indexPath.row] : @"";
        paramField.text = param;
        valueField.text = [NSString stringWithFormat:@"%@", value ?: @""];
        valueField.placeholder = param;
        valueField.enabled = YES;
    }
    return cell;
}

- (UITableViewCell *)toolButtonsCellWithTitles:(NSArray<NSString *> *)titles
                                          tags:(NSArray<NSNumber *> *)tags
                                         reuse:(NSString *)reuse {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuse];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        UIStackView *stack = [[UIStackView alloc] init];
        stack.tag = 210;
        stack.axis = UILayoutConstraintAxisHorizontal;
        stack.spacing = 12;
        stack.distribution = UIStackViewDistributionFillEqually;
        [cell.contentView addSubview:stack];
        [stack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(8, 16, 8, 16));
            make.height.mas_equalTo(48);
        }];

        for (NSInteger i = 0; i < titles.count; i++) {
            UIButton *btn = [BLTheme makeSecondaryButtonWithTitle:titles[i]
                                                            target:self
                                                            action:@selector(toolButtonClick:)];
            btn.tag = tags[i].integerValue;
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(48);
            }];
            [stack addArrangedSubview:btn];
        }
    }
    return cell;
}

- (UITableViewCell *)actionButtonsCell {
    static NSString *cid = @"DNA_ACTION_CELL";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        UIButton *getBtn = [BLTheme makePrimaryButtonWithTitle:@"Get" target:self action:@selector(toolButtonClick:)];
        getBtn.tag = 101;
        UIButton *setBtn = [BLTheme makePrimaryButtonWithTitle:@"Set" target:self action:@selector(toolButtonClick:)];
        setBtn.tag = 102;
        UIButton *profileBtn = [BLTheme makeSecondaryButtonWithTitle:@"Profile" target:self action:@selector(toolButtonClick:)];
        profileBtn.tag = 107;

        UIStackView *row1 = [[UIStackView alloc] initWithArrangedSubviews:@[getBtn, setBtn]];
        row1.axis = UILayoutConstraintAxisHorizontal;
        row1.spacing = 12;
        row1.distribution = UIStackViewDistributionFillEqually;

        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[row1, profileBtn]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 10;
        [cell.contentView addSubview:stack];

        [getBtn mas_makeConstraints:^(MASConstraintMaker *make) { make.height.mas_equalTo(48); }];
        [setBtn mas_makeConstraints:^(MASConstraintMaker *make) { make.height.mas_equalTo(48); }];
        [profileBtn mas_makeConstraints:^(MASConstraintMaker *make) { make.height.mas_equalTo(48); }];
        [stack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(8, 16, 8, 16));
        }];
    }
    return cell;
}

- (UITableViewCell *)moreCellAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cid = @"DNA_MORE_CELL";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        UIView *card = [[UIView alloc] init];
        card.tag = 300;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        UILabel *title = [[UILabel alloc] init];
        title.tag = 301;
        title.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        title.textColor = [BLTheme titleColor];
        [card addSubview:title];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(4, 16, 4, 16));
        }];
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
        }];
    }
    UILabel *title = [cell.contentView viewWithTag:301];
    title.text = self.moreItems[indexPath.row][@"title"];
    return cell;
}

- (UITableViewCell *)resultCell {
    static NSString *cid = @"DNA_RESULT_CELL";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        UITextView *textView = [[UITextView alloc] init];
        textView.tag = 400;
        textView.editable = NO;
        textView.selectable = YES;
        [BLTheme styleResultTextView:textView];
        [cell.contentView addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(4, 16, 8, 16));
            make.height.mas_equalTo(160);
        }];
    }
    UITextView *textView = [cell.contentView viewWithTag:400];
    textView.text = self.resultText.length ? self.resultText : @"Result will appear here.";
    return cell;
}

- (void)toolButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101: [self dnaControlWithAction:@"get"]; break;
        case 102: [self dnaControlWithAction:@"set"]; break;
        case 107: [self showDeviceProfile]; break;
        case 110: [self selectParams]; break;
        case 111: [self setParams]; break;
        default: break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section != 3) { return; }
    DNAMoreAction action = [self.moreItems[indexPath.row][@"action"] integerValue];
    [self handleMoreAction:action];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && self.stdData.allParams.count > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete || indexPath.section != 0) { return; }
    if (indexPath.row >= self.stdData.allParams.count) { return; }
    NSMutableArray *params = [self.stdData.allParams mutableCopy];
    NSMutableArray *values = [self.stdData.allValues mutableCopy];
    [params removeObjectAtIndex:indexPath.row];
    if (indexPath.row < values.count) {
        [values removeObjectAtIndex:indexPath.row];
    }
    [self.stdData setParams:params values:values];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Property

- (BLStdData *)stdData {
    if (!_stdData) {
        _stdData = [[BLStdData alloc] init];
    }
    return _stdData;
}

@end
