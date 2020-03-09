//
//  ZZQRCodeMaskView.m
//  AQTQRCode
//
//  Created by zz on 2019/10/31.
//  Copyright © 2019 zz. All rights reserved.
//

#import "ZZQRCodeMaskView.h"
#import "ZZQRCodeUtil.h"

@interface ZZQRCodeMaskView () {
    BOOL _isShown;      // 闪光灯是否显示
    NSTimer *_timer;    // 动画定时器
}
/// 扫描条
@property (nonatomic, strong) UIImageView *scanningline;
/// 闪光灯按钮
@property (nonatomic, strong, readwrite) UIButton *lightButton;

@end

@implementation ZZQRCodeMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _duration = 2.0;
        _borderColor = [UIColor whiteColor];
        _cornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
        _cornerWidth = 2.0;
        _backgroundAlpha = 0.5;
        [self scanningline];
        [self addSubview:self.lightButton];
    }
    return self;
}

/// MARK: animation
/// 开始定时器动画
- (void)startScanAnimation {
    // 添加扫描条
    if (!self.scanningline.superview) {
        [self addSubview:self.scanningline];
    }
    // 重置扫描条
    self.scanningline.alpha = 1.0f;
    self.scanningline.transform = CGAffineTransformIdentity;
    self.scanningline.frame = CGRectMake(CGRectGetMinX(_scanArea),
                                         CGRectGetMinY(_scanArea) - 6,
                                         CGRectGetWidth(_scanArea),
                                         12);
    // 设置定时器
    if (!_timer) {
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer timerWithTimeInterval:_duration repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf scanAnimate:timer];
        }];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    [_timer setFireDate:[NSDate distantPast]];
//    [self scanAnimate:nil];
}

/// 停止定时器动画
- (void)stopScanAnimation {
    [_timer invalidate];
    _timer = nil;
    // 渐隐扫描条
    [UIView animateWithDuration:0.2 animations:^{
        self.scanningline.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            // 移除扫描条
            [self.scanningline removeFromSuperview];
            self.scanningline.alpha = 1.0f;
        }
    }];
}

/// 执行一次扫描动画
- (void)scanAnimate:(NSTimer *)timer {
    // 移除可能未完成的动画
    [self.scanningline.layer removeAllAnimations];
    self.scanningline.transform = CGAffineTransformIdentity;
    self.scanningline.alpha = 0.0;
    CGFloat translation = CGRectGetHeight(self.scanArea);
    // 添加移动动画
    [UIView animateWithDuration:self.duration * 0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.scanningline.transform = CGAffineTransformTranslate(self.scanningline.transform, 0, translation / 2);
        self.scanningline.alpha = 1.0;
    } completion:nil];
    [UIView animateWithDuration:self.duration * 0.5 delay:self.duration * 0.5 options:UIViewAnimationOptionCurveLinear animations:^{
        self.scanningline.transform = CGAffineTransformTranslate(self.scanningline.transform, 0, translation / 2);
        self.scanningline.alpha = 0.0;
    } completion:nil];
}

/// MARK: light Button animation

/// 根据状态打开或关闭闪光灯
- (void)lightButtonAction:(UIButton *)button {
    if ([ZZQRCodeUtil isLightActive]) {
        [ZZQRCodeUtil closeFlashLight];
        button.selected = NO;
    } else {
        [ZZQRCodeUtil openFlashLight];
        button.selected = YES;
    }
}

- (void)showLightButton {
    if (_isShown) return;
    _isShown = YES;
    [self.lightButton.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 animations:^{
        self.lightButton.alpha = 1.0;
    }];
}

- (void)hideLightButton {
    if (!_isShown) return;
    _isShown = NO;
    [self.lightButton.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 animations:^{
        self.lightButton.alpha = 0.0;
    }];
}

