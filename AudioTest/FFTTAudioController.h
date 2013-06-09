//
//  FFTTAudioController.h
//  AudioTest
//
//  Created by James Ormrod on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>


@class FFTTAudioReceiver;
@class FFTTAnalysisEngine;
@class FFTTViewController;
@class FFTTAnalysisResults;

@interface FFTTAudioController : NSObject

@property (nonatomic, retain) AEAudioController *audioController;
@property (nonatomic, retain) FFTTViewController *viewController;
@property (nonatomic, retain) AEAudioFilePlayer *audioFilePlayer;
@property (nonatomic, retain) FFTTAudioReceiver *audioReceiver;
@property (nonatomic, retain) FFTTAnalysisEngine *analysisEngine;
@property (nonatomic, retain) FFTTAnalysisResults *analysisResults;

- (id)initWithViewController:(FFTTViewController*)viewController;

- (void)start;
- (void)stop;

- (int)getARTestCount;


- (void) triggerAnalysis;

- (void) updateAnalysisEngineFrequency:(float) newFrequency;

@end
