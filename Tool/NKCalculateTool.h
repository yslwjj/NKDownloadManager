//
//  NKCalculateTool.h
//  downLoad
//
//  Created by nickchen on 15/7/18.
//  Copyright (c) 2015年 nickqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NKCalculateTool : NSObject
/** 
 文件大小
 */
+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength;
/** 获得文件大小单位.
 @param 文件大小大小的单位
 @return 文件单位 e.g MB, KB, GB.
 */
+ (NSString *)calculateUnit:(unsigned long long)contentLength;
/**
 *  获得时间描述
 *
 *  @param timeInterval 时间跨度
 *
 *  @return 时间描述
 */
+ (NSString *)calculateTime:(NSTimeInterval)timeInterval;

@end
