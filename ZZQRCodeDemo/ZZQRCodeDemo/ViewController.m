//
//  ViewController.m
//  ZZQRCodeDemo
//
//  Created by ZZ on 2019/12/15
//  Copyright © 2019 zz. All rights reserved.
//

#import "ViewController.h"
#import "ZZQRCodeViewController.h"
#import "GenerateQRCodeViewController.h"
#import "ReadQRCodeViewController.h"

#define nameKey @"dataSourceNameKey"
#define classKey @"dataSourceClsKey"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *nameArray;
@property (nonatomic, strong) NSArray *clsArray;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZZQRCode";
    _dataSource = @[
        @{nameKey : @"扫描二维码", classKey : ZZQRCodeViewController.class},
        @{nameKey : @"识别二维码", classKey : ReadQRCodeViewController.class},
        @{nameKey : @"生成二维码", classKey : GenerateQRCodeViewController.class},
    ];
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _dataSource[indexPath.row][nameKey];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class cls = _dataSource[indexPath.row][classKey];
    UIViewController *viewController = [[cls alloc] init];
    viewController.title = _dataSource[indexPath.row][nameKey];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
