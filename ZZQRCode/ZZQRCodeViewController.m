//
//  ZZQRCodeViewController.m
//  AQTQRCode
//
//  Created by zz on 2019/11/1.
//  Copyright © 2019 zz. All rights reserved.
//

#import "ZZQRCodeViewController.h"
#import "ZZQRCodeReaderView.h"
#import "ZZQRCodeUtil.h"

@interface ZZQRCodeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIImage *_naviBackImage;
    UIImage *_naviShadowImage;
    UIColor *_naviTintColor;
    NSDictionary *_titleAttributes;
}

@property (nonatomic, copy) NSString *text; /// 中间显示文字
@property (nonatomic, strong) ZZQRCodeReaderView *readerView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *btnContentView;

@end

@implementation ZZQRCodeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(showPhotoPicker)];
    [self.view addSubview:self.readerView];
    [self.view addSubview:self.btnContentView];
    [self.view addSubview:self.textLabel];
    self.text = @"将二维码/条形码放入框内，即可自动扫描";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidStartRunning) name:AVCaptureSessionDidStartRunningNotification object:nil];
}

- (void)startScan {
    // 获取相册访问权限
    if (![ZZQRCodeUtil isAVAuthorized]) {
        [ZZQRCodeUtil requestAVAuthorization:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startScan];
                });
            } else {
                [self showAlertWithTitle:@"相机权限未开启" message:@"检测到相机权限未开启，是否到设置中去打开？"];
            }
        }];
        return;
    }
    [self.readerView startScan];
}

- (void)showPhotoPicker {
    // 获取相册访问权限
    if (![ZZQRCodeUtil isPHAuthorized]) {
        [ZZQRCodeUtil requestPHAuthorization:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showPhotoPicker];
                });
            } else {
                [self showAlertWithTitle:@"相册权限未开启" message:@"检测到相册权限未开启，是否到设置中去打开？"];
            }
        }];
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    [self.readerView stopScan];
}

/// 相册点击取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        /// 设置导航栏为透明
        [self setNavigationBarTransparent];
        [self.readerView startScan];
    }];
}

/// 相册选择了图片，识别二维码
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSArray *features = [ZZQRCodeUtil detectQRCodeWithImage:image];
    [picker dismissViewControllerAnimated:YES completion:^{
        /// 设置导航栏为透明
        [self setNavigationBarTransparent];
        [self readerView:self.readerView didReadCode:features.firstObject];
    }];

}

- (void)sessionDidStartRunning {
    
}

- (void)readerView:(ZZQRCodeReaderView *)readerView didReadCode:(NSString *)string {
    [readerView stopScan];
    if (_didReadQRCode) {
        _didReadQRCode(string, ^() {
            [readerView startScan];
        });
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:string message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:^{
                [self.readerView startScan];
            }];
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /// 保存导航栏设置
    _naviTintColor = self.navigationController.navigationBar.tintColor;
    _naviBackImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    _naviShadowImage = self.navigationController.navigationBar.shadowImage;
    _titleAttributes = self.navigationController.navigationBar.titleTextAttributes;
    /// 设置导航栏为透明
    [self setNavigationBarTransparent];
    [self startScan];
}

/// 设置导航栏为透明
- (void)setNavigationBarTransparent {
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    /// 恢复导航栏设置
    [self.navigationController.navigationBar setBackgroundImage:_naviBackImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = _naviShadowImage;
    self.navigationController.navigationBar.tintColor = _naviTintColor;
    self.navigationController.navigationBar.titleTextAttributes = _titleAttributes;
    [self.readerView stopScan];
}

/// 不支持屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

/// 设置白色状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.readerView.frame = self.view.bounds;
    self.btnContentView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 88, CGRectGetWidth(self.view.bounds), 88);
}

- (ZZQRCodeReaderView *)readerView {
    if (!_readerView) {
        _readerView = [ZZQRCodeReaderView QRCodeReaderViewWithFrame:self.view.bounds];
        __weak typeof(self) weakSelf = self;
        [_readerView setHandler:^(NSString * _Nullable string, ZZQRCodeReaderView * _Nonnull readerView) {
            [weakSelf readerView:readerView didReadCode:string];
        }];
    }
    return _readerView;
}

- (UIView *)btnContentView {
    if (!_btnContentView) {
        _btnContentView = [[UIView alloc] init];
        _btnContentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _btnContentView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:13.0];
        _textLabel.textColor = UIColor.whiteColor;
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.frame = CGRectMake(CGRectGetMinX(self.readerView.scanArea),
                                      CGRectGetMaxY(self.readerView.scanArea) + 10,
                                      CGRectGetWidth(self.readerView.scanArea),
                                      42);
    }
    return _textLabel;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    self.textLabel.text = _text;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:firstAction];
        UIAlertAction *secendAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:secendAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end
