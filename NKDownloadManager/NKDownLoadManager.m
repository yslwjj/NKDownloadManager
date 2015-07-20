//
//  NKDownLoadManager.m
//  backGroundDownLoad
//
//  Created by nickchen on 15/7/17.
//  Copyright (c) 2015年 nickqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NKDownLoadManager.h"

#import "NKDownLoadObject.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NKProgressInfo.h"

NSString * const kNKDownloadKeyURL = @"URL";
NSString * const kNKDownloadKeyFileName = @"fileName";

#define fileLengthList [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"length.plist"]

@interface NKDownLoadManager ()<NSURLSessionDataDelegate>
@property(nonatomic,strong) NSURLSession *session;
@property(nonatomic,strong) NSURLSession *backgroundSession;

// 普通下载数组
@property(nonatomic,strong) NSMutableArray *downloadingArray;
@end

@implementation NKDownLoadManager
#pragma mark -- singleton
static id _instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
#pragma mark -- lazy
/**
 *  这个单例对象的session
 */
- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *confi = [NSURLSessionConfiguration defaultSessionConfiguration];
        confi.HTTPMaximumConnectionsPerHost = 5;
        _session = [NSURLSession sessionWithConfiguration:confi delegate:self delegateQueue:nil];
    }
    return _session;
}

- (NSURLSession *)backgroundSession
{
    if (!_backgroundSession) {
        NSURLSessionConfiguration *confi = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backGround"];
        _backgroundSession = [NSURLSession sessionWithConfiguration:confi delegate:self delegateQueue:nil];
    }
    return _backgroundSession;
}

/**
 *  下载数组
 */
- (NSMutableArray *)downloadingArray
{
    if (!_downloadingArray) {
        _downloadingArray = @[].mutableCopy;
    }
    return _downloadingArray;
}


#pragma mark -- download Method
- (void)download:(NSString *)urlString
        progress:(void(^)(NKProgressInfo* progressInfo))progressBlock
        complete:(void(^)(NSString *filePath,NSError *error))completion
enableBackgroundMode:(BOOL)backgroundMode
{
   
    NSString *fileName = [self getFileName:urlString];
    if ([self fileHasBeenDownloaded:fileName]) {
        NKProgressInfo *progressInfo = [self progressInfoIfFileExsit:urlString];
        progressBlock(progressInfo);
        NSLog(@"下载完成");
    }else{

        // 创建下载任务
        NSURLSessionDataTask *dataTask = [self createDataTask:urlString enableBackgroundMode:backgroundMode];
        NKDownLoadObject *downloadObject = [NKDownLoadObject downLoadObjectWith:dataTask progress:progressBlock complete:completion];
        downloadObject.startTime = [NSDate date];
        downloadObject.fileName = fileName;
        downloadObject.filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
        downloadObject.status = RequestStatusDownloading;
        [self.downloadingArray addObject:downloadObject];
        [dataTask resume];
    }
}
/**
 *  创建一个新的下载任务
 *
 *  @param urlString
 *  @param backgroundMode 后台模式选择(预留)
 */
- (NSURLSessionDataTask *)createDataTask:(NSString *)urlString enableBackgroundMode:(BOOL)backgroundMode
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *fileName = [self getFileName:urlString];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    NSUInteger finishedLength = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil][NSFileSize] integerValue];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", finishedLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    // 设置任务描述信息
    NSMutableDictionary *descDict = [NSMutableDictionary dictionary];
    [descDict setObject:urlString forKey:kNKDownloadKeyURL];
    [descDict setObject:fileName forKey:kNKDownloadKeyFileName];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:descDict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // 产生一个新任务
    NSURLSessionDataTask *dataTask = nil;
    if (backgroundMode) {
        dataTask = [self.backgroundSession dataTaskWithRequest:request];
    }else{
        dataTask = [self.session dataTaskWithRequest:request];
    }
    [dataTask setTaskDescription:jsonString];
    return dataTask;
}

#pragma mark -- File Method
/**
 *  如果文件已经存在，返回文件的下载进度
 */
