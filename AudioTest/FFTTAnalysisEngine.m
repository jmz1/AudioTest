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
    int         _inputBufferHead;
    float       *_orderedBuffer;
    
    // computation arrays
    float                   *_windowedData;
    DSPSplitComplex         _windowedDataComplex;
    DSPSplitComplex         _freqDataComplex;
    float                   *_freqDataMag;
    float                   *_freqDataLog;
    float                   *_differenceEqnInput;
    float                   *_differenceEqnTerms;
    float                   *_differenceEqnResult;
    float                   _differenceEqnSum;
    float                   _diffHistory[kPartials][kTestHistoryLength];
    
    
    // precomputed factors
    FFTSetup     _FFTSetup;
    float           *_blackmanWindow;
    float           _floatOne;
    float           _floatZero;
    float           _floatArrayLimit;
    float           _freqToBinFactor;

    
    // test arrays
    int           *_fftRealInt;
    
    // bin calculation arrays
    float           _manualFrequency;
    float           _partialFreqEstimates[kPartials];
    float           _partialBinEstimates[kPartials];
    float           _partialBinEstimatesClipped[kPartials];
    int             _partialBinEstimatesNearest[kPartials];
    
    // partials history
    float           _partialsHistory[kPartials][kDiffEqnLength];
    //float           _differenceEqnOutput[kPartials];
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
    self->_freqDataComplex.realp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_freqDataComplex.imagp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_freqDataMag = (float*)calloc(kRingBufferLengthHalf, sizeof(float));
    self->_freqDataLog = (float*)calloc(kRingBufferLengthHalf, sizeof(float));

    // allocate precomputed factors
    self->_blackmanWindow = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_floatOne = 1.0;
    self->_floatZero = 0.0;
    self->_floatArrayLimit = kRingBufferLengthHalfFloat - 10.0;;
    self->_manualFrequency = kManualFrequency;
    self->_freqToBinFactor = kRingBufferLengthFloat/kFsFloat;
    self->_differenceEqnInput = (float*)calloc(kDiffEqnLength, sizeof(float));
    self->_differenceEqnTerms = (float*)calloc(kDiffEqnLength, sizeof(float));
    self->_differenceEqnResult = (float*)calloc(kDiffEqnLength, sizeof(float));
    float differenceEqnTermsFromDefine[] = kDiffEqnTerms;
    memcpy(self->_differenceEqnTerms, differenceEqnTermsFromDefine, kDiffEqnLength * sizeof(float));
    
    // allocate test variables
    self->_fftRealInt = (int*)calloc(kRingBufferLength, sizeof(int));
    
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

    // straight multiplication with window function
    vDSP_vmul (_orderedBuffer, 1, _blackmanWindow, 1, _windowedData, 1, kRingBufferLength);

    // copy windowed data to real part of FFT buffer
    memcpy(self->_windowedDataComplex.realp, self->_windowedData, kRingBufferLengthBytes);
    // perform FFT
    vDSP_fft_zop(_FFTSetup,&(_windowedDataComplex),1,&(_freqDataComplex),1,kLog2of8K,kFFTDirection_Forward);
    // convert to absolute magnitude, does not take square root, log(x) =  2*log(x^(1/2))
    vDSP_zvmags(&(self->_freqDataComplex),1,self->_freqDataMag,1,kRingBufferLengthHalf);
    // using Power conversion factor 0, alpha=10, total scaling = 20x MATLAB results
    vDSP_vdbcon(self->_freqDataMag,1,&_floatOne,self->_freqDataLog,1,kRingBufferLengthHalf,0);
    
    
    // calculate frequency bins
    // create set of frequency estimates, just linearly extrapolated from fundamental for now
    vDSP_vramp(&_manualFrequency, &_manualFrequency, _partialFreqEstimates, 1, kPartials);
    // convert frequency to bin number
    vDSP_vsma(_partialFreqEstimates,1, &_freqToBinFactor,&_floatZero,1,_partialBinEstimates,1,kPartials);
    // limit to bounds of array
    vDSP_vclip(_partialBinEstimates,1,&_floatZero,&_floatArrayLimit,_partialBinEstimatesClipped,1,kPartials);
    // round to nearest integer bin
    vDSP_vfixr32 (_partialBinEstimatesClipped,1,_partialBinEstimatesNearest,1,kPartials);
    
    
    for (int i = 0; i < kPartials; i++) {
        // shift history bins 'right'
        for (int j = kDiffEqnLength - 1; j > 0; j--) {
            _partialsHistory[i][j] = _partialsHistory[i][j-1];
        }
        // add data to start of bin history
        _partialsHistory[i][0] = _freqDataLog[_partialBinEstimatesNearest[i]];
        // multiply history by difference equation
        memcpy(self->_differenceEqnInput, &(_partialsHistory[i][0]), kDiffEqnLength * sizeof(float));
        vDSP_vmul (self->_differenceEqnInput, 1, _differenceEqnTerms, 1, _differenceEqnResult, 1, kDiffEqnLength);
        //vDSP_vmul (&(_partialsHistory[i][0]), 1, _differenceEqnTerms, 1, _differenceEqnOutput, 1, kDiffEqnLength);
        // sum difference equation output
        vDSP_sve(_differenceEqnResult,1,&_differenceEqnSum,kDiffEqnLength);
        //vDSP_sve(_differenceEqnOutput,1,&_differenceEqnSum2,kDiffEqnLength);
        
        // shift derivative history 'right'
        for (int j = kTestHistoryLength - 1; j > 0; j--) {
            _diffHistory[i][j] = _diffHistory[i][j-1];
        }
        // add latest sample
        _diffHistory[i][0] = _differenceEqnSum;
    }
    
    
    // convert log magnitude to integer as test output
    vDSP_vfix32 (self->_freqDataLog,1,self->_fftRealInt,1,kRingBufferLength);
}

@end
