//
//  FFTTAudioController.h
//  AudioTest
//
//  Created by James Ormrod on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

#import "FFTTAudioReceiver.h"
#import "FFTTAnalysisEngine.h"
#import "FFTTViewController.h"

@class FFTTAudioReceiver;
@class FFTTAnalysisEngine;
@class FFTTViewController;

@interface FFTTAudioController : NSObject

@property (nonatomic, retain) AEAudioController *audioController;
@property (nonatomic, retain) FFTTViewController *viewController;
@property (nonatomic, retain) AEAudioFilePlayer *audioFilePlayer;
@property (nonatomic, retain) FFTTAudioReceiver *audioReceiver;
@property (nonatomic, retain) FFTTAnalysisEngine *analysisEngine;

- (id)initWithViewController:(FFTTViewController*)viewController;

- (void)start;
- (void)stop;

- (int)getARTestCount;
- (float)getARTestValue;

- (void) triggerAnalysis;

@end
