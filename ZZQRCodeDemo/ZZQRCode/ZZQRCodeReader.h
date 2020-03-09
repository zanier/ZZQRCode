//
//  ZZQRCodeReader.h
//  AQTQRCode
//
//  Created by zz on 2019/10/30.
//  Copyright © 2019 杭州电梯安全通. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZQRCodeReader : NSObject

/// 初始化方法
+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes delegate:(id<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

@property (nonatomic, assign) CGRect scanArea;
/// 当前的识别格式
//@property (readonly) NSArray<AVMetadataObjectType> *metadataObjectTypes;
@property (nonatomic, strong) NSArray<AVMetadataObjectType> *metadataObjectTypes;

@property (readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, weak) id<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> delegate;

/// 扫描状态
@property (readonly) BOOL isScanning;

@property (readonly) CGFloat videoZoomFactor;

- (void)setVideoZoomFactor:(CGFloat)factor;

- (void)changeVideoZoomFactor;

/// 开始扫描
- (void)startScan;

/// 停止扫描
- (void)stopScan;

///// 设置扫描成功的回调
//- (void)setScanHandler:(void (^)(NSString * __nullable))handler;

@end

NS_ASSUME_NONNULL_END
