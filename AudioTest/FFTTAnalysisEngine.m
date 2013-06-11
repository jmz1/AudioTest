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
#import "FFTTAnalysisResults.h"


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
    BOOL                    _beatState[kPartials];
    
    
    // precomputed factors
    FFTSetup     _FFTSetup;
    float           *_blackmanWindow;
    float           *_flatTopWindow;
    float           _floatOne;
    float           _floatZero;
    float           _floatArrayLimit;
    float           _freqToBinFactor;
    float           _secondsPerFrame;

    
    // test arrays
    float           _diffHistory[kPartials][kTestHistoryLength];
    //float           _testInharmFactor[kPartials];
    
    // bin calculation arrays
    float           _manualFrequency;
    float           _partialFreqEstimates[kPartials];
    float           _partialBinEstimates[kPartials];
    float           _partialBinEstimatesClipped[kPartials];
    int             _partialBinEstimatesNearest[kPartials];
    
    // partials history
    float           _partialsHistory[kPartials][kDiffEqnLength];
    
    // beat period calculation arrays
    int             _beatPeriodCounters[kPartials];
    float           _absoluteFrequencies[kPartials];
    float           _impliedFrequencies[kPartials];
    
}

@end


@implementation FFTTAnalysisEngine

- (id) initWithAudioReceiver:(FFTTAudioReceiver *) receiver andResultsObject:(FFTTAnalysisResults *) results {
    if ( !(self = [super init]) ) return nil;
    
    // set receiver to get data from
    self.audioReceiver = receiver;
    
    // set receiver to get data from
    self.analysisResults = results;

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
    self->_flatTopWindow = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_floatOne = 1.0;
    self->_floatZero = 0.0;
    self->_floatArrayLimit = kRingBufferLengthHalfFloat - 10.0;;
    self->_manualFrequency = kManualFrequency;
    self->_freqToBinFactor = kRingBufferLengthFloat/kFsFloat;
    self->_secondsPerFrame = kSamplesPerWindowFloat/kFsFloat;
    self->_differenceEqnInput = (float*)calloc(kDiffEqnLength, sizeof(float));
    self->_differenceEqnTerms = (float*)calloc(kDiffEqnLength, sizeof(float));
    self->_differenceEqnResult = (float*)calloc(kDiffEqnLength, sizeof(float));
    float differenceEqnTermsFromDefine[] = kDiffEqnTerms;
    memcpy(self->_differenceEqnTerms, differenceEqnTermsFromDefine, kDiffEqnLength * sizeof(float));
    _fixedFrequency = kManualFrequency;
    
    // do FFT initialisations
    _FFTSetup = vDSP_create_fftsetup( kLog2of16K, kFFTRadix2 );
    
    // create window
    vDSP_blkman_window (self->_blackmanWindow, kRingBufferLength, 0);
    
    for (int i = 0; i < kRingBufferLength; i++) {
        _flatTopWindow[i] = 1
        - 1.93*cosf(M_2_PI*i/kRingBufferLengthFloat)
        + 1.29*cos(2.0*M_2_PI*i/kRingBufferLengthFloat)
        - 0.388*cos(4.0*M_2_PI*i/kRingBufferLengthFloat)
        + 0.028*cos(6.0*M_2_PI*i/kRingBufferLengthFloat);
    }
    
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
    //vDSP_vmul (_orderedBuffer, 1, _blackmanWindow, 1, _windowedData, 1, kRingBufferLength);
    vDSP_vmul (_orderedBuffer, 1, _flatTopWindow, 1, _windowedData, 1, kRingBufferLength);

    // copy windowed data to real part of FFT buffer
    memcpy(_windowedDataComplex.realp, _windowedData, kRingBufferLengthBytes);
    // perform FFT
    vDSP_fft_zop(_FFTSetup,&(_windowedDataComplex),1,&(_freqDataComplex),1,kLog2of8K,kFFTDirection_Forward);
    
    // convert to absolute magnitude, does not take square root, log(x) =  2*log(x^(1/2))
    vDSP_zvmags(&(_freqDataComplex),1,_freqDataMag,1,kRingBufferLengthHalf);
    // using Power conversion factor 0, alpha=10, total scaling = 20x MATLAB results
    vDSP_vdbcon(_freqDataMag,1,&_floatOne,_freqDataLog,1,kRingBufferLengthHalf,0);
    
    
    
    // calculate frequency bins
    for (int i = 0; i < kPartials; i++) {
        // use fixed harmonicity estimate 
        _partialFreqEstimates[i] = _fixedFrequency * (i+1) *
            sqrtf(1 + kManualInharmonicity*(powf((i+1), 2.0f)));
        _partialBinEstimates[i] = _partialFreqEstimates[i] * _freqToBinFactor;
        _partialBinEstimatesClipped[i] = MIN(_partialBinEstimates[i] , _floatArrayLimit);
        _partialBinEstimatesNearest[i] = roundf(_partialBinEstimatesClipped[i]);
    }
    
    // find beats
    for (int i = 0; i < kPartials; i++) {
        // shift history bins into past
        for (int j = kDiffEqnLength - 1; j > 0; j--) {
            _partialsHistory[i][j] = _partialsHistory[i][j-1];
        }
        // add data to start of bin history
        _partialsHistory[i][0] = _freqDataLog[_partialBinEstimatesNearest[i]];
        
        // multiply history by difference equation
        memcpy(_differenceEqnInput, &(_partialsHistory[i][0]), kDiffEqnLength * sizeof(float));
        vDSP_vmul (_differenceEqnInput, 1, _differenceEqnTerms, 1, _differenceEqnResult, 1, kDiffEqnLength);
        // sum difference equation output to get derivative
        vDSP_sve(_differenceEqnResult,1,&_differenceEqnSum,kDiffEqnLength);
        
        // shift derivative history into past
        for (int j = kTestHistoryLength - 1; j > 0; j--) {
            _diffHistory[i][j] = _diffHistory[i][j-1];
        }
        // add latest sample to front
        _diffHistory[i][0] = _differenceEqnSum;
        
        // increment period counter
        _beatPeriodCounters[i]++;
        
        // detect beat transitions
        if (_beatState[i]) {
            if (_differenceEqnSum < kEdgeDetectDown)
                _beatState[i] = NO;
        }
        else {
            if (_differenceEqnSum > kEdgeDetectUp){
                _beatState[i] = YES;
                _absoluteFrequencies[i] = 1/(_secondsPerFrame * _beatPeriodCounters[i]);
                _impliedFrequencies[i] = 1/(_secondsPerFrame * _beatPeriodCounters[i] * (i+1));
                _beatPeriodCounters[i] = 0;
            }
        }
    }
    
    
    
    // add beat states to results object
    for (int i = 0; i < kPartials; i++) {
        [self.analysisResults.beatStates replaceObjectAtIndex:(i) withObject:[NSNumber numberWithBool:(_beatState[i])]];
        [self.analysisResults.impliedFrequencies replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:(_impliedFrequencies[i])]];
        [self.analysisResults.absoluteFrequencies replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:(_absoluteFrequencies[i])]];
    }
}


@end