/// MARK: - scan area
- (void)setScanArea:(CGRect)scanArea {
    if (CGRectEqualToRect(_scanArea, scanArea)) return;
    _scanArea = scanArea;
    // 重绘边框
    [self setNeedsDisplay];
    // 重布局控件
    [self setNeedsLayout];
    // 设置动画
    if (_timer.isValid) {
        [self stopScanAnimation];
        [self startScanAnimation];
    }
}

/// MARK: - drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (CGRectEqualToRect(_scanArea, CGRectZero)) return;
    // 设置背景颜色
    [[[UIColor blackColor] colorWithAlphaComponent:_backgroundAlpha] setFill];
    UIRectFill(rect);
    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置混合模式
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    // 设置空白区域
    UIBezierPath *blankPath = [UIBezierPath bezierPathWithRect:_scanArea];
    [blankPath fill];
    // 执行混合模式
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // 设置边框
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:_scanArea];
    borderPath.lineCapStyle = kCGLineCapButt;
    borderPath.lineWidth = 0.2;
    [_borderColor set];
    [borderPath stroke];
    
    // 边角框宽度
    CGFloat cornerWidth = 2.0;
    // 边角框长度
    CGFloat cornerLength = 20;
    
    //（按顺时针方向绘制）
    // 左上边角框
    UIBezierPath *leftTopPath = [UIBezierPath bezierPath];
    leftTopPath.lineWidth = cornerWidth;
    [_cornerColor set];
    [leftTopPath moveToPoint:CGPointMake(CGRectGetMinX(_scanArea),
                                         CGRectGetMinY(_scanArea) + cornerLength)];
    [leftTopPath addLineToPoint:CGPointMake(CGRectGetMinX(_scanArea),
                                            CGRectGetMinY(_scanArea))];
    [leftTopPath addLineToPoint:CGPointMake(CGRectGetMinX(_scanArea) + cornerLength,
                                            CGRectGetMinY(_scanArea))];
    [leftTopPath stroke];
    
    // 右上边角框
    UIBezierPath *rightTopPath = [UIBezierPath bezierPath];
    rightTopPath.lineWidth = cornerWidth;
    [_cornerColor set];
    [rightTopPath moveToPoint:CGPointMake(CGRectGetMaxX(_scanArea) - cornerLength,
                                          CGRectGetMinY(_scanArea))];
    [rightTopPath addLineToPoint:CGPointMake(CGRectGetMaxX(_scanArea),
                                             CGRectGetMinY(_scanArea))];
    [rightTopPath addLineToPoint:CGPointMake(CGRectGetMaxX(_scanArea),
                                             CGRectGetMinY(_scanArea) + cornerLength)];
    [rightTopPath stroke];
    
    // 右下边角框
    UIBezierPath *rightBottomPath = [UIBezierPath bezierPath];
    rightBottomPath.lineWidth = cornerWidth;
    [_cornerColor set];
    [rightBottomPath moveToPoint:CGPointMake(CGRectGetMaxX(_scanArea),
                                             CGRectGetMaxY(_scanArea) - cornerLength)];
    [rightBottomPath addLineToPoint:CGPointMake(CGRectGetMaxX(_scanArea),
                                                CGRectGetMaxY(_scanArea))];
    [rightBottomPath addLineToPoint:CGPointMake(CGRectGetMaxX(_scanArea) - cornerLength,
                                                CGRectGetMaxY(_scanArea))];
    [rightBottomPath stroke];
    
    // 左下边角框
    UIBezierPath *leftbottomPath = [UIBezierPath bezierPath];
    leftbottomPath.lineWidth = cornerWidth;
    [_cornerColor set];
    [leftbottomPath moveToPoint:CGPointMake(CGRectGetMinX(_scanArea) + cornerLength,
                                            CGRectGetMaxY(_scanArea))];
    [leftbottomPath addLineToPoint:CGPointMake(CGRectGetMinX(_scanArea),
                                               CGRectGetMaxY(_scanArea))];
    [leftbottomPath addLineToPoint:CGPointMake(CGRectGetMinX(_scanArea),
                                               CGRectGetMaxY(_scanArea) - cornerLength)];
    [leftbottomPath stroke];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 闪光灯按钮布局
    self.lightButton.frame = CGRectMake(CGRectGetMidX(self.scanArea) - 88 / 2,
                                        CGRectGetMaxY(self.scanArea) - 66, 88, 66);
    // 设置按钮图片在上，文字在下，间距为 margin
    // 图片 向右移动的距离是标题宽度的一半,向上移动的距离是图片高度的一半
    CGFloat margin = 10;
    self.lightButton.imageEdgeInsets = UIEdgeInsetsMake(-(margin + CGRectGetHeight(_lightButton.titleLabel.bounds)) / 2,
                                                        CGRectGetWidth(_lightButton.titleLabel.bounds) / 2,
                                                        (margin + CGRectGetHeight(_lightButton.titleLabel.bounds)) / 2,
                                                        -CGRectGetWidth(_lightButton.titleLabel.bounds) / 2);
    // 标题 向左移动的距离是图片宽度的一半,向下移动的距离是标题高度的一半
    self.lightButton.titleEdgeInsets = UIEdgeInsetsMake((margin + CGRectGetHeight(_lightButton.imageView.bounds)) / 2,
                                                        -CGRectGetWidth(_lightButton.imageView.bounds) / 2,
                                                        -(margin + CGRectGetHeight(_lightButton.imageView.bounds)) / 2,
                                                        CGRectGetWidth(_lightButton.imageView.bounds) / 2);
}

