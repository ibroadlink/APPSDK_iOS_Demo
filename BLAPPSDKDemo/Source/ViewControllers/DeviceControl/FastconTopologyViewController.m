//
//  FastconTopologyViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/10/22.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "FastconTopologyViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BLDeviceService.h"
#import "JYEqualCellSpaceFlowLayout.h"
#import "HeaderCollectionReusableView.h"

@interface FastconTopologyViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) BLDNADevice *device;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic) NSMutableArray *subdeviceArray;
@property (strong,nonatomic) NSMutableArray *secondSubdeviceArray;
@property (strong,nonatomic) NSDictionary *allDeviceDic;
@property (strong,nonatomic) NSString *secondSubdeviceMac;
@end

@implementation FastconTopologyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewInit];
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.allDeviceDic = @{
                        @"c8:f7:42:81:f7:4e":@[@"b4:43:0d:12:13:14",@"b4:43:0d:12:13:15",@"b4:43:0d:12:13:16",@"b4:43:0d:12:13:17"],
                        @"b4:43:0d:12:13:14":@[@"b4:43:0d:12:13:18"],
                        @"b4:43:0d:12:13:15":@[@"b4:43:0d:12:13:19",@"b4:43:0d:12:13:20"],
                        @"b4:43:0d:12:13:16":@[@"b4:43:0d:12:13:21",@"b4:43:0d:12:13:22",@"b4:43:0d:12:13:23"],
                        @"b4:43:0d:12:13:17":@[@"b4:43:0d:12:13:24",@"b4:43:0d:12:13:25",@"b4:43:0d:12:13:26",@"b4:43:0d:12:13:27",@"b4:43:0d:12:13:28"],
                        };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getDeviceTopologyList];
}

- (void)viewInit {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    JYEqualCellSpaceFlowLayout * flowLayout = [[JYEqualCellSpaceFlowLayout alloc]initWithType:AlignWithCenter betweenOfCell:25.0];
    flowLayout.footerReferenceSize = CGSizeMake(0.0f, 0.0f);
    self.collectionView.collectionViewLayout = flowLayout;
    [self.collectionView registerClass:[HeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier"];
    [self.collectionView registerClass:[HeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerIdentifier"];
}

+ (instancetype)viewController {
    FastconTopologyViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)getDeviceTopologyList {
    [self showIndicatorOnWindow];
    //搜索子设备
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        self.subdeviceArray = [self.allDeviceDic objectForKey:self.device.mac];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.collectionView reloadData];
        });
    });
}



#pragma mark --- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self showIndicatorOnWindow];
        //搜索子设备
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(1);
            self.subdeviceArray = [self.allDeviceDic objectForKey:self.device.mac];
            [self.secondSubdeviceArray removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.collectionView reloadData];
            });
        });
        
        
    } else if (indexPath.section == 1) {
        self.secondSubdeviceMac = self.subdeviceArray[indexPath.row];
        [self showIndicatorOnWindow];
        //搜索二级子设备
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(1);
            [self.secondSubdeviceArray setArray:[self.allDeviceDic objectForKey:self.secondSubdeviceMac]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.collectionView reloadData];
            });
        });
        
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"deviceidCell" forIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:101];
    UILabel *label = [cell viewWithTag:102];
    cell.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    if (indexPath.section == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        [imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"default_module_icon"]];
        label.text = self.device.mac;
    }else if (indexPath.section == 1){
        cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        [imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"default_module_icon"]];
        label.text = self.subdeviceArray[indexPath.row];
    }else {
        cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"default_module_icon"]];
        label.text = self.secondSubdeviceArray[indexPath.row];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!self.secondSubdeviceArray.count) {
        return 2;
    }else {
        return 3;
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        return self.subdeviceArray.count;
    }else {
        return self.secondSubdeviceArray.count;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 90);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return CGSizeMake(self.view.bounds.size.width, 50);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
        if (section != 0) {
            return CGSizeMake(self.view.bounds.size.width, 10);
        }
    return CGSizeZero;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"kind:%@",kind);
    NSLog(@"section:%ld,row:%ld",(long)indexPath.section,(long)indexPath.row);
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        if (indexPath.section == 1) {
            HeaderCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier" forIndexPath:indexPath];
            headerView.label.text = [NSString stringWithFormat:@"%@的子设备",self.device.mac];;
            headerView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
            reusableview = headerView;
        }else {
            HeaderCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier" forIndexPath:indexPath];
            headerView.label.text = [NSString stringWithFormat:@"%@的子设备",self.secondSubdeviceMac];
            headerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            reusableview = headerView;
        }
        
        
    }else if (kind == UICollectionElementKindSectionFooter){
        HeaderCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerIdentifier" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor whiteColor];
        reusableview = headerView;
    }
    
    return reusableview;
}

- (NSMutableArray *)subdeviceArray {
    if (!_subdeviceArray) {
        _subdeviceArray = [NSMutableArray array];
    }
    return _subdeviceArray;
}

- (NSMutableArray *)secondSubdeviceArray {
    if (!_secondSubdeviceArray) {
        _secondSubdeviceArray = [NSMutableArray array];
    }
    return _secondSubdeviceArray;
}

- (NSDictionary *)allDeviceDic {
    if (!_allDeviceDic) {
        _allDeviceDic = [NSDictionary dictionary];
    }
    return _allDeviceDic;
}
@end
