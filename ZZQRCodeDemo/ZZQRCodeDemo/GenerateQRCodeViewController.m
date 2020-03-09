//
//  GenerateQRCodeViewController.m
//  ZZQRCodeDemo
//
//  Created by ZZ on 2019/12/15
//  Copyright © 2019 zz. All rights reserved.
//

#import "GenerateQRCodeViewController.h"
#import "ZZQRCodeUtil.h"

@interface GenerateQRCodeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIImage *_logoImage;
    UIImage *_qrcodeImage;
}

@property (nonatomic, strong) UIImageView *qrcodeImageView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *removeLogoButton;
@property (nonatomic, strong) UIButton *generateButton;

@end

@implementation GenerateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(showPhotoPicker)];
    CGFloat left = (kScreenWidth - 300) / 2;
    CGFloat width = 300;
    CGFloat margin = 24;
    
    _logoImage = [UIImage imageNamed:@"233.jpg"];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(left, 80, width, 60)];
    _textView.text = @"Hello world!";
    _textView.font = [UIFont systemFontOfSize:18];
    _textView.backgroundColor = UIColor.lightGrayColor;
    [self.view addSubview:_textView];
    
    _qrcodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, CGRectGetMaxY(_textView.frame) + margin, 300, 300)];
    _qrcodeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_qrcodeImageView];
    
    _removeLogoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _removeLogoButton.frame = CGRectMake(left, CGRectGetMaxY(_qrcodeImageView.frame) + margin, width, 45);
    [_removeLogoButton setTitle:@"移除logo" forState:UIControlStateNormal];
    [_removeLogoButton addTarget:self action:@selector(removeLogoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_removeLogoButton];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _saveButton.frame = CGRectMake(left, CGRectGetMaxY(_removeLogoButton.frame) + margin, width, 45);
    [_saveButton setTitle:@"保存二维码" forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
    
    _generateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _generateButton.frame = CGRectMake(left, CGRectGetMaxY(_saveButton.frame) + margin, width, 45);
    [_generateButton setTitle:@"生成二维码" forState:UIControlStateNormal];
    [_generateButton addTarget:self action:@selector(generateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_generateButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self generateButtonAction];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)removeLogoButtonAction {
    _logoImage = nil;
    [self generateButtonAction];
}

- (void)generateButtonAction {
    NSString *text = _textView.text;
    UIImage *logo = _logoImage;
    UIImage *newImage;
    if (logo) {
        newImage = [ZZQRCodeUtil generateLogoQRCodeImageWithString:text size:_qrcodeImageView.bounds.size.width foregroundColor:UIColor.blackColor backgroundColor:UIColor.whiteColor logo:logo ratio:0.3 radius:5 borderWidth:3 borderColor:UIColor.whiteColor];
    } else {
        newImage = [ZZQRCodeUtil generateQRCodeImageWithString:text size:_qrcodeImageView.bounds.size.width];
    }
    _qrcodeImageView.image = newImage;
}

- (void)saveButtonAction {
    if (!_qrcodeImageView.image) return;
    UIImage *newImage = _qrcodeImageView.image;
    UIGraphicsBeginImageContext(newImage.size);
    //  绘制二维码图片
    [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
    //  从图片上下文中取出图片
    newImage  = UIGraphicsGetImageFromCurrentImageContext();
    //  关闭图片上下文
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
    } else {
        msg = @"保存图片成功" ;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:firstAction];
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
    _logoImage = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self generateButtonAction];
    }];
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
