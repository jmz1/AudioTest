//
//  FFTTViewController.m
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTViewController.h"
#import "FFTTAnalysisEngine.h"
#import "FFTTAnalysisResults.h"
#import "AnalysisDefines.h"

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

- (void) updateDisplayWithResults:(FFTTAnalysisResults*)analysisResults{
    
    // iterate through beat labels, displaying current beat state for each
    for (int i = 0; i < [self.beatLabels count]; i++) {
        UILabel *beatLabel = (UILabel*) [self.beatLabels objectAtIndex:i];
        BOOL beatState = [[analysisResults.beatStates objectAtIndex:i] boolValue];
        if (beatState == TRUE) {
            beatLabel.backgroundColor = [UIColor greenColor];
        }
        else{
            beatLabel.backgroundColor = [UIColor blackColor];
        }
    }
    
    // iterate through beat period labels, displaying current beat state for each
    for (int i = 0; i < [self.beatPeriodLabels count]; i++) {
        UILabel *beatPeriodLabel = (UILabel*) [self.beatPeriodLabels objectAtIndex:i];
        float impliedPeriod = [[analysisResults.impliedFrequency objectAtIndex:i] floatValue];

        beatPeriodLabel.text = [NSString stringWithFormat:@"%f", impliedPeriod];;
    }

    
    
}
    
    
@end
