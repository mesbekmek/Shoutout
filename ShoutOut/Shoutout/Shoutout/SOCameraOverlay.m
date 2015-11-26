//
//  SOCameraOverlay.m
//  Shoutout
//
//  Created by Varindra Hart on 11/23/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOCameraOverlay.h"

@implementation SOCameraOverlay

- (instancetype)initFromNib{
    
    if (self = [super init]) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlay" owner:self options:nil] firstObject];
        
        return self;
    }
    
    return nil;
}


- (void)handlePan:(UIPanGestureRecognizer *)pan{
    
    CGPoint translation = [pan translationInView:self.superview];
    
    pan.view.center = CGPointMake(pan.view.center.x, pan.view.center.y + translation.y);
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

- (BOOL)hasText {
    
    if (!self.edited) {
        return NO;
    }
    else if ([self.tagTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
        return YES;
    }
    
    return NO;
    
}
@end
