//
//  SOExportHandler.m
//  Shoutout
//
//  Created by Varindra Hart on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOExportHandler.h"

@implementation SOExportHandler


- (void)exportMixComposition:(AVMutableComposition *)mixComposition completion:(void (^)(NSURL *url, BOOL success))onCompletion{
    
    NSURL *randomFinalVideoFileURL = [self getRandomVideoFileURL];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    exportSession.outputURL = randomFinalVideoFileURL;
    
    CMTimeValue val = mixComposition.duration.value;
    CMTime start = CMTimeMake(0, 1);
    CMTime duration = CMTimeMake(val, 1);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error]debugDescription]);
                onCompletion(nil,NO);
            }
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Export canceled");
                onCompletion(nil,NO);
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                NSLog(@"Export complete!");
                onCompletion(exportSession.outputURL, YES);
            }
            default:
            {
                NSLog(@"default");
//                onCompletion(nil,NO);
            }
        }
    }];
    
}

- (NSURL *)getRandomVideoFileURL{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo-%d.mp4",arc4random() % 1000]];
    NSURL *randomUrl = [NSURL fileURLWithPath:myPathDocs];
    
    return randomUrl;
    
}


- (AVMutableComposition *)mergeVideosFrom:(NSMutableArray <AVAsset *> *)videosArray{
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *audioCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CGSize size = CGSizeZero;
    CMTime time = kCMTimeZero;
    
    NSMutableArray *instructions = [NSMutableArray new];
    
    for(AVAsset *asset in videosArray)
    {
        AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        
        NSError *videoError;
        [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                       ofTrack:videoAssetTrack
                                        atTime:time
                                         error:&videoError];
        //Added this line in an attempt to fix the orientation
        videoCompositionTrack.preferredTransform = videoAssetTrack.preferredTransform;
        //
        if (videoError) {
            NSLog(@"Error - %@", videoError.debugDescription);
        }
        
        AVAssetTrack *audioAssetTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        NSError *audioError;
        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                       ofTrack:audioAssetTrack
                                        atTime:time
                                         error:&audioError];
        if (audioError) {
            NSLog(@"Error - %@", audioError.debugDescription);
        }
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        videoCompositionInstruction.timeRange = CMTimeRangeMake(time, videoAssetTrack.timeRange.duration);
        videoCompositionInstruction.layerInstructions = @[[AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack]];
        [instructions addObject:videoCompositionInstruction];
        
        time = CMTimeAdd(time, videoAssetTrack.timeRange.duration);
        
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = videoAssetTrack.naturalSize;;
        }
    }
    
    return mixComposition;
    
//    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
//    mutableVideoComposition.instructions = instructions;
//    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
//    mutableVideoComposition.renderSize = size;
//    
//    AVPlayerItem *pi = [AVPlayerItem playerItemWithAsset:mixComposition];
//    pi.videoComposition = mutableVideoComposition;
//    
//    return pi;
}
@end
