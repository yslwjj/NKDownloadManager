//
//  downLoadInfo.m
//  backGroundDownLoad
//
//  Created by Nickqiao on 15/7/15.
//  Copyright (c) 2015年 https://github.com/nickqiao/NKDownloadManager/ All rights reserved.
//

#import "downLoadInfo.h"
@implementation downLoadInfo

+ (instancetype)downLoadInfoWithvedioUrlString:(NSString *)vedioUrl
{
    downLoadInfo *downloadInfo = [[self alloc] init];
    downloadInfo.vedioUrlString = vedioUrl;
    downloadInfo.filePath = @"";
    downloadInfo.status = DownLoadStatusBegin;
    downloadInfo.detail = @"";
    downloadInfo.remainingTime = @"";
    downloadInfo.progress = 0.0;
    
    return downloadInfo;
}

@end
