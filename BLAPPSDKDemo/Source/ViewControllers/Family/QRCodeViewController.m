//
//  QRCodeViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/5/7.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "QRCodeViewController.h"
#import "JoinFamilyViewController.h"
#import "BLTheme.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>

@interface QRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIView *viewPreview;
@property (nonatomic, strong) UIView *boxView;
@property (nonatomic, strong) CALayer *scanLayer;
@property (nonatomic, copy) NSString *qCode;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) NSTimer *scanTimer;
@property (nonatomic, assign) BOOL didStartReading;

@end

@implementation QRCodeViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scan QR Code";
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self buildUI];
}

- (void)buildUI {
    self.viewPreview = [[UIView alloc] init];
    self.viewPreview.backgroundColor = [UIColor blackColor];
    self.viewPreview.clipsToBounds = YES;
    [self.view addSubview:self.viewPreview];

    [self.viewPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.videoPreviewLayer) {
        self.videoPreviewLayer.frame = self.viewPreview.layer.bounds;
        [self updateScanBoxFrame];
    }

    if (!self.didStartReading && self.viewPreview.bounds.size.width > 0 && self.viewPreview.bounds.size.height > 0) {
        self.didStartReading = YES;
        [self startReading];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [self stopReading];
    }
}

- (void)dealloc {
    [self.scanTimer invalidate];
    self.scanTimer = nil;
}

- (void)updateScanBoxFrame {
    if (!self.boxView) { return; }
    CGRect bounds = self.viewPreview.bounds;
    CGFloat insetX = bounds.size.width * 0.2f;
    CGFloat insetY = bounds.size.height * 0.2f;
    self.boxView.frame = CGRectMake(insetX, insetY, bounds.size.width - insetX * 2, bounds.size.height - insetY * 2);
    self.scanLayer.frame = CGRectMake(0, 0, self.boxView.bounds.size.width, 2);
}

- (BOOL)startReading {
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }

    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    [self.captureSession addOutput:captureMetadataOutput];

    dispatch_queue_t dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];

    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPreviewLayer.frame = self.viewPreview.layer.bounds;
    [self.viewPreview.layer addSublayer:self.videoPreviewLayer];

    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);

    self.boxView = [[UIView alloc] initWithFrame:CGRectZero];
    self.boxView.layer.borderColor = [BLTheme primaryColor].CGColor;
    self.boxView.layer.borderWidth = 2.0f;
    self.boxView.backgroundColor = [UIColor clearColor];
    [self.viewPreview addSubview:self.boxView];

    self.scanLayer = [[CALayer alloc] init];
    self.scanLayer.backgroundColor = [BLTheme primaryColor].CGColor;
    [self.boxView.layer addSublayer:self.scanLayer];
    [self updateScanBoxFrame];

    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                      target:self
                                                    selector:@selector(moveScanLayer:)
                                                    userInfo:nil
                                                     repeats:YES];
    [self.scanTimer fire];

    [self.captureSession startRunning];
    return YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects.firstObject;
        if ([metadataObj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *qcode = metadataObj.stringValue;
            self.qCode = qcode;
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                JoinFamilyViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
                vc.qCode = self.qCode;
                [self.navigationController popToViewController:vc animated:YES];
            });
        }
    }
}

- (void)moveScanLayer:(NSTimer *)timer {
    if (!self.scanLayer || !self.boxView) { return; }
    CGRect frame = self.scanLayer.frame;
    if (self.boxView.frame.size.height < self.scanLayer.frame.origin.y + 2) {
        frame.origin.y = 0;
        self.scanLayer.frame = frame;
    } else {
        frame.origin.y += 5;
        [UIView animateWithDuration:0.1 animations:^{
            self.scanLayer.frame = frame;
        }];
    }
}

- (void)stopReading {
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    [self.captureSession stopRunning];
    self.captureSession = nil;
}

@end
