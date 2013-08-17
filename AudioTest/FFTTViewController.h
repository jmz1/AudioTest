//
//  FFTTViewController.h
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FFTTAnalysisEngine.h"

@class FFTTAnalysisResults;
@class FFTTAudioController;

@interface FFTTViewController : UIViewController

@property (nonatomic, retain) FFTTAudioController *audioController;

@property (nonatomic, retain) IBOutletCollection(UILabel) NSMutableArray *beatLabels;

@property (nonatomic, retain) IBOutletCollection(UILabel) NSMutableArray *beatPeriodLabels;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *displayLabels;

@property (weak, nonatomic) IBOutlet UILabel *detectedFrequencyLabel;


@property (weak, nonatomic) IBOutlet UITextField *minFrequencyEntry;
@property (weak, nonatomic) IBOutlet UITextField *maxFrequencyEntry;


- (void) updateDisplayWithResults:(FFTTAnalysisResults*)analysisResults;

- (void) registerAudioController:(FFTTAudioController*)audioController;

- (IBAction)backgroundTap:(id)sender;

- (IBAction)editedMinFrequency:(UITextField *)sender;

- (IBAction)editedMaxFrequency:(UITextField *)sender;

- (IBAction)toggledManualSwitch:(UISwitch *)sender;

@end
