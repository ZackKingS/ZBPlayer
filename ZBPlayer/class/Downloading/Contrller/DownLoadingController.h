//
//  DownLoadingController.h
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/24.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownLoadingController : UIViewController
@property(strong,nonatomic) void(^block)(NSString * progress);
@end
