//
//  FFTTAudioReceiver.m
//  AudioTest
//
//  Created by Daniel Clelland on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAudioReceiver.h"

@implementation FFTTAudioReceiver

static void receiverCallback(id                        receiver,
                             AEAudioController        *audioController,
                             void                     *source,
                             const AudioTimeStamp     *time,
                             UInt32                    frames,
                             AudioBufferList          *audio) {

    // Do your thing
    
//    FFTTAudioHandler *THIS = (FFTTAudioReceiver *)receiver;
//    
//    // convert incoming data to floating point
//    AEFloatConverterToFloatBufferList(THIS->_floatConverter, audio, THIS->_conversionBuffer, frames);
//    
//    // Get a pointer to the audio buffer that we can advance
//    float *audioPtr = THIS->_conversionBuffer->mBuffers[0].mData;
//    
//    // Copy in contiguous segments, wrapping around if necessary
//    int remainingFrames = frames;
//    while ( remainingFrames > 0 ) {
//        int framesToCopy = MIN(remainingFrames, kRingBufferLength - THIS->_ringBufferHead);
//        
//        memcpy(THIS->_ringBuffer + THIS->_ringBufferHead, audioPtr, framesToCopy * sizeof(float));
//        audioPtr += framesToCopy;
//        
//        int buffer_head = THIS->_ringBufferHead + framesToCopy;
//        if ( buffer_head == kRingBufferLength ) buffer_head = 0;
//        OSMemoryBarrier();
//        THIS->_ringBufferHead = buffer_head;
//        remainingFrames -= framesToCopy;
//    }
}

- (AEAudioControllerAudioCallback)receiverCallback {
    return &receiverCallback;
}

@end