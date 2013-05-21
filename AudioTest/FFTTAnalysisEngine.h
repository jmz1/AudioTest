//
//  FFTTAnalysisEngine.h
//  AudioTest
//
//  Created by James Ormrod on 20/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FFTTAudioReceiver.h"

@class FFTTAudioReceiver;

@interface FFTTAnalysisEngine : NSObject

@property (nonatomic, retain) FFTTAudioReceiver *audioReceiver;

- (id) initWithAudioReceiver:(FFTTAudioReceiver *) receiver;

- (void) runAnalysis;

@end
