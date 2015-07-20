# NKDownloadManager
##利用NSURLSessionDataTask写的下载框架 ，
      第一，支持断点下载，文件存入cache文件夹
      第二，文件名利用文件url进行md5加密，不会重复下载
      第三，支持多任务下载，互不影响
##   一些易用的API
```
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
- (void)retryDownload:(NSString *)urlString;```



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
```
