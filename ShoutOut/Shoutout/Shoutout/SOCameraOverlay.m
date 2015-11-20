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

- (void)setUpGestureRecognizer{
    self.edited = NO;
    self.tagTextField.delegate = self;
    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    
    [self.tagTextField addGestureRecognizer:panGest];
    self.tagTextField.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self endEditing:YES];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self endEditing:YES];
    
}
@end