- (NKProgressInfo *)progressInfoIfFileExsit:(NSString *)urlString
{
    NSString *fileName = [self getFileName:urlString];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    if ([self fileExistsWithName:fileName]) {
        NKProgressInfo *progressInfo = [[NKProgressInfo alloc] init];
        //
        progressInfo.finishedLength = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil][NSFileSize] integerValue];
        progressInfo.expectedLength = [[NSDictionary dictionaryWithContentsOfFile:fileLengthList][fileName] integerValue];
        progressInfo.progress = 1.0 * progressInfo.finishedLength / progressInfo.expectedLength;
        progressInfo.speed = 0.0;
        progressInfo.remainingLength = progressInfo.expectedLength - progressInfo.expectedLength;
        progressInfo.downloadTime = 0.0;
        progressInfo.remainingTime = 0.0;
        return progressInfo;
    }
    return nil;
}

- (BOOL)fileExistsWithName:(NSString *)fileName
{
    BOOL exists = NO;
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        exists = YES;
    }
    
    return exists;
}
// 是否下载100%完成
- (BOOL)fileHasBeenDownloaded:(NSString *)fileName
{
    BOOL Done = NO;
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    NSUInteger finishedLength = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil][NSFileSize] integerValue];
    NSInteger totalLength = [[NSDictionary dictionaryWithContentsOfFile:fileLengthList][fileName] integerValue];
    if (totalLength && finishedLength == totalLength) {
        Done = YES;
    }
    return Done;
}
/**
 *  返回文件类型
 */
- (NSString *)fileTypeWith:(NSString *)urlString
{
    NSString *urlLastPathComponent = [[urlString componentsSeparatedByString:@"/"] lastObject];
    NSString *fileType = [[urlLastPathComponent componentsSeparatedByString:@"."] lastObject];
    return fileType;
}
/**
 *  返回文件名
 */
- (NSString *)getFileName:(NSString *)urlString
{
    NSString *fileNameWithoutType = [self md5:urlString];
    NSString *fileType = [self fileTypeWith:urlString];
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",fileNameWithoutType,fileType];
    return fileName;
}

#pragma mark -- Cancel Method
- (void)cancelAllDownload
{
    [self.downloadingArray enumerateObjectsUsingBlock:^(NKDownLoadObject *downloadObject, NSUInteger idx, BOOL *stop) {
        if (downloadObject.completion) {
            downloadObject.completion = nil;
        }
        [downloadObject.dataTask cancel];
        [self.downloadingArray removeObject:downloadObject];
    }];
}

- (void)cancelDownload:(NSString *)urlString
{
    [self.downloadingArray enumerateObjectsUsingBlock:^(NKDownLoadObject *downloadObject, NSUInteger idx, BOOL *stop) {
        if ([downloadObject.fileName isEqualToString:[self getFileName:urlString]]) {
            if (downloadObject.completion) {
                downloadObject.completion = nil;
            }
            [downloadObject.dataTask cancel];
            [self.downloadingArray removeObject:downloadObject];
        }
    }];
}

#pragma mark -- pauseOrRetry Method
- (void)pauseDownload:(NSString *)urlString
{
    NSString *fileName = [self getFileName:urlString];
    [self.downloadingArray enumerateObjectsUsingBlock:^(NKDownLoadObject *downloadObject, NSUInteger idx, BOOL *stop) {
        RequestStatus status = downloadObject.status;
        if (status == RequestStatusDownloading && [downloadObject.fileName isEqualToString:fileName]) {
            [downloadObject.dataTask suspend];
            downloadObject.status = RequestStatusPaused;
        }
    }];
}

- (void)retryDownload:(NSString *)urlString
{
    NSString *fileName = [self getFileName:urlString];
    [self.downloadingArray enumerateObjectsUsingBlock:^(NKDownLoadObject *downloadObject, NSUInteger idx, BOOL *stop) {
        RequestStatus status = downloadObject.status;
        if (status == RequestStatusPaused && [downloadObject.fileName isEqualToString:fileName]) {
            [downloadObject.dataTask resume];
            downloadObject.status = RequestStatusDownloading;
        }
    }];
}

