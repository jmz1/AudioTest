//
//  FFTTAudioController.h
//  AudioTest
//
//  Created by Daniel Clelland on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

#import "FFTTAudioReceiver.h"
#import "FFTTAnalysisEngine.h"

@class FFTTAudioReceiver;
@class FFTTAnalysisEngine;

@interface FFTTAudioController : NSObject

@property (nonatomic, retain) AEAudioController *audioController;
@property (nonatomic, retain) AEAudioFilePlayer *audioFilePlayer;
@property (nonatomic, retain) FFTTAudioReceiver *audioReceiver;
@property (nonatomic, retain) FFTTAnalysisEngine *analysisEngine;

- (void)start;
- (void)stop;

- (int)getARTestCount;
- (float)getARTestValue;

- (void) triggerAnalysis;

@end
