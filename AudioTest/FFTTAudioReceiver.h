//
//  FFTTAudioReceiver.h
//  AudioTest
//
//  Created by James Ormrod on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "FFTTAudioController.h"

@class FFTTAudioController;

@interface FFTTAudioReceiver : NSObject <AEAudioReceiver>

- (id)initWithParentController:(FFTTAudioController *) parentAudioController;

- (int) getTestCount;

- (void) feedNewSamples;

- (void) copyBufferData:(float *)destination bufferHeadPosition:(int *)bufferHead;

@end
