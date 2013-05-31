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


typedef struct analysisReturnStruct analysisReturnStruct_t;

struct analysisReturnStruct {
    BOOL    beatState[kPartials];
};



@property (nonatomic, retain) FFTTAudioReceiver *audioReceiver;



- (id) initWithAudioReceiver:(FFTTAudioReceiver *) receiver;

- (void) runAnalysis;

- (analysisReturnStruct_t) getResults;

@end
