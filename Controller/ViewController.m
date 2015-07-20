//
//  ViewController.m
//  backGroundDownLoad
//
//  Created by nickchen on 15/7/15.
//  Copyright (c) 2015年 nickqiao. All rights reserved.
//

#import "ViewController.h"
#import "NKDownLoadManager.h"
#import "downLoadInfo.h"
#import "NKDownLoadCell.h"
#import "NKCalculateTool.h"
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *downloadArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
}

- (NSMutableArray *)downloadArray
{
    if (!_downloadArray){
        _downloadArray = @[].mutableCopy;
        for (int i = 1; i <= 10; i++) {
            NSString *vediourl = [NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_0%d.mp4",i];
            [_downloadArray addObject:[downLoadInfo downLoadInfoWithvedioUrlString:vediourl]];
        }
    }
    return _downloadArray;
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.downloadArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"download";
    NKDownLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
       [cell.downLoadBtn addTarget:self action:@selector(downLoadBtnClicked:) forControlEvents:UIControlEventTouchDown];
    cell.downLoadBtn.row = indexPath.row;
    cell.downLoadBtn.section = indexPath.section;
    
    [cell.playBtn addTarget:self action:@selector(playClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.row = indexPath.row;
    cell.playBtn.section = indexPath.section;
    
    [self updateCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(NKDownLoadCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    downLoadInfo *downloadInfo = [self.downloadArray objectAtIndex:indexPath.row];
    if (downloadInfo.progress == 1.0) {
        downloadInfo.status = DownLoadStatusDownloaded;
        cell.playBtn.enabled = YES;
    }else{
        cell.playBtn.enabled = NO;
    }
    
    if (downloadInfo.status == DownLoadStatusBegin) {
        [cell.downLoadBtn setBackgroundImage:[UIImage imageNamed:@"Download"] forState:UIControlStateNormal];
    }else if (downloadInfo.status == DownLoadStatusPause){
        [cell.downLoadBtn setBackgroundImage:[UIImage imageNamed:@"Download"] forState:UIControlStateNormal];
    }else if (downloadInfo.status == DownLoadStatusDownLoading && downloadInfo.progress > 0){
        [cell.downLoadBtn setBackgroundImage:[UIImage imageNamed:@"Downloading_pause"] forState:UIControlStateNormal];
    }else{
        [cell.downLoadBtn setBackgroundImage:[UIImage imageNamed:@"Downloaded"] forState:UIControlStateNormal];
    }
    
    cell.progressView.progress = downloadInfo.progress;
    cell.timeLabel.text = downloadInfo.remainingTime;
    cell.detailLabel.text = downloadInfo.detail;
}

#pragma mark -- ButtonAction
- (void)downLoadBtnClicked:(NKIndexButton *)button
{
    button.selected = !button.isSelected;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.row inSection:button.section];
    downLoadInfo *downLoadInfo = self.downloadArray[button.row];
    
    if (downLoadInfo.status == DownLoadStatusBegin) {
        // 开始下载
        downLoadInfo.status = DownLoadStatusDownLoading;
        [[NKDownLoadManager sharedManager] download:downLoadInfo.vedioUrlString
                                           progress:^(NKProgressInfo *progressInfo) {
                                               
            [self localizedDownloadInfo:downLoadInfo with:progressInfo];
            [self.downloadArray replaceObjectAtIndex:indexPath.row withObject:downLoadInfo];
            [self.tableView reloadData];
                                               
        } complete:^(NSString *filePath, NSError *error) {
            downLoadInfo.filePath = filePath;
        } enableBackgroundMode:NO];
        
    }else if(downLoadInfo.status == DownLoadStatusDownLoading) {
        // 暂停下载
        downLoadInfo.status = DownLoadStatusPause;
        [[NKDownLoadManager sharedManager] pauseDownload:downLoadInfo.vedioUrlString];
        [self.downloadArray replaceObjectAtIndex:indexPath.row withObject:downLoadInfo];
        [self.tableView reloadData];

        
    }else {
        // 继续下载
        downLoadInfo.status =  DownLoadStatusDownLoading;
        [[NKDownLoadManager sharedManager] retryDownload:downLoadInfo.vedioUrlString];
        [self.downloadArray replaceObjectAtIndex:indexPath.row withObject:downLoadInfo];
        [self.tableView reloadData];

    }
}

- (void)playClicked:(NKIndexButton *)button
{
    
    downLoadInfo *downloadInfo = [self.downloadArray objectAtIndex:button.row];
    NSURL *url = [NSURL fileURLWithPath:downloadInfo.filePath];
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)stopAll:(id)sender {
}

// 本地化进度信息
- (void)localizedDownloadInfo:(downLoadInfo *) downLoadInfo with :(NKProgressInfo *)progressInfo
{
    downLoadInfo.progress = progressInfo.progress;
    downLoadInfo.remainingTime = [NSMutableString stringWithFormat:@"还需:%@",[NKCalculateTool calculateTime:progressInfo.remainingTime]];
    
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                 [NKCalculateTool calculateFileSizeInUnit:progressInfo.expectedLength],
                                 [NKCalculateTool calculateUnit:progressInfo.expectedLength]];
    NSString *finishedSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                     [NKCalculateTool calculateFileSizeInUnit:progressInfo.finishedLength],
                                     [NKCalculateTool calculateUnit:progressInfo.finishedLength]];
    NSString *speedInUnits = [NSString stringWithFormat:@"%.2f %@/s",
                              [NKCalculateTool calculateFileSizeInUnit:progressInfo.speed],
                              [NKCalculateTool calculateUnit:progressInfo.speed]];
    
    downLoadInfo.detail = [NSMutableString stringWithFormat:@"%@/%@\n下载速度:%@",
                           finishedSizeInUnits,fileSizeInUnits,speedInUnits];
}



@end
