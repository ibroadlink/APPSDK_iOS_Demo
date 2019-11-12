//
//  HaderCollectionReusableView.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/10/23.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "HeaderCollectionReusableView.h"

@implementation HeaderCollectionReusableView
-(instancetype)init{
    self = [super init];
    if (self){
        _label = [[UILabel alloc]initWithFrame:self.bounds];
        _label.backgroundColor = [UIColor blueColor];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:25];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
        [self addSubview:_label];
    }
    return self;
}
-(void)updateLabelFrame{
    _label.frame = self.bounds;
}
@end
