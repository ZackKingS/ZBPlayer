//
//  ZBTool.h
//  ZBPlayer
//
//  Created by 柏超曾 on 2017/8/25.
//  Copyright © 2017年 柏超曾. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBTool : NSObject

+(NSMutableArray*) read;

+(void)saveWithMutableArray:(NSMutableArray*)mutableArray ;

+(void)addMov:(NSString *)str;

+(void)deleteAtIndexPath:(NSInteger)index;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (BOOL)isValidatIP:(NSString *)ipAddress ;

+ (NSDictionary *)getIPAddresses;
@end
