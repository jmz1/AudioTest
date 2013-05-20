//
//  FFTTViewController.h
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFTTViewController : UIViewController

@property (nonatomic, retain) IBOutlet UISwitch *switchOutlet;
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UILabel *valueLabel;

- (IBAction)switchChanged:(UISwitch *)sender;

@end
