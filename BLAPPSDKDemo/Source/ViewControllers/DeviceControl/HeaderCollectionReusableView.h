//
//  HaderCollectionReusableView.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/10/23.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeaderCollectionReusableView : UICollectionReusableView
@property(nonatomic,retain)UILabel * label;
@property(nonatomic,retain)UIImageView *imageView;
-(void)updateLabelFrame;
@end

NS_ASSUME_NONNULL_END
