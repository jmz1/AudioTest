//
//  FFTTViewController.h
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFTTViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
//- (IBAction)getButtonPressed:(UIButton *)sender;
- (IBAction)switchChanged:(UISwitch *)sender;

@end
