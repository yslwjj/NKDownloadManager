//
//  NKDownLoadManager.h
//  backGroundDownLoad
//
//  Created by Nickqiao on 15/7/17.
//  Copyright (c) 2015年 https://github.com/nickqiao/NKDownloadManager/ All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NKProgressInfo.h"


@interface NKDownLoadManager : NSObject

/**
 *  后台模式的回调block(由于还没写),此参数目前不能用
 */
@property (nonatomic, strong) void(^backgroundTransferCompletionHandler)();

/**
 *  @return 下载管理者
 */
+ (instancetype)sharedManager;

/**
 *  下载方法
 *
 *  @param urlString      文件的url路径
 *  @param progressBlock  文件下载过程的回调block
 *  @param completion     文件下载完完毕后的回调block
 *  @param backgroundMode 后台模式选择(此参数为预留,目前还没写,暂时传NO)
 */
- (void)download:(NSString *)urlString
        progress:(void(^)(NKProgressInfo* progressInfo))progressBlock
        complete:(void(^)(NSString *filePath,NSError *error))completion
enableBackgroundMode:(BOOL)backgroundMode;

/**
 *  暂停正在进行的下载任务
 */
- (void)pauseDownload:(NSString *)urlString;

/**
 *  继续暂停的下载任务
 */
- (void)retryDownload:(NSString *)urlString;

/**
 *  取消一个下载任务
 */
- (void)cancelDownload:(NSString *)urlString;

/**
 *  取消所有下载任务
 */
- (void)cancelAllDownload;

/**
 *  有的文件已经下载完毕或者下载了一部分，需要知道进度信息，调用此方法
 *
 *  @param urlString 文件的url
 *
 *  @return 已经存在文件的进度信息
 */
- (NKProgressInfo *)progressInfoIfFileExsit:(NSString *)urlString;

@end
