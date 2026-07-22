//
//  ShareFamilyViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/5/6.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "ShareFamilyViewController.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>

@interface ShareFamilyViewController ()

@property (nonatomic, strong) UIImageView *qCodeImageView;
@property (nonatomic, strong) UILabel *qCodeLabel;

@end

@implementation ShareFamilyViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Share Family";
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self buildUI];
    [self getFamilyMemberInviteQrcode];
}

- (void)buildUI {
    [BLTheme hideStoryboardSubviewsIn:self.view];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    [scrollView addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Invite Members";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [content addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Share this QR code or invite text with family members";
    subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    subtitleLabel.numberOfLines = 0;
    [content addSubview:subtitleLabel];

    UIView *card = [[UIView alloc] init];
    [BLTheme styleCardView:card];
    [content addSubview:card];

    self.qCodeImageView = [[UIImageView alloc] init];
    self.qCodeImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.qCodeImageView.backgroundColor = [UIColor whiteColor];
    self.qCodeImageView.layer.cornerRadius = 8;
    self.qCodeImageView.clipsToBounds = YES;
    [card addSubview:self.qCodeImageView];

    self.qCodeLabel = [[UILabel alloc] init];
    self.qCodeLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightMedium];
    self.qCodeLabel.textColor = [BLTheme titleColor];
    self.qCodeLabel.textAlignment = NSTextAlignmentCenter;
    self.qCodeLabel.numberOfLines = 0;
    self.qCodeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [card addSubview:self.qCodeLabel];

    UIButton *refreshButton = [BLTheme makePrimaryButtonWithTitle:@"Refresh"
                                                           target:self
                                                           action:@selector(refresh:)];
    [card addSubview:refreshButton];

    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(16);
        make.left.equalTo(content).offset(20);
        make.right.equalTo(content).offset(-20);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.left.right.equalTo(titleLabel);
    }];
    [card mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(24);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
    }];
    [self.qCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card).offset(24);
        make.centerX.equalTo(card);
        make.width.height.mas_equalTo(240);
    }];
    [self.qCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qCodeImageView.mas_bottom).offset(16);
        make.left.equalTo(card).offset(16);
        make.right.equalTo(card).offset(-16);
    }];
    [refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qCodeLabel.mas_bottom).offset(20);
        make.left.equalTo(card).offset(16);
        make.right.equalTo(card).offset(-16);
        make.bottom.equalTo(card).offset(-20);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(card).offset(28);
    }];
}

- (void)getFamilyMemberInviteQrcode {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    [manager getFamilyInvitedQrcodeWithCompletionHandler:^(BLSInvitedQrcodeResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });

        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self QRCodeMethod:result.qrcode];
                self.qCodeLabel.text = result.qrcode;
            });
        }
    }];
}

- (void)refresh:(id)sender {
    [self getFamilyMemberInviteQrcode];
}

#pragma mark - 生成二维码的方法

- (void)QRCodeMethod:(NSString *)qrCodeString {
    UIImage *qrcodeImg = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:qrCodeString] withSize:240.0f];
    self.qCodeImageView.image = qrcodeImg;
}

#pragma mark - InterpolatedUIImage

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size / CGRectGetWidth(extent), size / CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);

    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - QRCodeGenerator

- (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];

    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];

    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];

    return qrFilter.outputImage;
}

#pragma mark - imageToTransparent

void ProviderReleaseData(void *info, const void *data, size_t size) {
    free((void *)data);
}

- (UIImage *)imageBlackToTransparent:(UIImage *)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue {
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);

    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[3] = red;
            ptr[2] = green;
            ptr[1] = blue;
        } else {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[0] = 0;
        }
    }

    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];

    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

@end
