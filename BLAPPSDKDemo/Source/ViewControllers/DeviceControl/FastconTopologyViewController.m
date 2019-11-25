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
#import "BLTopologyModel.h"

@interface FastconTopologyViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) BLDNADevice *device;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic) BLTopologyModel *topologyModel;
@property (strong,nonatomic) BLTopologyDevice *selectTopologyDevice;
@property (strong,nonatomic) NSMutableArray *allDeviceList;
@property (strong,nonatomic) NSMutableArray *needShowDeviceList;
@end

@implementation FastconTopologyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewInit];
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
//    NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.did subDevDid:nil dataStr:@"{}" command:@"device_fastcon_bridge_devices" scriptPath:nil];
//    NSLog(@"result:%@",result);
//    NSDictionary *allDeviceDic = [BLCommonTools deserializeMessageJSON:result];
    NSDictionary *allDeviceDic = @{
        @"status": @0,
        @"msg": @"success",
        @"data": @{
            @"count": @6,
            @"deviceList": @[@{
                @"mac": @"c8:f7:42:fe:2b:a2",
                @"rssi": @0,
                @"parentIndex": @65535
            }, @{
                @"mac": @"c8:f7:42:fe:2b:a1",
                @"rssi": @-46,
                @"parentIndex": @0
            }, @{
                @"mac": @"78:0f:77:e6:78:3b",
                @"rssi": @-63,
                @"parentIndex": @3
            }, @{
                @"mac": @"78:0f:77:e6:77:eb",
                @"rssi": @-59,
                @"parentIndex": @1
            }, @{
                @"mac": @"34:ea:34:18:9d:2b",
                @"rssi": @-49,
                @"parentIndex": @3
            }, @{
                @"mac": @"78:0f:77:b3:e5:0b",
                @"rssi": @-61,
                @"parentIndex": @4
            }]
        }
    };
    self.topologyModel = [BLTopologyModel BLS_modelWithJSON:allDeviceDic];
    NSMutableOrderedSet  *set = [NSMutableOrderedSet  orderedSet];
    [self.topologyModel.deviceList enumerateObjectsUsingBlock:^(BLTopologyDevice *obj, NSUInteger idx, BOOL *stop) {
        [set addObject:@(obj.parentIndex)];//利用set不重复的特性,得到有多少组,根据数组中的MeasureType字段
    }];
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentIndex = %@", obj];//创建谓词筛选器
        NSArray *group = [self.topologyModel.deviceList filteredArrayUsingPredicate:predicate];//用数组的过滤方法得到新的数组,在添加的最终的数组_slices中<br>
        [self.allDeviceList addObject:group];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getDeviceTopologyList:65535];
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

- (void)getDeviceTopologyList:(NSInteger)parentIndex {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.allDeviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *group = obj;
            for (BLTopologyDevice *topologyDevice in group) {
                if (topologyDevice.parentIndex == parentIndex) {
                    [self.needShowDeviceList addObject:group];
                    *stop = YES;
                    return;
                }
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.collectionView reloadData];
        });
    });
}



#pragma mark --- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showIndicatorOnWindow];
//    NSLog(@"section:%ld,row:%ld",(long)indexPath.section,(long)indexPath.row);
    BLTopologyDevice *topologyDevice = self.needShowDeviceList[indexPath.section][indexPath.row];
    NSInteger index = [self.topologyModel.deviceList indexOfObject:topologyDevice];
    if (self.needShowDeviceList.count > indexPath.section + 1) {
        [self.needShowDeviceList removeObjectsInRange:NSMakeRange(indexPath.section + 1, self.needShowDeviceList.count - indexPath.section - 1)];
    }
    
    [self getDeviceTopologyList:index];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.collectionView reloadData];
        });
    });
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"deviceidCell" forIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:101];
    UILabel *label = [cell viewWithTag:102];
    cell.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"default_module_icon"]];
    BLTopologyDevice *topologyDevice = self.needShowDeviceList[indexPath.section][indexPath.row];
    label.text = topologyDevice.mac;
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.needShowDeviceList.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = self.needShowDeviceList[section];
    return array.count;
    
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

    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        HeaderCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier" forIndexPath:indexPath];
        BLTopologyDevice *topologyDevice = self.needShowDeviceList[indexPath.section - 1][indexPath.row];
        headerView.label.text = [NSString stringWithFormat:@"%@的子设备",topologyDevice.mac];
        NSLog(@"section:%ld,row:%ld,mac:%@",(long)indexPath.section,(long)indexPath.row,topologyDevice.mac);
        headerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        reusableview = headerView;


    }else if (kind == UICollectionElementKindSectionFooter){
        HeaderCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerIdentifier" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor whiteColor];
        reusableview = headerView;
    }

    return reusableview;
}

- (NSMutableArray *)needShowDeviceList {
    if (!_needShowDeviceList) {
        _needShowDeviceList = [NSMutableArray array];
    }
    return _needShowDeviceList;
}

- (NSMutableArray *)allDeviceList {
    if (!_allDeviceList) {
        _allDeviceList = [NSMutableArray array];
    }
    return _allDeviceList;
}

@end





