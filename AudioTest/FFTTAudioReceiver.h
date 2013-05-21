//
//  FFTTAudioReceiver.h
//  AudioTest
//
//  Created by Daniel Clelland on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "FFTTAudioController.h"

@class FFTTAudioController;

@interface FFTTAudioReceiver : NSObject <AEAudioReceiver>

- (id)initWithParentController:(FFTTAudioController *) parentAudioController;

- (int) getTestCount;

- (float) getTestValue;


- (void) copyBufferData:(float *)destination bufferHeadPosition:(int *)bufferHead;

@end
