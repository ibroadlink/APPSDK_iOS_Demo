//
//  BLLoadingButton.m
//  ihc
//
//  Created by apple on 2017/4/20.
//  Copyright © 2017年 broadlink. All rights reserved.
//

#import "BLLoadingButton.h"

#define kWidth 25

@interface BLLoadingButton ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation BLLoadingButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self viewInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self viewInit];
    }
    return self;
}

- (void)viewInit {
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.indicatorView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indicatorView.frame = CGRectMake(self.frame.size.width / 2 - kWidth / 2.0, self.frame.size.height / 2 - kWidth / 2.0, kWidth, kWidth);
}


- (void)setIsLoading:(BOOL)isLoading{
    if (_isLoading == isLoading) {
        return;
    }
    [self willChangeValueForKey:@"isLoading"];
    _isLoading = isLoading;
    [self didChangeValueForKey:@"isLoading"];
    if (isLoading) {
        [self.indicatorView startAnimating];
        self.userInteractionEnabled = NO;
        self.titleLabel.alpha = 0;
    } else {
        [self.indicatorView stopAnimating];
        self.userInteractionEnabled = YES;
        self.titleLabel.alpha = 1;
    }
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"isLoading"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    if (buttonType == UIButtonTypeSystem) {
        buttonType = UIButtonTypeCustom;
    }
    return [super buttonWithType:buttonType];
}

@end
