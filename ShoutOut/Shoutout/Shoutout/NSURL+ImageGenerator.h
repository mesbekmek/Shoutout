//
//  NSURL+ImageGenerator.h
//  WIT
//
//  Created by Varindra Hart on 10/31/15.
//  Copyright © 2015 Varindra Hart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface NSURL (ImageGenerator)

/*
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
- (UIImage *) thumbnailImagePreview;


@end
