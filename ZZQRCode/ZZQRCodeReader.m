//
//  ZZQRCodeReader.m
//  AQTQRCode
//
//  Created by zz on 2019/10/30.
//  Copyright © 2019 zz. All rights reserved.
//

#import "ZZQRCodeReader.h"
#import "ZZQRCodeUtil.h"

@interface ZZQRCodeReader () {
    BOOL _didSetup;
}

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer; // 预览图层

@end

@implementation ZZQRCodeReader

/// MARK: - init
+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes delegate:(id<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>)delegate {
    return [[self alloc] initWithMetadataObjectTypes:metadataObjectTypes delegate:delegate];
}

- (instancetype)initWithMetadataObjectTypes:(NSArray<AVMetadataObjectType> *)metadataObjectTypes delegate:(id<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>)delegate {
    if (self = [super init]) {
        _metadataObjectTypes = metadataObjectTypes;
        _delegate = delegate;
        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (_didSetup) return;
    if (!_metadataObjectTypes || _metadataObjectTypes.count == 0) {
        _metadataObjectTypes = [ZZQRCodeUtil defaultMetadataObjectTypes];
    }
    if ([ZZQRCodeUtil isAVAuthorized] && [ZZQRCodeUtil isAvailable]) {
        [self setupAVComponents];
        [self configDefaultAVComponents];
        _didSetup = YES;
    }
}

/// 初始化对象
- (void)setupAVComponents {
    // 1. 获取摄像设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2. 创建输出流
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    // 3. 创建元数据输出流
    _output = [[AVCaptureMetadataOutput alloc] init];
    // 4. 创建摄像数据输出流，用于识别光线强弱
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 5. 初始会话
    _session = [[AVCaptureSession alloc] init];
    // 6. 创建预览图层
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
}

- (CGFloat)videoZoomFactor {
    return _device.videoZoomFactor;
}

- (void)setVideoZoomFactor:(CGFloat)factor {
    if (factor < 1 || factor > _device.maxAvailableVideoZoomFactor) return;
    AVCaptureDeviceLock;
    _device.videoZoomFactor = factor;
    AVCaptureDeviceUnLock;
}

- (void)changeVideoZoomFactor {
    AVCaptureDeviceLock;
    if (_device.videoZoomFactor == 1) {
        [_device rampToVideoZoomFactor:MIN(_device.maxAvailableVideoZoomFactor, 4) withRate:8];
    } else {
        [_device rampToVideoZoomFactor:1 withRate:8];
    }
    AVCaptureDeviceUnLock;
}

- (void)scale {
    static BOOL didZoom = YES;
    AVCaptureDeviceLock;
    if (didZoom) {
        [_device rampToVideoZoomFactor:MIN(_device.maxAvailableVideoZoomFactor, 4) withRate:8];
    } else {
        [_device rampToVideoZoomFactor:1 withRate:4];
    }
    didZoom = !didZoom;
    AVCaptureDeviceUnLock;
}

/// 对象设置
- (void)configDefaultAVComponents {
    // 添加输入输出流到会话
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    if ([_session canAddOutput:_videoDataOutput]) {
        [_session addOutput:_videoDataOutput];
    }
    // 设置输出代理，在主线程中回调
    [_output setMetadataObjectsDelegate:_delegate queue:dispatch_get_main_queue()];
    [_videoDataOutput setSampleBufferDelegate:_delegate queue:dispatch_get_main_queue()];
    // 设置识别格式（添加到会话后才能设置）
    _output.metadataObjectTypes = _metadataObjectTypes;
    // 设置高质量采集率
    _session.sessionPreset = AVCaptureSessionPreset1920x1080;
    // 设置视频填充模式
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void)setMetadataObjectTypes:(NSArray<AVMetadataObjectType> *)metadataObjectTypes {
    if (_metadataObjectTypes != metadataObjectTypes) {
        _metadataObjectTypes = metadataObjectTypes;
        _output.metadataObjectTypes = metadataObjectTypes;
    }
}

/// MARK: - 扫描
/// 扫描状态
- (BOOL)isScanning {
    return _session.isRunning;
}

/// 开始扫描
- (void)startScan {
    [self setup];
    if ([ZZQRCodeUtil isAVAuthorized] && [ZZQRCodeUtil isAvailable]) {
        if (![_session isRunning]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self.session startRunning];
            });
        }
    }
}

/// 停止扫描
- (void)stopScan {
    if ([_session isRunning]) {
        [_session stopRunning];
    }
}

/// MARK: - getter / setter
/// 设置扫描区域
/// @param scanArea 扫描区域
- (void)setScanArea:(CGRect)scanArea {
    if (CGRectEqualToRect(_scanArea, scanArea)) {
        return;
    }
    _scanArea = scanArea;
    [self.output setRectOfInterest:[ZZQRCodeUtil outputRectOfInterestWithArea:_scanArea]];
}

@end
