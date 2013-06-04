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
    
    BOOL fundamentalBeat = [[analysisResults.beatStates objectAtIndex:kManualBin] boolValue];
    
    if (fundamentalBeat == TRUE) {
        self.beatLabel.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.beatLabel.backgroundColor = [UIColor blackColor];
    }
}
    
    
@end
