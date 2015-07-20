//
//  NKProgressInfo.h
//  downLoad
//
//  Created by nickchen on 15/7/18.
//  Copyright (c) 2015年 nickqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NKProgressInfo : NSObject

/**
 *  下载进度
 */
@property (nonatomic,assign) float progress;
/**
 *  下载速度
 */
@property (nonatomic,assign) float speed;
/**
 *  文件总大小
 */
@property (nonatomic,assign) unsigned long long expectedLength;
/**
 *  已下载大小
 */
@property (nonatomic,assign) unsigned long long finishedLength;
/**
 *  未下载大小
 */
@property (nonatomic,assign) unsigned long long remainingLength;
/**
 *  已下载用时
 */
@property (nonatomic,assign) NSTimeInterval downloadTime;

/**
 *  预计剩余下载时间
 */
@property (nonatomic,assign) NSTimeInterval remainingTime;

@end
