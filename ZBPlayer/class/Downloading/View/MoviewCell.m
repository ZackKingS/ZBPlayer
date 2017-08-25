//
//  MoviewCell.m
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/24.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import "MoviewCell.h"
#import "DownLoadingController.h"

@implementation MoviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    DownLoadingController *vc =[[DownLoadingController alloc]init];
    vc.block = ^(NSString *progress) {
        self.progressLabel.text = progress;
        
    };
    
   
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
