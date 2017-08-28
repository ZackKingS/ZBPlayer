//
//  DownLoadingController.m
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/24.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import "DownLoadingController.h"
#import "AddingMovieController.h"
#import "PlayMoviewController.h"

#import "MoviewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SBPlayer.h"

#import "ZBTool.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "ZBTool.h"

@interface DownLoadingController ()<UITableViewDelegate,UITableViewDataSource,NSURLSessionDownloadDelegate>{
    HTTPServer * httpServer;
}



@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray   *movieArr ;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumData;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) double progress;

@end
NSString * const MYID = @"MovieCell";

@implementation DownLoadingController

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;//这里可以改变旋转的方向
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    
    
     NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSLog(@"%@",uploadDirPath);
    
    NSFileManager  *maneger = [[NSFileManager alloc]init];
    
    
     NSArray *subPaths = [maneger contentsOfDirectoryAtPath:uploadDirPath error:nil];
 
    NSLog(@"%@",subPaths);
}


- (NSMutableArray *)movieArr
{
    
//    if (!_movieArr) {
//        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *strPath = [documentsPath stringByAppendingPathComponent:@"text.txt"];
//        BOOL exist =   [[ [NSFileManager alloc]init]  fileExistsAtPath:strPath];
//        if (exist) {  //已经存在
//            
//            NSString *newStr = [NSString stringWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
//            NSArray  *array = [newStr componentsSeparatedByString:@" "];//分隔符逗号
//            _movieArr = [NSMutableArray  arrayWithArray:array];
//            for (NSString *str in _movieArr) {
//                if ([str isEqualToString:@""]) {
//                    [_movieArr removeObject:str];
//                    break;
//                }
//            }
//        }else{
//            
//            // 2.创建要存储的内容：字符串
//            _movieArr = [NSMutableArray array];
//            NSString *string = [_movieArr componentsJoinedByString:@""];
//            [string writeToFile:strPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//          
//        }
        
        
        //Method 2
        NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSFileManager  *maneger = [[NSFileManager alloc]init];
        NSArray *subPaths = [maneger contentsOfDirectoryAtPath:uploadDirPath error:nil];
        _movieArr = [NSMutableArray array];
        
        _movieArr = [NSMutableArray arrayWithArray:subPaths];
        
//    }
    return _movieArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [self setupHttp];
    [self setupTableView];
    [self setupNavigationItem];
    [self addobsever];
   
}

-(void)addobsever
{
    
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(reloading) name:@"ok" object:nil];
    
}

-(void)reloading{
    
    [self.tableView reloadData];
}


-(void)setupHttp{
    httpServer = [[HTTPServer alloc] init];
    
    [httpServer setType:@"_http._tcp."];
    
    // webPath是server搜寻HTML等文件的路径
    
    NSString *webPath = [[NSBundle mainBundle] resourcePath];
    
    [httpServer setDocumentRoot:webPath];
    
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    
    
}


-(void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MoviewCell class]) bundle:nil] forCellReuseIdentifier:MYID];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)setupNavigationItem
{
    
//     self.navigationItem.title = @"下载中";
//    UIBarButtonItem *addItem = [[UIBarButtonItem  alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addMoview)];
//    self.navigationItem.rightBarButtonItem = addItem;

    UIBarButtonItem *addItem = [[UIBarButtonItem  alloc]initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(addMoview)];
    self.navigationItem.rightBarButtonItem = addItem;
    
   
    
    NSError *err;
    
    if ([httpServer start:&err]) {
        
         self.navigationItem.title = [NSString stringWithFormat:@"%@:%hu",[ZBTool getIPAddress:YES],[httpServer listeningPort]];
        
        
        NSLog(@"%@",[NSString stringWithFormat:@"%@:%hu",[ZBTool getIPAddress:YES],[httpServer listeningPort]]);
        
    }else{
        
        NSLog(@"%@",err);
        
        
    }
    
}

