//
//  ZBTabbarController.m
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/24.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import "ZBTabbarController.h"

#import "DownLoadedController.h"
#import "DownLoadingController.h"
#import "ZBNavgationController.h"
@interface ZBTabbarController ()

@end

@implementation ZBTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
      [self addAllController];
    
    
     [self setupAllTabBarItem];
  
    
}


- (void)addAllController
{
    
    
    
    DownLoadingController *recently = [[DownLoadingController alloc]init];
    ZBNavgationController *nav2 = [[ZBNavgationController alloc]initWithRootViewController:recently];
    [self addChildViewController:nav2];
    
    
    DownLoadedController *downloaded = [[DownLoadedController alloc]init];
    ZBNavgationController *nav1 = [[ZBNavgationController alloc]initWithRootViewController:downloaded];
    [self addChildViewController:nav1];
    
}


- (void)setupAllTabBarItem
{
    
    UINavigationController *nav = self.childViewControllers[0];
    [nav.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    nav.tabBarItem.title = @"下载中";
//    nav.tabBarItem.image = [UIImage imageNamed:@"duobao.png"];
    // 快速生成一个没有渲染图片
//    nav.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"duobao.png"];
    
    
    UINavigationController *nav1 = self.childViewControllers[1];
    nav1.tabBarItem.title = @"已下载";
//    nav1.tabBarItem.image = [UIImage imageNamed:@"will.png"];
//    nav1.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"will.png"];
    
    

    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
