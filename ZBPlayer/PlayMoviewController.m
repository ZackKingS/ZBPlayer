//
//  PlayMoviewController.m
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/24.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import "PlayMoviewController.h"
#import "SBPlayer.h"


@interface PlayMoviewController ()
@property (nonatomic,strong) SBPlayer *player;
@property (nonatomic, strong) UIView *showView;

@property (weak, nonatomic) IBOutlet UIView *myView;

@end

@implementation PlayMoviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    
    //1.
//    NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"4k" ofType:@"mp4"]];
    
    
    NSString *str= [[NSUserDefaults standardUserDefaults] objectForKey:@"zburl"];

    
    self.player = [[SBPlayer alloc]initWithUrl:[NSURL URLWithString:str]];
    
    

    
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
        make.top.mas_equalTo(self.view.mas_top).offset(70);
        make.height.mas_equalTo(@250);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    
    [self.player stop];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