#pragma mark -- NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self.downloadingArray enumerateObjectsUsingBlock:^(NKDownLoadObject *downloadObject, NSUInteger idx, BOOL *stop) {
        if ([downloadObject.dataTask isEqual:dataTask]) {
            [downloadObject.stream open];
            
            // 获得已经下载的长度
            downloadObject.progressInfo.finishedLength = [[[NSFileManager defaultManager] attributesOfItemAtPath:downloadObject.filePath error:nil][NSFileSize] integerValue];
            downloadObject.progressInfo.expectedLength = [response.allHeaderFields[@"Content-Length"] integerValue] + downloadObject.progressInfo.finishedLength;
            
            // 把文件长度存进列表文件
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:fileLengthList];
            if (dict == nil) dict = [NSMutableDictionary dictionary];
            dict[downloadObject.fileName] = @(downloadObject.progressInfo.expectedLength);
            [dict writeToFile:fileLengthList atomically:YES];
            
            // 接收这个请求，允许接收服务器的数据
            completionHandler(NSURLSessionResponseAllow);
        }
    }];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.downloadingArray enumerateObjectsUsingBlock:^(NKDownLoadObject *downloadObject, NSUInteger idx, BOOL *stop) {
        if ([downloadObject.dataTask isEqual:dataTask]) {
            // 写入数据
            NSUInteger left = [data length];
            downloadObject.progressInfo.finishedLength += left;
            NSUInteger nwr = 0;
            do {
                nwr = [downloadObject.stream write:[data bytes] maxLength:left];
                if (-1 == nwr) {
                    break;
                }
                left -= nwr;
            } while (left > 0);
            if (left) {
                NSLog(@"stream error: %@",[downloadObject.stream streamError]);
            }
            if (downloadObject.progressBlock) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    downloadObject.progressInfo.progress = 1.0 * downloadObject.progressInfo.finishedLength / downloadObject.progressInfo.expectedLength;
                    downloadObject.progressInfo.downloadTime = -1 * [downloadObject.startTime timeIntervalSinceNow];
                    downloadObject.progressInfo.speed = downloadObject.progressInfo.finishedLength / downloadObject.progressInfo.downloadTime;
                    downloadObject.progressInfo.remainingLength = downloadObject.progressInfo.expectedLength - downloadObject.progressInfo.finishedLength;
                    downloadObject.progressInfo.remainingTime = downloadObject.progressInfo.remainingLength / downloadObject.progressInfo.speed;
                    downloadObject.progressBlock(downloadObject.progressInfo);
                });
            };
        }
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ([session isEqual:self.backgroundSession]) {
        [task resume];
        NSLog(@"%@",error);
    }else{
        [self.downloadingArray enumerateObjectsUsingBlock:^(NKDownLoadObject *downloadObject, NSUInteger idx, BOOL *stop) {
            if ([downloadObject.dataTask isEqual:task]) {
                if (downloadObject.completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        downloadObject.completion(downloadObject.filePath,error);
                    });
                }
                [downloadObject.stream close];
                downloadObject.stream = nil;
                [downloadObject.dataTask cancel];
                downloadObject.dataTask = nil;
                
                [self.downloadingArray removeObject:downloadObject];
            }
        }];
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([dataTasks count] == 0) {
            if (self.backgroundTransferCompletionHandler != nil ) {
                void(^completionHandler)() = self.backgroundTransferCompletionHandler;
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler();
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"所有任务下载完成";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                });
                self.backgroundTransferCompletionHandler = nil;
            }
        }
    }];
}

#pragma mark -- md5
- (NSString *)md5:(NSString *)str
{
    NSData *stringbytes = [str dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    if (CC_MD5([stringbytes bytes], (int)[stringbytes length], digest)) {
        NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            unsigned char achar = digest[i];
            [digestString appendFormat:@"%02X",achar];
        }
        return digestString;
    }
    return nil;
}



@end
