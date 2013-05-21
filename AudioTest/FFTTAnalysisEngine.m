//
//  FFTTAnalysisEngine.m
//  AudioTest
//
//  Created by James Ormrod on 20/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAnalysisEngine.h"

#import <Accelerate/Accelerate.h> 

#import "AnalysisDefines.h"
#import "FFTTAudioReceiver.h"


@interface FFTTAnalysisEngine() {
    float       *_inputBuffer;
    int          _inputBufferHead;
    float       *_orderedBuffer;
}

@end


@implementation FFTTAnalysisEngine

- (id) initWithAudioReceiver:(FFTTAudioReceiver *) receiver{
    if ( !(self = [super init]) ) return nil;
    
    // set receiver to get data from
    self.audioReceiver = receiver;

    // do initialisations for buffers
    self->_inputBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_inputBufferHead = 0;
    self->_orderedBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    
    return self;
}


- (void) runAnalysis{
    // copy data to local buffer
    [self.audioReceiver copyBufferData:_inputBuffer bufferHeadPosition:(&_inputBufferHead)];
    // reorder buffer oldest->newest
    int numBytesUntilEnd = kRingBufferLengthBytes - _inputBufferHead;
    memcpy(_orderedBuffer, _inputBuffer + _inputBufferHead, numBytesUntilEnd);
    memcpy(_orderedBuffer + numBytesUntilEnd, _inputBuffer, _inputBufferHead);

}

@end
