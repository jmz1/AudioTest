//
//  FFTTViewController.m
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTViewController.h"
#import "FFTTAudioHandler.h"


@interface FFTTViewController ()

@end

@implementation FFTTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)getButtonPressed:(UIButton *)sender {
//    NSLog(@"Hello");
//    self.countLabel.text = [NSString stringWithFormat:@"%d",5];
//}
- (IBAction)switchChanged:(UISwitch *)sender {
    NSLog(@"Hello");
//    NSLog(@"%@", self.countLabel.text);
    self.countLabel.text = [NSString stringWithFormat:@"%d", 5];

}
@end
