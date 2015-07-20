//
//  downLoadInfo.h
//  backGroundDownLoad
//
//  Created by Nickqiao on 15/7/15.
//  Copyright (c) 2015年 https://github.com/nickqiao/NKDownloadManager/ All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DownLoadStatus)
{
    DownLoadStatusBegin,
    DownLoadStatusDownLoading,
    DownLoadStatusPause,
    DownLoadStatusDownloaded
};

@interface downLoadInfo : NSObject

@property (nonatomic,copy) NSString *vedioUrlString;
@property (nonatomic,assign) DownLoadStatus status;
@property (nonatomic,assign) float progress;
@property (nonatomic,copy) NSString *remainingTime;
@property (nonatomic,copy) NSString *detail;
@property (nonatomic,copy) NSString *filePath;

+ (instancetype)downLoadInfoWithvedioUrlString:(NSString *)vedioUrl;

@end
