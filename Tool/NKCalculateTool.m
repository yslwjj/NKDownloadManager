//
//  NKCalculateTool.m
//  downLoad
//
//  Created by nickchen on 15/7/18.
//  Copyright (c) 2015年 nickqiao. All rights reserved.
//

#import "NKCalculateTool.h"

@implementation NKCalculateTool
+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return (float) (contentLength / (float)pow(1024, 3));
    else if(contentLength >= pow(1024, 2))
        return (float) (contentLength / (float)pow(1024, 2));
    else if(contentLength >= 1024)
        return (float) (contentLength / (float)1024);
    else
        return (float) (contentLength);
}
+ (NSString *)calculateUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return @"GB";
    else if(contentLength >= pow(1024, 2))
        return @"MB";
    else if(contentLength >= 1024)
        return @"KB";
    else
        return @"Bytes";
}
+ (NSString *)calculateTime:(NSTimeInterval)timeInterval
{
    NSMutableString *timeStr = [NSMutableString string];
    int hours = timeInterval / 3600;
    int minutes = (timeInterval - hours * 3600) / 60;
    int seconds = timeInterval - hours * 3600 - minutes * 60;
    
    if(hours>0)
        [timeStr appendFormat:@"%d Hours ",hours];
    if(minutes>0)
        [timeStr appendFormat:@"%d Min ",minutes];
    if(seconds>0)
        [timeStr appendFormat:@"%d sec",seconds];
    return timeStr;
}
@end
