//
//  VideoViewController.h
//  Shoutout
//
//  Created by Varindra Hart on 11/24/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
#import "SOShoutout.h"


@interface VideoViewController : UIViewController

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (nonatomic) SOShoutout *shoutout;

@end
