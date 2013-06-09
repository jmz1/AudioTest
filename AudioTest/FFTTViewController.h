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

@property (weak, nonatomic) IBOutlet UITextField *frequencyEntry;

- (void) updateDisplayWithResults:(FFTTAnalysisResults*)analysisResults;

- (void) registerAudioController:(FFTTAudioController*)audioController;

- (IBAction)backgroundTap:(id)sender;

- (IBAction)editedFrequency:(UITextField *)sender;

@end
