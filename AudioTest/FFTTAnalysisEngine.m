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
    // input buffers
    float       *_inputBuffer;
    int          _inputBufferHead;
    float       *_orderedBuffer;
    
    // computation arrays
    float                   *_windowedData;
    DSPSplitComplex          _windowedDataComplex;

    
    // struct for precomputed FFT factors
    FFTSetup     _FFTSetup;
    // stored Blackmann window
    float         *_blackmanWindow;
}

@end


@implementation FFTTAnalysisEngine

- (id) initWithAudioReceiver:(FFTTAudioReceiver *) receiver{
    if ( !(self = [super init]) ) return nil;
    
    // set receiver to get data from
    self.audioReceiver = receiver;

    // do initialisations for buffers
    self->_inputBufferHead = 0;
    self->_inputBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_orderedBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_windowedData = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_windowedDataComplex.realp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_windowedDataComplex.imagp = (float*)calloc(kRingBufferLength, sizeof(float));
    
    self->_blackmanWindow = (float*)calloc(kRingBufferLength, sizeof(float));
    
    // do FFT initialisations
    _FFTSetup = vDSP_create_fftsetup( kLog2of16K, kFFTRadix2 );
    
    // create window
    vDSP_blkman_window (self->_blackmanWindow, kRingBufferLength, 0);
    
    return self;
}


- (void) runAnalysis{
    // copy data to local buffer
    [self.audioReceiver copyBufferData:_inputBuffer bufferHeadPosition:(&_inputBufferHead)];
    // reorder buffer oldest->newest
    int numSamplesUntilEnd = kRingBufferLength - _inputBufferHead;
    memcpy(self->_orderedBuffer, self->_inputBuffer + _inputBufferHead, numSamplesUntilEnd * sizeof(float));
    memcpy(self->_orderedBuffer + numSamplesUntilEnd, self->_inputBuffer, _inputBufferHead * sizeof(float));
//    memcpy(self->_orderedBuffer, _inputBuffer, kRingBufferLengthBytes);
    
    // cast _windowedData to (float *), set stride to 2 to set real parts only
    // NOT NEEDED for full complex FFT
    //vDSP_vmul (_orderedBuffer, 1, _blackmanWindow, 1, (float*) _windowedData, 2, kRingBufferLength);
    
    // straight multiplication with window function
    vDSP_vmul (_orderedBuffer, 1, _blackmanWindow, 1, _windowedData, 1, kRingBufferLength);

    // copy windowed data to real part of FFT buffer
    memcpy(self->_windowedDataComplex.realp, self->_windowedData, kRingBufferLengthBytes);
    
    
}

@end
