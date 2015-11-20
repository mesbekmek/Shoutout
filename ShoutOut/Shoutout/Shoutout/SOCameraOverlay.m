//
//  SOCameraOverlay.m
//  Shoutout
//
//  Created by Varindra Hart on 11/19/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOCameraOverlay.h"

@implementation SOCameraOverlay

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithGestureRecognizer{
    
    if (self = [super init]) {
            self.edited = NO;
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        
        [self.tagTextField addGestureRecognizer:panGest];
        self.tagTextField.hidden = YES;
        
        return self;
    
    }
    return nil;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan{
    
    CGPoint translation = [pan translationInView:self.superview];
    
    pan.view.center = CGPointMake(pan.view.center.x + translation.x, pan.view.center.y + translation.y);
    [pan setTranslation:CGPointMake(0,0) inView:self];
}

- (IBAction)tagButtonTapped:(id)sender{
    
    if (!self.edited) {
        self.tagTextField.hidden = NO;
        self.tagTextField.text = @"";
        self.edited = YES;
    }
    else{
        self.tagTextField.hidden = YES;
        self.edited = NO;
    }
    
}

@end
