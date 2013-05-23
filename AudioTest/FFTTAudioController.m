//
//  FFTTAudioController.m
//  AudioTest
//
//  Created by James Ormrod on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAudioController.h"

#import "AnalysisDefines.h"

@implementation FFTTAudioController

- (id)init
{
    self = [super init];
    if (self) {
        // Set up the audio controller
        self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:YES];
        self.audioController.preferredBufferDuration = kSamplesPerWindowFloat / 44100.0 + 0.00001;
        
        // set up the sample player
        self.audioFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"Samples/A4d" withExtension:@"aiff"] audioController:self.audioController error:nil];
        self.audioFilePlayer.loop = true;
        self.audioFilePlayer.volume = 1.0;
        
        // set up the receiver
        self.audioReceiver = [[FFTTAudioReceiver alloc] initWithParentController:self];
        
        // set up analysis engine
        self.analysisEngine = [[FFTTAnalysisEngine alloc] initWithAudioReceiver:self.audioReceiver];
        
        // set up the channels (haven't finished doing this)
//        [self.audioController addInputReceiver:self.audioReceiver];
//        [self.audioController addOutputReceiver:self.audioReceiver];
        
        [self.audioController addInputReceiver:(id< AEAudioReceiver >) self.audioReceiver
                               forChannels:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]];

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

- (float)getARTestValue
{
    return [self.audioReceiver getTestValue];
}

- (void) triggerAnalysis{
    [self.analysisEngine runAnalysis];
}


@end