-(void)addMoview{
    
//    AddingMovieController *adding = [[AddingMovieController alloc]init];
//    
//    adding.block = ^(NSString *str) {
//      
//         NSLog(@"%@",self.movieArr);
//        
//        [self.movieArr addObject:str];
//        
//        NSLog(@"%@",self.movieArr);
//        
//        [self.tableView reloadData];
//        
//        
//        [ZBTool addMov:str];
//        
//
//        
//        
//        [self startBtnClick:str];  //下载
//        
//    };
//    
//    adding.hidesBottomBarWhenPushed = YES;
//    
//    [self.navigationController pushViewController:adding animated:YES];
    
    [self.tableView reloadData];
}

#pragma mark ----------  开始  ------------
- (void)startBtnClick:(NSString *)str
{
//    //1.url
    NSURL *url = [NSURL URLWithString:str];
//
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //3.创建session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //4.创建Task
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
    
    //5.执行Task
    [downloadTask resume];
    
    self.downloadTask = downloadTask;
    
}

#pragma mark ----------  打印进度  ------------
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //1. 获得文件的下载进度
    NSLog(@"%f",1.0 * totalBytesWritten/totalBytesExpectedToWrite);
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"%.2f%%",1.0 * totalBytesWritten/totalBytesExpectedToWrite * 100];

    
    
    self.progress = 1.0 * totalBytesWritten/totalBytesExpectedToWrite * 100;
    

    
    
    MoviewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MYID];
    cell.progressLabel.text =[NSString stringWithFormat:@"%.2f%%",1.0 * totalBytesWritten/totalBytesExpectedToWrite * 100];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ---------- 当下载完成的时候调用  ------------

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"%@",location);
    
 
    
    //1 拼接文件全路径
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    

    //2 剪切文件
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];

    fullPath = [@"file://" stringByAppendingString:fullPath];

     NSLog(@"%@",fullPath);
    NSString *key =[NSString stringWithFormat:@"%d",self.movieArr.count];
    [[NSUserDefaults standardUserDefaults] setObject:fullPath forKey:key];
    
    
    self.navigationItem.title = @"已下载";
 
}


#pragma mark ---------- 下载异常  ------------
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"didCompleteWithError");
    NSLog(@"%@",error);
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.movieArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoviewCell *cell = [tableView dequeueReusableCellWithIdentifier:MYID forIndexPath:indexPath];
    
//    cell.textLabel.text = [self.movieArr[indexPath.row] lastPathComponent];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%",self.progress];;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",self.progress];
    cell.movieName.text = [self.movieArr[indexPath.row] lastPathComponent];

    
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PlayMoviewController *player= [[PlayMoviewController alloc]init];
//    player.hidesBottomBarWhenPushed = YES;
//    player.moiveName = [self.movieArr[indexPath.row] lastPathComponent];
//    
//    
//    player.key = [NSString stringWithFormat:@"%d",indexPath.row+1];
    
    
    
    NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *name = self.movieArr[indexPath.row];
    
    
    NSString *fullPath  =[NSString stringWithFormat:@"file://%@/%@",uploadDirPath,name];
    
//    NSString *fullPath = [uploadDirPath stringByAppendingString:name];
    
    NSLog(@"%@",fullPath);
    
    player.key = fullPath;
    [self.navigationController pushViewController:player animated:NO];
}


- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"commitEditingStyle--");
    [self.movieArr removeObjectAtIndex:indexPath.row];
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    
    
    NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSLog(@"%@",uploadDirPath);
    
    NSFileManager  *maneger = [[NSFileManager alloc]init];
    
    
    NSArray *subPaths = [maneger contentsOfDirectoryAtPath:uploadDirPath error:nil];
    
    NSLog(@"%@",subPaths);
    
    
    for (NSString *str in subPaths) {
        
        if ([str isEqualToString:self.movieArr[indexPath.row]]) {
            
            NSString *filePath = [uploadDirPath stringByAppendingPathComponent:str];
            
            // 删除路径
            [maneger removeItemAtPath:filePath error:nil];
//             maneger remove(<#const char *#>)
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView reloadData];
        }
    }
 
    
    
//    [ZBTool deleteAtIndexPath:indexPath.row];
    
}



- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end
