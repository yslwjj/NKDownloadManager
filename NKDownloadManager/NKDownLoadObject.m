//
//  NKDownLoadObject.m
//  backGroundDownLoad
//
//  Created by Nickqiao on 15/7/17.
//  Copyright (c) 2015年 https://github.com/nickqiao/NKDownloadManager/ All rights reserved.
//

#import "NKDownLoadObject.h"
#import "NKProgressInfo.h"
@implementation NKDownLoadObject

-(NKProgressInfo *)progressInfo
{
    if (!_progressInfo) {
        _progressInfo = [[NKProgressInfo alloc] init];
    }
    return _progressInfo;
}

-(NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    }
    return _stream;
}

+ (instancetype)downLoadObjectWith:(NSURLSessionDataTask *)dataTask progress:(void(^)(NKProgressInfo *progressInfo))progressBlock complete:(void(^)(NSString *filePath,NSError *error))completion
{
    NKDownLoadObject *obj = [[self alloc] init];
    obj.dataTask = dataTask;
    obj.progressBlock = progressBlock;
    obj.completion = completion;
    return obj;

}


@end
