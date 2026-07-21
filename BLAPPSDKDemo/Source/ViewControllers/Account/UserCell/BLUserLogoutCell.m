//
//  BLUserLogoutCell.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/3.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "BLUserLogoutCell.h"
#import "BLTheme.h"

@implementation BLUserLogoutCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [[BLTheme dangerColor] colorWithAlphaComponent:0.08];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [BLTheme dangerColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
