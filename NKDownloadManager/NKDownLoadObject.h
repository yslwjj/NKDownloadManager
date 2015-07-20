//
//  NKDownLoadObject.h
//  backGroundDownLoad
//
//  Created by nickchen on 15/7/17.
//  Copyright (c) 2015年 nickqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  下载状态
 */
typedef NS_ENUM(NSUInteger, RequestStatus){
    /**
     *  正在下载
     */
    RequestStatusDownloading,
    /**
     *  暂停下载
     */
    RequestStatusPaused,
    /**
     *  下载失败
     */
    RequestStatusFailed
};

@class NKProgressInfo;

@interface NKDownLoadObject : NSObject
/**
 *  进度信息
 */
@property(nonatomic,strong) NKProgressInfo *progressInfo;

/**
 *  文件名
 */
@property (nonatomic,copy) NSString *fileName;
/**
 *  下载任务
 */
@property(nonatomic,strong) NSURLSessionDataTask *dataTask;
/**
 *  文件存储路径
 */
@property (nonatomic,copy) NSString *filePath;
/**
 *  下载开始时间
 */
@property(nonatomic,strong) NSDate *startTime;
/**
 *  当前请求状态
 */
@property (nonatomic,assign) RequestStatus status;

/**
 *  下载时候的流对象
 */
@property(nonatomic,strong) NSOutputStream *stream;

/**
 *  下载中回调
 */
@property(nonatomic,copy) void(^progressBlock)(NKProgressInfo *progressInfo);
/**
 *  下载完成后回调
 */
@property(nonatomic,strong) void(^completion)(NSString *filePath,NSError *error) ;
/**
 *  快速初始化对象
 */
+ (instancetype)downLoadObjectWith:(NSURLSessionDataTask *)dataTask progress:(void(^)(NKProgressInfo *progressInfo))progressBlock complete:(void(^)(NSString *filePath,NSError *error))completion;
@end
