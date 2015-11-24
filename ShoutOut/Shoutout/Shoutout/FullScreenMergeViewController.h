//
//  FullScreenMergeViewController.h
//  Shoutout
//
//  Created by Diana Elezaj on 11/24/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface FullScreenMergeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *fullScreenVideoPlaying;
@property (nonatomic) NSMutableArray<AVAsset *> *videoAssetsArray;
@end
