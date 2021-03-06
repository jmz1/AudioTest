//
//  FFTTAudioController.m
//  AudioTest
//
//  Created by James Ormrod on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAudioController.h"

#import "AnalysisDefines.h"
#import "FFTTAudioReceiver.h"
#import "FFTTAnalysisEngine.h"
#import "FFTTViewController.h"
#import "FFTTAnalysisResults.h"


@implementation FFTTAudioController

- (id)initWithViewController:(FFTTViewController *)viewController
{
    self = [super init];
    if (self) {
        // set view controller
        self.viewController = viewController;
        
        // Set up the audio controller
        self.audioController = [[AEAudioController alloc] 
            initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:YES];
        self.audioController.preferredBufferDuration = kSamplesPerAudioCallbackFloat / kFsFloat + 0.00001;
        
        [self.audioController stop];
        
        // set up the sample player
        self.audioFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] 
            URLForResource:@"Samples/A3d" withExtension:@"aiff"] audioController:self.audioController error:nil];

        self.audioFilePlayer.loop = true;
        self.audioFilePlayer.volume = 1.0;
        
        // set up the receiver
        self.audioReceiver = [[FFTTAudioReceiver alloc] initWithParentController:self];
        
        // set up object for analysis results passing
        self.analysisResults = [[FFTTAnalysisResults alloc] init];
        
        // set up analysis engine
        self.analysisEngine = [[FFTTAnalysisEngine alloc] 
            initWithAudioReceiver:self.audioReceiver andResultsObject:self.analysisResults];
        
        BOOL usingSamples = kBoolUseSamples;
        
        if (usingSamples == TRUE) {
            // to play audio file as output
            [self.audioController addChannels:[NSArray arrayWithObjects:self.audioFilePlayer, nil]];
            
            // to add receiver for output
            [self.audioController addOutputReceiver:(id< AEAudioReceiver >) self.audioReceiver 
                forChannel:self.audioFilePlayer];
            
        }
        else {
            // to add receiver for mic input
            [self.audioController addInputReceiver:(id< AEAudioReceiver >) self.audioReceiver 
                forChannels:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]];
        }


        [self.audioController start:nil];
    }
    return self;
}

- (void)start
{
    NSError *error;
    if (![_audioController start:&error]) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (void)stop
{
    [_audioController stop];
}

- (int)getARTestCount
{
    return [self.audioReceiver getTestCount];
}


- (void) triggerAnalysis{
    // run analysis number of times equal to buffer oversampling
    for (int i = 0; i<kBufferAnalysisMultiple; i++) {
        [self.analysisEngine runAnalysis];
    }
    [self.viewController updateDisplayWithResults:self.analysisResults];
}


- (void) updateAnalysisEngineMaxDetectFrequency:(float) newMaxFrequency{
    self.analysisEngine.maximumAcorFrequency = newMaxFrequency;
}

- (void) updateAnalysisEngineMinDetectFrequency:(float) newMinFrequency{
    self.analysisEngine.minimumAcorFrequency = newMinFrequency;
}

- (void) setManualFrequencyState:(BOOL)manualFrequencyState{
    self.analysisEngine.manualFrequencyState = manualFrequencyState;
}


@end
