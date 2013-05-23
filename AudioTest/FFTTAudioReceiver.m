//
//  FFTTAudioReceiver.m
//  AudioTest
//
//  Created by James Ormrod on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAudioReceiver.h"
#include <libkern/OSAtomic.h>

#import "AnalysisDefines.h"

@interface FFTTAudioReceiver () {
    float       *_ringBuffer;
    int          _ringBufferHead;
    int          _testCount;
    float        _testSample;
    dispatch_queue_t _analysisQueue;
    FFTTAudioController *_parentAudioController;
}

@end

@implementation FFTTAudioReceiver


- (id)initWithParentController:(FFTTAudioController *)parentAudioController {
    if ( !(self = [super init]) ) return nil;

    self->_ringBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_ringBufferHead = 0;
    
    self->_analysisQueue = dispatch_queue_create("Analysis Queue",NULL);
    self->_parentAudioController = parentAudioController;
    
    return self;
}

static void receiverCallbackFunction(id                        receiver,
                             AEAudioController        *audioController,
                             void                     *source,
                             const AudioTimeStamp     *time,
                             UInt32                    frames,
                             AudioBufferList          *audio) {

    // Do your thing
    FFTTAudioReceiver *THIS = (FFTTAudioReceiver*)receiver;

    
    // Get a pointer to the audio buffer that we can advance
    float *audioPtr = audio->mBuffers[0].mData;
    
    // Copy in contiguous segments, wrapping around if necessary
    int remainingFrames = frames;
    while ( remainingFrames > 0 ) {
        int framesToCopy = MIN(remainingFrames, kRingBufferLength - (THIS->_ringBufferHead / sizeof(float)));
        
        memcpy(THIS->_ringBuffer + THIS->_ringBufferHead, audioPtr, framesToCopy * sizeof(float));
        audioPtr += framesToCopy;
        
        int buffer_head = THIS->_ringBufferHead + (framesToCopy * sizeof(float));
        if ( buffer_head == kRingBufferLengthBytes ) buffer_head = 0;
        OSMemoryBarrier();
        THIS->_ringBufferHead = buffer_head;
        remainingFrames -= framesToCopy;
    }
    
    THIS->_testCount++;
    THIS->_testSample = THIS->_ringBuffer[0];
    
    // enqueue analysis
    // create block with: [THIS->_audioController triggerAnalysis];
    dispatch_async(dispatch_get_main_queue(), ^{
        [THIS->_parentAudioController triggerAnalysis];
    });
    
}

- (AEAudioControllerAudioCallback)receiverCallback {
    return &receiverCallbackFunction;
}

- (int) getTestCount {
    return _testCount;
}

- (float) getTestValue {
    return _testSample;
}

- (void) copyBufferData:(float *)destination bufferHeadPosition:(int *)bufferHead {
    *bufferHead = self->_ringBufferHead;
    memcpy(destination, self->_ringBuffer, kRingBufferLengthBytes);
}


@end