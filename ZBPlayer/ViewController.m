//
//  ViewController.m
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/22.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import "ViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "SBPlayer.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height



@interface ViewController ()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumData;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic,strong) MPMoviePlayerController *mpcontrol;


@property (weak, nonatomic) IBOutlet UILabel *progressTitle;


@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@property (weak, nonatomic)  NSString * videouri;



@property (nonatomic,strong) SBPlayer *player;
@property (nonatomic, strong) UIView *showView;

@end

@implementation ViewController




-(void)viewDidLoad{
    
    
    
    [super viewDidLoad];
    
    _progressView.progress = 0;
  
    
    //1.
    //NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"4k" ofType:@"mp4"]];
    
    
    //2.
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    // 获取文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    // 获取cache文件夹下所有文件,不包括子路径的子路径
    NSArray *subPaths = [mgr contentsOfDirectoryAtPath:[ arr lastObject] error:nil];
    
    NSURL *remoteURL = [NSURL URLWithString:[[ arr lastObject] stringByAppendingPathComponent:[subPaths lastObject]]];
    NSString *tr = [remoteURL absoluteString] ;
    tr = [@"file:///" stringByAppendingString:tr];
    NSURL * urllll = [NSURL URLWithString:tr];
    
    
    self.player = [[SBPlayer alloc]initWithUrl:urllll];
    
    
    
    

    
    
  
    
    
    
    
    
    //设置标题
    [self.player setTitle:@"这是一个标题"];
    //设置播放器背景颜色
    self.player.backgroundColor = [UIColor blackColor];
    //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
    self.player.mode = SBLayerVideoGravityResizeAspectFill;
    //添加播放器到视图
    [self.view addSubview:self.player];
    //约束，也可以使用Frame
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(@250);
    }];
    
    
    
    


}




#pragma mark ----------  开始  ------------
- (IBAction)startBtnClick:(id)sender
{
    //1.url
    NSURL *url = [NSURL URLWithString:@"http://116.211.186.142/videos/v0/20170820/ee/5d/d38eb7686939ac6a4fe9a1556b8ceb3b.mp4?key=6da14882e69017c1"];
    
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

//暂停是可以恢复
- (IBAction)suspendBtnClick:(id)sender
{
    NSLog(@"+++++++++++++++++++暂停");
    [self.downloadTask suspend];
}


#pragma mark ----------  取消  ------------
//cancel:取消是不能恢复
//cancelByProducingResumeData:是可以恢复
- (IBAction)cancelBtnClick:(id)sender
{
    NSLog(@"+++++++++++++++++++取消");
    //[self.downloadTask cancel];
    
    //恢复下载的数据!=文件数据
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        self.resumData = resumeData;
    }];
}


#pragma mark ----------  恢复下载  ------------


- (IBAction)goOnBtnClick:(id)sender
{
    NSLog(@"+++++++++++++++++++恢复下载");
    if(self.resumData)
    {
        self.downloadTask = [self.session downloadTaskWithResumeData:self.resumData];
    }
    
    [self.downloadTask resume];
}


//优点:不需要担心内存
//缺点:无法监听文件下载进度
-(void)download
{
    //1.url
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/images/minion_03.png"];
    
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //3.创建session
    NSURLSession *session = [NSURLSession sharedSession];
    
    //4.创建Task
    /*
     第一个参数:请求对象
     第二个参数:completionHandler 回调
     location:
     response:响应头信息
     error:错误信息
     */
    //该方法内部已经实现了边接受数据边写沙盒(tmp)的操作
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //6.处理数据
        NSLog(@"%@---%@",location,[NSThread currentThread]);
        
        //6.1 拼接文件全路径
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        
        
        self.videouri  = fullPath ;
        
        //6.2 剪切文件
        [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
        NSLog(@"%@",fullPath);
    }];
    
    //5.执行Task
    [downloadTask resume];
}



#pragma mark NSURLSessionDownloadDelegate
/**
 *  写数据
 *
 *  @param session                   会话对象
 *  @param downloadTask              下载任务
 *  @param bytesWritten              本次写入的数据大小
 *  @param totalBytesWritten         下载的数据总大小
 *  @param totalBytesExpectedToWrite  文件的总大小
 */




#pragma mark ----------  打印进度  ------------
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //1. 获得文件的下载进度
    NSLog(@"%f",1.0 * totalBytesWritten/totalBytesExpectedToWrite);
    
    
    _progressView.progress = 1.0 * totalBytesWritten/totalBytesExpectedToWrite;
    
    
    _progressTitle.text = [NSString stringWithFormat:@"%.2f",1.0 * totalBytesWritten/totalBytesExpectedToWrite *100];
}

/**
 *  当恢复下载的时候调用该方法
 *
 *  @param fileOffset         从什么地方下载
 *  @param expectedTotalBytes 文件的总大小
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"%s",__func__);
}

/**
 *  当下载完成的时候调用
 *
 *  @param location     文件的临时存储路径
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"%@",location);
    
    

    
    
    
    //1 拼接文件全路径
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    
    self.videouri = fullPath;
    
    
    //2 剪切文件
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
    NSLog(@"%@",fullPath);
}

/**
 *  请求结束
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"didCompleteWithError");
}





- (IBAction)play:(id)sender {
    
//       [self.player play];


//    
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"instruction" ofType:@"mp4"];
//        videoPath =  [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"instruction.mp4"];
//    NSURL *url = [NSURL fileURLWithPath:videoPath];
//    AVPlayer *player = [AVPlayer playerWithURL:url];
//    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
//    playerViewController.player = player;
//    [self presentViewController:playerViewController animated:YES completion:nil];
//    [playerViewController.player play];
    
    
    NSURL *URL = [NSURL fileURLWithPath:videoPath];
    MPMoviePlayerViewController  * moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    moviePlayerController.moviePlayer.movieSourceType=MPMovieSourceTypeFile;

}







@end
