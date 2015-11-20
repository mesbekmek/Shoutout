//
//  SOCameraOverlay.h
//  Shoutout
//
//  Created by Varindra Hart on 11/19/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <UIKit/UIKit.h>

const int MAX_STRING_LENGTH = 25;

@interface SOCameraOverlay : UIView <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *tagButton;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;

@property (nonatomic) BOOL edited;

-(IBAction)tagButtonTapped:(id)sender;

//-(instancetype)initWithGestureRecognizer;
- (void)setUpGestureRecognizer;
@end
