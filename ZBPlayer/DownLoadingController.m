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



#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height



@interface DownLoadingController ()<UITableViewDelegate,UITableViewDataSource,NSURLSessionDownloadDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray   *movieArr ;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumData;
@property (nonatomic, strong) NSURLSession *session;


@end
NSString * const MYID = @"MovieCell";

@implementation DownLoadingController

- (NSMutableArray *)movieArr
{
    
    if (!_movieArr) {
        
        _movieArr = [NSMutableArray array];
        
        [_movieArr addObject:@"海贼王"];
        [_movieArr addObject:@"死神"];
        [_movieArr addObject:@"火影"];
    }
    return _movieArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
  
    
    [self setupTableView];
    
    [self setupNavigationItem];
    
    
    
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
    
     self.navigationItem.title = @"下载中";
    
    UIBarButtonItem *addItem = [[UIBarButtonItem  alloc]initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addMoview)];
    
    self.navigationItem.rightBarButtonItem = addItem;
    
}

-(void)addMoview{
    
    AddingMovieController *adding = [[AddingMovieController alloc]init];
    
    adding.block = ^(NSString *str) {
      
        [self.movieArr addObject:str];
        
        [self.tableView reloadData];
        
        [self startBtnClick:str];  //下载
        
    };
    
    adding.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:adding animated:YES];
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
    
    
//    _progressView.progress = 1.0 * totalBytesWritten/totalBytesExpectedToWrite;
    
    
//    _progressTitle.text = [NSString stringWithFormat:@"%.2f",1.0 * totalBytesWritten/totalBytesExpectedToWrite *100];
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
    
    
//    self.videouri = fullPath;
    
    
    //2 剪切文件
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
    
    
    NSLog(@"下载完成");
    NSLog(@"%@",fullPath);
    
    
   
    fullPath = [@"file://" stringByAppendingString:fullPath];
//    NSURL * urllll = [NSURL URLWithString:fullPath];

    
    [[NSUserDefaults standardUserDefaults] setObject:fullPath forKey:@"zburl"];
    
    
    
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
    
    cell.textLabel.text = self.movieArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    return cell;
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PlayMoviewController *player= [[PlayMoviewController alloc]init];
    
    player.hidesBottomBarWhenPushed = YES;
    player.url =   [NSURL URLWithString:self.movieArr[indexPath.row]]  ;
    [self.navigationController pushViewController:player animated:YES];
    
    
}


@end
