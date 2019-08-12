//
//  FamilyListViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyListViewController.h"
#import "FamilyDetailViewController.h"
#import "BLStatusBar.h"
#import "DropDownList.h"
#import "BLNewFamilyManager.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface FamilyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)NSArray<BLSFamilyInfo *> *familyInfos;

@end

@implementation FamilyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.familyInfos = [[NSArray alloc] init];
    self.familyListTableView.delegate = self;
    self.familyListTableView.dataSource = self;
    [self setExtraCellLineHidden:self.familyListTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryFamilyBaseList];
}

+ (instancetype)viewController {
    FamilyListViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.familyInfos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"FAMILY_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.section];
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:100];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:familyInfo.iconpath] placeholderImage:[UIImage imageNamed:@"default_family"]];
    
    UILabel *familyNameLabel = (UILabel *)[cell viewWithTag:101];
    familyNameLabel.text = familyInfo.name;
    
    UILabel *familyIdLabel = (UILabel *)[cell viewWithTag:102];
    familyIdLabel.text = familyInfo.familyid;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.section];
    [self performSegueWithIdentifier:@"FamilyDetailView" sender:familyInfo];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSFamilyInfo *familyInfo = self.familyInfos[indexPath.row];
        BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
        
        [self showIndicatorOnWindow];
        [manager delFamilyWithFamilyid:familyInfo.familyid completionHandler:^(BLBaseResult * _Nonnull result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];

                if ([result succeed]) {
                    [BLStatusBar showTipMessageWithStatus:@"Delete Family success!"];
                    [self queryFamilyBaseList];
                } else {
                    NSLog(@"ERROR :%@", result.msg);
                    [BLStatusBar showTipMessageWithStatus:[@"Delete Family failed! " stringByAppendingString:result.msg]];
                }
            });
        }];
    }
}

#pragma mark - private method

- (void)queryFamilyBaseList {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
        [manager queryFamilyBaseInfoListWithCompletionHandler:^(BLSFamilyListResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                
                if ([result succeed]) {
                    self.familyInfos = result.familyList;
                    [self.familyListTableView reloadData];
                } else {
                    NSLog(@"error:%ld msg:%@", (long)result.error, result.msg);
                    [BLStatusBar showTipMessageWithStatus:result.msg];
                }
            });
        }];
    });
}

- (IBAction)addFamilyBtnClick:(UIBarButtonItem *)sender {
    NSArray *keyList = @[@"创建家庭",@"加入家庭"];
    CGFloat drop_X = CGRectGetMaxX(self.navigationController.navigationBar.frame) - 100;
    CGFloat drop_Y = 5;
    CGFloat drop_W = 100;
    CGFloat drop_H = keyList.count * 40 + 10;
    
    DropDownList *dropList = [[DropDownList alloc] initWithFrame:CGRectMake(drop_X, drop_Y, drop_W, drop_H) dataArray:keyList onTheView:self.view] ;
    
    dropList.myBlock = ^(NSInteger row,NSString *title)
    {
        if (row == 0) {
            [self performSegueWithIdentifier:@"CreateFamilyView" sender:nil];
        }else {
            [self performSegueWithIdentifier:@"JoinFamilyView" sender:nil];
        }
    };
    
    [self.view addSubview:dropList];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FamilyDetailView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[FamilyDetailViewController class]]) {
            [BLNewFamilyManager sharedFamily].familyid = ((BLSFamilyInfo *)sender).familyid;

            FamilyDetailViewController* vc = (FamilyDetailViewController *)target;
            vc.familyInfo = (BLSFamilyInfo *)sender;
        }
    }
}


@end
