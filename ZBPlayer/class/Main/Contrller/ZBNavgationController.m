//
//  ZBNavgationController.m
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/24.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import "ZBNavgationController.h"

@interface ZBNavgationController ()

@end

@implementation ZBNavgationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 统一设置返回按钮  && 隐藏底部条
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // 设置返回按钮,只有非根控制器
    if (self.childViewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"<返回" style:UIBarButtonItemStylePlain target:self action:@selector(backUp)];
        
        //隐藏底部条
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)backUp{
    [self popViewControllerAnimated:NO];
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
