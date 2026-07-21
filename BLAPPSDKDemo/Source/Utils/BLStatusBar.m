//
//  BLStatusBar.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BLStatusBar.h"
#import "BLTheme.h"

@interface BLStatusBar ()
@property (nonatomic, strong, readwrite) UIWindow *overlayWindow;
@property (nonatomic, strong, readwrite) UIView *topBar;
@property (nonatomic, strong) UILabel *stringLabel;
@property (nonatomic, strong) UILabel* coinLabel;
@property (nonatomic ,strong) UIImageView* topImageView;
@property (nonatomic, strong) UIImageView* coinImageView;
@property (nonatomic ,assign) BOOL showing ;
@end

@implementation BLStatusBar

@synthesize topBar, overlayWindow, stringLabel, coinLabel,topImageView,coinImageView;

+(BLStatusBar* )sharedView{
    static dispatch_once_t once;
    static BLStatusBar* sharedView;
    dispatch_once(&once, ^ {
        sharedView=[[BLStatusBar alloc]initWithFrame:[UIScreen mainScreen].bounds] ;
    });
    return sharedView;
}

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled=NO;
        self.backgroundColor=[UIColor clearColor];
        self.alpha =1;
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

-(UIWindow* )overlayWindow{
    if (!overlayWindow) {
        overlayWindow=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled= NO;
        overlayWindow.windowLevel=UIWindowLevelStatusBar;
    }
    return overlayWindow;
    
}
-(UIView* )topBar{
    if(!topBar) {
        topBar = [[UIView alloc] init];
        
        topBar.frame =CGRectMake(0, [UIScreen mainScreen].bounds.size.height-32, overlayWindow.frame.size.width, 30.0);
        topBar.alpha =1;
        topBar.layer.cornerRadius =18.0;
        topBar.layer.masksToBounds = YES;
        [overlayWindow addSubview:topBar];
    }
    return topBar;
}
-(UILabel* )stringLabel{
    if (stringLabel ==nil) {
        stringLabel =[[UILabel alloc]initWithFrame:CGRectZero];
        stringLabel.textColor= [UIColor whiteColor];
        stringLabel.backgroundColor=[UIColor clearColor];
        stringLabel.adjustsFontSizeToFitWidth =YES;
        stringLabel.textAlignment = NSTextAlignmentCenter;
        stringLabel.baselineAdjustment =UIBaselineAdjustmentAlignCenters;
        stringLabel.font =[UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        stringLabel.numberOfLines=0;
    }
    if (!stringLabel.superview) {
        [self.topBar addSubview:stringLabel];
    }
    return stringLabel;
}
-(UILabel* )coinLabel{
    if (coinLabel ==nil) {
        coinLabel =[[UILabel alloc]initWithFrame:CGRectZero];
        
        coinLabel.backgroundColor=[UIColor clearColor];
        coinLabel.adjustsFontSizeToFitWidth =YES;
        coinLabel.textAlignment = NSTextAlignmentLeft;
        //        coinLabel.baselineAdjustment =UIBaselineAdjustmentAlignCenters;
        coinLabel.font =[UIFont systemFontOfSize:14.0];
        coinLabel.numberOfLines=1;
    }
    if (!coinLabel.superview) {
        [self.topBar addSubview:coinLabel];
    }
    return coinLabel;
}

-(UIImageView* )topImageView{
    if (!topImageView) {
        topImageView=[[UIImageView alloc]initWithFrame:CGRectZero];
        
    }
    if (!topImageView.superview)
        [self.topBar addSubview:topImageView];
    
    return topImageView;
}
-(UIImageView* )coinImageView{
    if (!coinImageView) {
        coinImageView=[[UIImageView alloc]initWithFrame:CGRectZero];
        
    }
    if (!coinImageView.superview)
        [self.topBar addSubview:coinImageView];
    
    return coinImageView;
}

+(void)showTipMessageWithStatus:(NSString* )message{
    if (![BLStatusBar sharedView].showing) {
        [[BLStatusBar sharedView] showStatusWithString:message andTopImage:nil andTipIsBottom:NO];
        [BLStatusBar performSelector:@selector(dismiss) withObject:nil afterDelay:3.0f ];
    }
}

+(void)showTipMessageWithStatus:(NSString* )message andImage:(UIImage* )image andTipIsBottom:(BOOL)isBottom{
    if (![BLStatusBar sharedView].showing) {
        [[BLStatusBar sharedView] showStatusWithString:message andTopImage:image andTipIsBottom:(BOOL)isBottom];
        [BLStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:1.0f ];
    }
}

+(void)showTipMessageWithStatus:(NSString* )message andImage:(UIImage* )image andCoin:(NSString*)coin andSecImage:(UIImage*)secImage
                 andTipIsBottom:(BOOL)isBottom{
    if (![BLStatusBar sharedView].showing) {
        
        [[BLStatusBar sharedView] showStatusWithString:message andTopImage:image andCoin:coin andSecImage:secImage andTipIsBottom:(BOOL)isBottom];
        
        [BLStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:1.0 ];
    }
    
}

+(void)dismiss{
    
    [[BLStatusBar sharedView] dismiss];
    
}

-(void)dismiss{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [stringLabel removeFromSuperview];
        stringLabel = nil;
        topBar.alpha = 0.0;
        [topBar removeFromSuperview];
        topBar = nil;
        
        NSLog(@"  %@ ",self.subviews);
    });
    self.showing =NO;
}

