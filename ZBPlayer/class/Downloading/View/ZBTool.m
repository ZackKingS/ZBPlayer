//
//  ZBTool.m
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/25.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import "ZBTool.h"

@implementation ZBTool

+(void)deleteAtIndexPath:(NSInteger)index{
    
    NSMutableArray *mutableArr =    [self read];
    [mutableArr removeObjectAtIndex:index];
    [self saveWithMutableArray:mutableArr];
    
    
}

+(void)addMov:(NSString *)str{
    
    NSMutableArray *muArr =    [self read];
    
    [muArr addObject:str];
    
    [self saveWithMutableArray:muArr];
}


+(NSMutableArray*) read{
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *strPath = [documentsPath stringByAppendingPathComponent:@"text.txt"];
    NSString *newStr = [NSString stringWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
    NSArray  *array = [newStr componentsSeparatedByString:@" "];//分隔符逗号
    
    NSMutableArray *ac = [NSMutableArray arrayWithArray:array];
    
    return ac;
}


+(void)saveWithMutableArray:(NSMutableArray*)mutableArray {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *strPath = [documentsPath stringByAppendingPathComponent:@"text.txt"];
    NSString *string = [mutableArray componentsJoinedByString:@" "];
    [string writeToFile:strPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSString *newStrr = [NSString stringWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", newStrr);
    
}
@end
