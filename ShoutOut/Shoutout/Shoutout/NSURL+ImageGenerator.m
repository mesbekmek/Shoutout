//
//  NSURL+ImageGenerator.m
//  WIT
//
//  Created by Varindra Hart on 10/31/15.
//  Copyright © 2015 Varindra Hart. All rights reserved.
//

#import "NSURL+ImageGenerator.h"

@implementation NSURL (ImageGenerator)

- (UIImage *)thumbnailImagePreview{
    /*
     CODE Via Mike Kavouras
     
     func thumbnailImagePreview() -> UIImage?
     {
     let asset = AVURLAsset(URL: self)
     let imageGenerator = AVAssetImageGenerator(asset: asset)
     imageGenerator.appliesPreferredTrackTransform = true
     imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels
     
     do {
     let time: CMTime = CMTime(seconds: 0.0, preferredTimescale:1)
     let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
     return UIImage(CGImage: imageRef)
     } catch {
     return nil
     }
     }

     */
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = true;
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    
    
        CMTime time = CMTimeMake(0.0, 1);
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:nil error:nil];
    UIImage* image = [UIImage imageWithCGImage:cgImage];
    
    if (image) {
        return image;
    }
    else{
        return nil;
    }
    
}

@end
