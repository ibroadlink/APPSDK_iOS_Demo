//
//  BLUserHeadImageCell.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/3.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "BLUserHeadImageCell.h"
#import "BLTheme.h"

@implementation BLUserHeadImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [BLTheme cardColor];
    self.contentView.backgroundColor = [BLTheme cardColor];
    self.IconUrlImageView.layer.cornerRadius = 28;
    self.IconUrlImageView.layer.masksToBounds = YES;
    self.IconUrlImageView.layer.borderWidth = 2;
    self.IconUrlImageView.layer.borderColor = [BLTheme primaryLightColor].CGColor;
    self.titleLabel.textColor = [BLTheme titleColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
