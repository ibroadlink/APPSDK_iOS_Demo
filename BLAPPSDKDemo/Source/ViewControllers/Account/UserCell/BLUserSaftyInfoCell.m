//
//  BLUserSaftyInfoCell.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/3.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "BLUserSaftyInfoCell.h"
#import "BLTheme.h"

@implementation BLUserSaftyInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [BLTheme cardColor];
    self.contentView.backgroundColor = [BLTheme cardColor];
    self.titleLabel.textColor = [BLTheme titleColor];
    self.rightTitleLabel.textColor = [BLTheme subtitleColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
