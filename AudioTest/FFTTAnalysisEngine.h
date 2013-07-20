//
//  FFTTAnalysisEngine.h
//  AudioTest
//
//  Created by James Ormrod on 20/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AnalysisDefines.h"
#import "FFTTAudioReceiver.h"

@class FFTTAudioReceiver;

@interface FFTTAnalysisEngine : NSObject

@property (assign) float minimumAcorFrequency;
@property (assign) float maximumAcorFrequency;

@property (nonatomic, retain) FFTTAudioReceiver *audioReceiver;
@property (nonatomic, retain) FFTTAnalysisResults *analysisResults;

- (id) initWithAudioReceiver:(FFTTAudioReceiver *) receiver andResultsObject:(FFTTAnalysisResults *) results;
- (void) runAnalysis;


@end
