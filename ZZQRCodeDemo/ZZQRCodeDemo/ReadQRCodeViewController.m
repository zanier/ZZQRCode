//
//  ReadQRCodeViewController.m
//  ZZQRCodeDemo
//
//  Created by ZZ on 2019/12/15
//  Copyright © 2019 zz. All rights reserved.
//

#import "ReadQRCodeViewController.h"
#import "ZZQRCodeUtil.h"

@interface ReadQRCodeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView *qrcodeImageView;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation ReadQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(showPhotoPicker)];
    CGFloat left = (kScreenWidth - 300) / 2;
    CGFloat width = 300;
    CGFloat margin = 24;
    _qrcodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, 80, 300, 300)];
    _qrcodeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_qrcodeImageView];
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(left, CGRectGetMaxY(_qrcodeImageView.frame) + margin, width, 60)];
    _textView.text = @"请从相册中选择二维码图片";
    _textView.font = [UIFont systemFontOfSize:18];
    _textView.userInteractionEnabled = NO;
    [self.view addSubview:_textView];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if (error) {
        msg = @"保存图片失败" ;
    } else {
        msg = @"保存图片成功" ;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
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
}

/// 相册点击取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/// 相册选择了图片，识别二维码
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _qrcodeImageView.image = image;
    NSArray *features = [ZZQRCodeUtil detectQRCodeWithImage:image];
    _textView.text = features.firstObject;
    [picker dismissViewControllerAnimated:YES completion:nil];
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
