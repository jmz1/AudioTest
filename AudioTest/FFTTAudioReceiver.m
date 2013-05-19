//
//  FFTTAudioReceiver.m
//  AudioTest
//
//  Created by Daniel Clelland on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAudioReceiver.h"
#include <libkern/OSAtomic.h>

#define kRingBufferLength 8192

@interface FFTTAudioReceiver () {
    float       *_ringBuffer;
    int          _ringBufferHead;
}

@end

@implementation FFTTAudioReceiver


- (id)init {
    if ( !(self = [super init]) ) return nil;

    self->_ringBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_ringBufferHead = 0;
    
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
        if ( buffer_head == (kRingBufferLength * sizeof(float)) ) buffer_head = 0;
        OSMemoryBarrier();
        THIS->_ringBufferHead = buffer_head;
        remainingFrames -= framesToCopy;
    }
}

- (AEAudioControllerAudioCallback)receiverCallback {
    return &receiverCallbackFunction;
}

@end