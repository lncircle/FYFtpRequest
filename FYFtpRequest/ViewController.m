//
//  ViewController.m
//  FYFtpRequest
//
//  Created by mxc235 on 2018/3/18.
//  Copyright © 2018年 FY. All rights reserved.
//

#import "ViewController.h"
#import "FYFtpRequest.h"
#import "SVProgressHUD.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, strong) FYFtpRequest *ftpRequest;

@end

#warning 这里填写ftp登录的信息

static NSString * const FTP_ADDRESS = @"211.150.90.250";
static UInt16     const FTP_Port = 6028;
static NSString * const USERNAME = @"admin@115871";
static NSString * const PASSWORD = @"admin@115871";

@implementation ViewController

- (FYFtpRequest *)ftpRequest
{
    if (!_ftpRequest) {
        _ftpRequest = [[FYFtpRequest alloc] initFTPClientWithUserName:USERNAME userPassword:PASSWORD serverIp:FTP_ADDRESS serverHost:FTP_Port];
    }
    return _ftpRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = @[@"查看文件信息、获取列表",@"创建文件夹",@"上传文件",@"下载文件"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

// 获取列表，需要路径参数，为空 获取根目录
- (void)showList
{
    [self.ftpRequest showResourceListRemoteRelativePath:@"" sucess:^(__unsafe_unretained Class resultClass, id result) {
        
        NSLog(@"%@",result);
        NSMutableArray *arr = [NSMutableArray array];
        NSInteger index = 0;
        for (NSDictionary *dict in result) {
            if (index > 3) {
                break;
            }
            [arr addObject:[[dict allValues] firstObject]];
            index ++;
        }
        
        NSString *str = [arr componentsJoinedByString:@"\n\n"];
        [SVProgressHUD showSuccessWithStatus:str];
        
    } fail:^(NSString *errorDescription) {
        [SVProgressHUD showErrorWithStatus:errorDescription];
    }];
}

// 创建文件夹，需要创建目录路径参数
- (void)createFolder
{
    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [self.ftpRequest createResourceToRemoteRelativeFolder:uuid sucess:^(__unsafe_unretained Class resultClass, id result) {
        [SVProgressHUD showSuccessWithStatus:result];
    } fail:^(NSString *errorDescription) {
        [SVProgressHUD showErrorWithStatus:errorDescription];
    }];
}

// 下载文件
- (void)downLoadFile
{
    NSString *remotePath = @"HTTP与FTP协议基础.pdf";
    NSString *locaPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    locaPath = [locaPath stringByAppendingPathComponent:remotePath];
    
    [self.ftpRequest downloadFileWithRelativePath:remotePath toLocalPath:locaPath progress:^(NSInteger totalSize, NSInteger finishedSize) {
        [SVProgressHUD showProgress:(float)finishedSize/totalSize];
    } sucess:^(__unsafe_unretained Class resultClass, id result) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:result];
    } fail:^(NSString *errorDescription) {
        [SVProgressHUD showErrorWithStatus:errorDescription];
    }];
}

// 上传文件
- (void)upLoadFile
{
    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *remotePath = [uuid stringByAppendingPathComponent:@"HTTP与FTP协议基础.pdf"];
    NSString *locaPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    locaPath = [locaPath stringByAppendingPathComponent:[remotePath lastPathComponent]];
    
    [self.ftpRequest uploadFileToRemoteRelativePath:remotePath withLocalPath:locaPath progress:^(NSInteger totalSize, NSInteger finishedSize) {
        [SVProgressHUD showProgress:(float)finishedSize/totalSize];
    } sucess:^(__unsafe_unretained Class resultClass, id result) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:result];
    } fail:^(NSString *errorDescription) {
        [SVProgressHUD showErrorWithStatus:errorDescription];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self showList];
            break;
        case 1:
            [self createFolder];
            break;
        case 2:
            [self upLoadFile];
            break;
        case 3:
            [self downLoadFile];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