/// MARK: getter / settet

- (UIImageView *)scanningline {
    if (!_scanningline) {
        UIImage *image = [UIImage imageNamed:@"QRCodeScanLine" inBundle:[ZZQRCodeUtil bundle] compatibleWithTraitCollection:nil];
        if (!image) {
            image = [UIImage imageNamed:@"QRCodeScanLine"];
        }
        _scanningline = [[UIImageView alloc] init];
        _scanningline.image = image;
    }
    return _scanningline;
}

- (UIButton *)lightButton {
    if (!_lightButton) {
        UIImage *imageOff = [UIImage imageNamed:@"flashlight_off" inBundle:[ZZQRCodeUtil bundle] compatibleWithTraitCollection:nil];
        UIImage *imageOn = [UIImage imageNamed:@"flashlight_open" inBundle:[ZZQRCodeUtil bundle] compatibleWithTraitCollection:nil];
        _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _lightButton.alpha = 0.0;
        _lightButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        _lightButton.imageView.contentMode = UIViewContentModeCenter;
        [_lightButton setTintColor:UIColor.whiteColor];
        [_lightButton setImage:imageOff forState:UIControlStateNormal];
        [_lightButton setImage:imageOn forState:UIControlStateSelected];
        [_lightButton setTitle:@"轻触照亮" forState:UIControlStateNormal];
        [_lightButton setTitle:@"轻触关闭" forState:UIControlStateSelected];
        [_lightButton addTarget:self action:@selector(lightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightButton;
}

- (void)setDuration:(NSTimeInterval)duration {
    if (_duration != duration) {
        _duration = duration;
        [self stopScanAnimation];
        [self startScanAnimation];
    }
}
- (void)setBorderColor:(UIColor *)borderColor {
    if (_borderColor != borderColor) {
        _borderColor = borderColor;
        [self setNeedsDisplay];
    }
}

- (void)setCornerColor:(UIColor *)cornerColor {
    if (_cornerColor != cornerColor) {
        _cornerColor = cornerColor;
        [self setNeedsDisplay];
    }
}

- (void)setCornerWidth:(CGFloat)cornerWidth {
    if (_cornerWidth != cornerWidth) {
        _cornerWidth = cornerWidth;
        [self setNeedsDisplay];
    }
}

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha {
    if (_backgroundAlpha != backgroundAlpha) {
        _backgroundAlpha = backgroundAlpha;
        [self setNeedsDisplay];
    }
}

@end
