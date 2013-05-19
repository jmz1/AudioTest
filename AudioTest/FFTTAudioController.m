//
//  FFTTAudioController.m
//  AudioTest
//
//  Created by Daniel Clelland on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAudioController.h"

@implementation FFTTAudioController

- (id)init
{
    self = [super init];
    if (self) {
        // Set up the audio controller
        self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:YES];
        self.audioController.preferredBufferDuration = 1024.0 / 44100.0;
        
        // set up the sample player
        self.audioFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"Samples/A4d" withExtension:@"aiff"] audioController:self.audioController error:nil];
        self.audioFilePlayer.loop = true;
        self.audioFilePlayer.volume = 1.0;
        
        // set up the receiver
        self.audioReceiver = [[FFTTAudioReceiver alloc] init];
        
        // set up the channels (haven't finished doing this)
//        [self.audioController addInputReceiver:self.audioReceiver];
//        [self.audioController addOutputReceiver:self.audioReceiver];
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

@end
