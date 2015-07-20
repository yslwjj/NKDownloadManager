//
//  NKDownLoadCell.h
//  downLoad
//
//  Created by nickchen on 15/7/19.
//  Copyright (c) 2015年 nickqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NKIndexButton.h"
@interface NKDownLoadCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NKIndexButton *downLoadBtn;
@property (weak, nonatomic) IBOutlet NKIndexButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end
