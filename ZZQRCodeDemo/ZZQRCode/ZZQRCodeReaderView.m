//
//  ZZQRCodeReaderView.m
//  AQTQRCode
//
//  Created by zz on 2019/10/30.
//  Copyright © 2019 杭州电梯安全通. All rights reserved.
//

#import "ZZQRCodeReaderView.h"
#import "ZZQRCodeUtil.h"
#import "ZZQRCodeReader.h"
#import "ZZQRCodeMaskView.h"

@interface ZZQRCodeReaderView () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    NSArray<AVMetadataObjectType> *_metadataObjectTypes;
}

@property (nonatomic, assign) BOOL isScanning;              // 状态
@property (nonatomic, strong) ZZQRCodeReader *reader;       // 扫描管理
@property (nonatomic, strong) ZZQRCodeMaskView *maskView;   // 显示视图
@property (nonatomic, copy) void (^handler)(NSString *string, ZZQRCodeReaderView *readerView); // 扫描成功的回调
@property (nonatomic, copy) void (^brightnessHandler)(CGFloat brightness, ZZQRCodeReaderView *readerView); // 亮度变化的回调

@end

@implementation ZZQRCodeReaderView

/// MARK: life cycle

- (void)dealloc {
    [_reader stopScan];
    [_maskView stopScanAnimation];
    [ZZQRCodeUtil closeFlashLight];
}

+ (instancetype)QRCodeReaderViewWithFrame:(CGRect)frame {
    ZZQRCodeReaderView *instance = [[[self class] alloc] initWithFrame:frame scanArea:CGRectZero scanTypes:@[AVMetadataObjectTypeQRCode] handler:nil];
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame scanArea:(CGRect)area scanTypes:(nullable NSArray<AVMetadataObjectType> *)types handler:(nullable void (^)(NSString * _Nullable string, ZZQRCodeReaderView * _Nonnull readerView))handler {
    if (self = [super initWithFrame:frame]) {
        _scanArea = area;
        _metadataObjectTypes = types;
        self.handler = handler;
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    self.backgroundColor = [UIColor blackColor];
    [self.layer insertSublayer:self.reader.previewLayer atIndex:0];
    [self addSubview:self.maskView];
    if (CGRectEqualToRect(_scanArea, CGRectZero)) {
        CGFloat width = ceilf(MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) * 0.7);
        CGFloat left = ceilf((CGRectGetWidth(self.bounds) - width) / 2);
        CGFloat top = ceilf((CGRectGetHeight(self.bounds) - width) / 2);
        [self setScanArea:CGRectMake(left, top, width, width)];
    }
    // 双击缩放
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    // 捏合缩放
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:pinch];
    
}

/// 双击缩放
- (void)doubleTapAction:(UITapGestureRecognizer *)gesture {
    [self.reader changeVideoZoomFactor];
}

/// 捏合缩放
- (void)pinchAction:(UIPinchGestureRecognizer *)gesture {
    static CGFloat beginFactory;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        beginFactory = self.reader.videoZoomFactor;
    }
    CGFloat factor = gesture.scale * beginFactory;
    NSLog(@"gesture.scale : %f, beginFactory: beginFactory: %f, factor: %f", gesture.scale, beginFactory, factor);
    [self.reader setVideoZoomFactor:factor];
}


/// MARK: scan
/// 开始扫描
- (void)startScan {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.maskView startScanAnimation];
        [self.reader startScan];
        self.isScanning = YES;
    });
}

/// 停止扫描
- (void)stopScan {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.maskView stopScanAnimation];
        [self.reader stopScan];
        self.isScanning = NO;
    });
}

/// MARK: - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    // 图层大小和视图一致
    self.reader.previewLayer.frame = self.bounds;
    self.maskView.frame = self.bounds;
}

/// 修改了扫描区域，重新进行布局
- (void)setScanArea:(CGRect)scanArea {
    if (CGRectEqualToRect(_scanArea, scanArea)) {
        return;
    }
    _scanArea = scanArea;
    self.reader.scanArea = scanArea;
    self.maskView.scanArea = scanArea;
}

/// MARK: - <AVCaptureMetadataOutputObjectsDelegate>
/// MARK: 扫码成功的回调
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataObject *metedataObject in metadataObjects) {
        if ([metedataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
            && [self.reader.metadataObjectTypes containsObject:metedataObject.type]) {
            // 播放声音
            [[self class] playSoundName:@"qrcode_scan_sound.wav"];
            // 返回结果
            NSString *string = [(AVMetadataMachineReadableCodeObject *)metedataObject stringValue];
            if (_handler) {
                __weak typeof(self) weakSelf = self;
                _handler(string, weakSelf);
            }
            return;
        }
    }
}

/// 播放声音
/// @param name 声音文件名称，需包含格式名
+ (void)playSoundName:(NSString *)name {
    /// 静态库 path 的获取
    NSString *path = [[ZZQRCodeUtil bundle] pathForResource:name ofType:nil];
    if (!path) return;
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundID);
}

static void soundCompleteCallback(SystemSoundID soundID, void *clientData) {}

/// MARK: - <AVCaptureVideoDataOutputSampleBufferDelegate>
/// MARK: 亮度变化
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // 闪光灯已打开，不隐藏按钮
    if (self.maskView.lightButton.selected) {
        return;
    }
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSDictionary alloc] initWithDictionary:(__bridge NSDictionary *)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifDictionary = [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    float brightness = [[exifDictionary objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    if (brightness > 0) {
        // 光线明亮，隐藏按钮
        [self.maskView hideLightButton];
    } else {
        // 光线昏暗，显示按钮
        [self.maskView showLightButton];
    }
    // 执行回调
    if (_brightnessHandler) {
        __weak typeof(self) weakSelf = self;
        _brightnessHandler(brightness, weakSelf);
    }
}

/// MARK: - getter / setter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[ZZQRCodeMaskView alloc] init];
    }
    return _maskView;
}

- (ZZQRCodeReader *)reader {
    if (!_reader) {
        _reader = [ZZQRCodeReader readerWithMetadataObjectTypes:_metadataObjectTypes delegate:self];
    }
    return _reader;
}

- (BOOL)isScanning {
    if ([NSThread isMainThread]) {
        return _isScanning;
    } else {
        __block BOOL isScanning;
        dispatch_sync(dispatch_get_main_queue(), ^{
            isScanning = _isScanning;
        });
        return isScanning;
    }
}

@end