-(void)showStatusWithString:(NSString* )string andTopImage:(UIImage *)image andTipIsBottom:(BOOL)isBottom{
    if (!self.superview)
        [self.overlayWindow addSubview:self];
    
    self.showing =YES;
    self.topBar.backgroundColor=[BLTheme toastBackgroundColor];
    NSString* text=string;
    UIImage* topImage=image;
    CGRect labelRect = CGRectZero;
    CGFloat width =0;
    CGFloat height =0;
    
    self.stringLabel.hidden=NO;
    self.stringLabel.text=text;
    self.stringLabel.textColor =[UIColor whiteColor];
    if (image !=nil) {
        self.topImageView.frame =CGRectMake(14, 10.5, 15, 15);
        self.topImageView.image=topImage;
    }else{
        self.topImageView.frame =CGRectMake(0, 0, 0, 0);
    }
    if (string) {
        CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 80, 60);
        NSDictionary *attrDic = @{NSFontAttributeName:self.stringLabel.font};
        CGSize stringSize = [text boundingRectWithSize:size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attrDic
                                               context:nil].size;
        width =stringSize.width;
        height =MAX(stringSize.height, 18);
        CGFloat labelX = image ? (self.topImageView.frame.origin.x + 22) : 16;
        labelRect =CGRectMake(labelX, 10, width, height);
    }
    self.stringLabel.frame=labelRect;
    CGFloat barWidth = MAX(120, self.topImageView.frame.size.width + self.stringLabel.frame.size.width + 40);
    CGFloat barHeight = MAX(36, height + 20);
    CGFloat barX = ([UIScreen mainScreen].bounds.size.width - barWidth) / 2.0;
    CGFloat barY = [UIScreen mainScreen].bounds.size.height - barHeight - 64;
    self.topBar.frame = CGRectMake(barX, barY, barWidth, barHeight);
    self.topBar.layer.cornerRadius = barHeight / 2.0;
    [self.overlayWindow setHidden:NO];
    
    self.topBar.alpha =1.0;

    [self setNeedsDisplay];
    
}
-(void)showStatusWithString:(NSString* )string andTopImage:(UIImage *)image andCoin:(NSString*)coin andSecImage:(UIImage*)secImage andTipIsBottom:(BOOL)isBottom{
    if (!self.superview)
        [self.overlayWindow addSubview:self];
    self.topBar.backgroundColor=[BLTheme toastBackgroundColor];
    NSString* text=string;
    UIImage* topImage=image;
    
    CGRect labelRect = CGRectZero;
    CGFloat width =0;
    CGFloat height =0;
    
    if (image !=nil) {
        self.topImageView.frame =CGRectMake(14, 10.5, 15, 15);
        
        self.topImageView.image=topImage;
    }
    
    if (string) {
        CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 80, 60);
        NSDictionary *attrDic = @{NSFontAttributeName:self.stringLabel.font};
        CGSize stringSize = [text boundingRectWithSize:size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attrDic
                                               context:nil].size;
        width =stringSize.width;
        height =MAX(stringSize.height, 18);
        labelRect =CGRectMake((self.topImageView.frame.origin.x +22), 10, width, height);
    }
    self.stringLabel.frame=labelRect;
    
    self.stringLabel.hidden=NO;
    self.stringLabel.text=text;
    self.stringLabel.textColor =[UIColor whiteColor];
    
    
    
    NSString* cointext =coin;
    self.coinLabel.text =cointext;
    
    self.coinLabel.textColor = [UIColor whiteColor];
    [self.coinLabel sizeToFit];
    self.coinLabel.frame =CGRectMake(labelRect.origin.x+labelRect.size.width+5, 10, self.coinLabel.frame.size.width, self.coinLabel.frame.size.height);
    
    if (image !=nil) {
        self.coinImageView.frame =CGRectMake(self.coinLabel.frame.origin.x+self.coinLabel.frame.size.width+5, 9, 17, 17);
        self.coinImageView.image=secImage;
        
    }
    
    CGFloat barWidth = self.topImageView.frame.size.width+10+self.stringLabel.frame.size.width+25+self.coinImageView.frame.size.width+self.coinLabel.frame.size.width;
    CGFloat barHeight = MAX(36, height + 20);
    self.topBar.frame =CGRectMake(([UIScreen mainScreen].bounds.size.width-barWidth)/2, [UIScreen mainScreen].bounds.size.height - barHeight - 64, barWidth, barHeight);
    self.topBar.layer.cornerRadius = barHeight / 2.0;
    
    self.topBar.alpha =1.0;
    [self.overlayWindow setHidden:NO];
    
    [self setNeedsDisplay];
}

@end
