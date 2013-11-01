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
    int         _ringBufferHead;
    float       *_newSamplesBuffer;
    int         _newSamplesHead;
    int         _testCount;
    FFTTAudioController *_parentAudioController;
}

@end

@implementation FFTTAudioReceiver


- (id)initWithParentController:(FFTTAudioController *)parentAudioController {
    if ( !(self = [super init]) ) return nil;
    
    self->_ringBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_ringBufferHead = 0;
    
    self->_newSamplesBuffer = (float*)calloc(kSamplesPerAudioCallback, sizeof(float));
    self->_ringBufferHead = 0;
    
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
        
    // copy all new samples
    memcpy(THIS->_newSamplesBuffer, audioPtr, kSamplesPerAudioCallback * sizeof(float));
    THIS->_newSamplesHead = 0;
    
    THIS->_testCount++;
    
    // enqueue analysis
    // create block with: [THIS->_audioController triggerAnalysis];
    dispatch_async(dispatch_get_main_queue(), ^{
        [THIS->_parentAudioController triggerAnalysis];
    });
    
}

- (void) feedNewSamples {
    // Copy in contiguous segments, wrapping around if necessary

    //int framesToCopy = MIN(remainingFrames, kRingBufferLength - (_ringBufferHead));
    memcpy(_ringBuffer + _ringBufferHead,
           _newSamplesBuffer + _newSamplesHead, kSamplesPerAnalysisWindow * sizeof(float));
    // increment new samples buffer head
    _newSamplesHead += kSamplesPerAnalysisWindow;
    // wrap around buffer head position
    int buffer_head = _ringBufferHead + kSamplesPerAnalysisWindow;
    if ( buffer_head == kRingBufferLength ) buffer_head = 0;
    _ringBufferHead = buffer_head;

}

- (AEAudioControllerAudioCallback)receiverCallback {
    return &receiverCallbackFunction;
}

- (int) getTestCount {
    return _testCount;
}

- (void) copyBufferData:(float *)destination bufferHeadPosition:(int *)bufferHead {
    //NSLog(@"%d",self->_ringBufferHead);
    *bufferHead = self->_ringBufferHead;
    memcpy(destination, self->_ringBuffer, kRingBufferLengthBytes);
}

// 1. feed some samples from newSamples into main buffer
// 2. call copyBufferData as normal

@end