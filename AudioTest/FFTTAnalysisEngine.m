//
//  FFTTAnalysisEngine.m
//  AudioTest
//
//  Created by James Ormrod on 20/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAnalysisEngine.h"

#import <Accelerate/Accelerate.h>
#import <complex.h>

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
    //float                   *_differenceEqnInput;
    //float                   *_differenceEqnTerms;
    //float                   *_differenceEqnResult;
    //float                   _differenceEqnSum;
    //float                   _derivativeScaled;
    //BOOL                    _beatState[kPartials];
    
    
    // precomputed factors
    FFTSetup        _FFTSetup;
    float           *_blackmanWindow;
    float           *_flatTopWindow;
    float           _floatOne;
    float           _floatZero;
    float           _floatArrayLimit;
    float           _freqToBinFactor;
    float           _secondsPerFrame;
    //float           _derivativeScalingFactor;
    double           _radiansPerFrame;

    
    // test arrays
    //float           _diffHistory[kPartials][kTestHistoryLength];
    //float           _testInharmFactor[kPartials];
    
    float           _testArrayReal[kUnwrappedPadLength];
    float           _testArrayImag[kUnwrappedPadLength];
    float           _testArrayAbs[kUnwrappedPadLength];
    
    // bin calculation arrays
    float           _manualFrequency;
    float           _partialFreqEstimates[kPartials];
    float           _partialBinEstimates[kPartials];
    float           _partialBinEstimatesClipped[kPartials];
    int             _partialBinEstimatesNearest[kPartials];
    
    // partials history
    //float           _partialsHistory[kPartials][kDiffEqnLength];
    
    // beat period calculation arrays
    //int             _beatPeriodCounters[kPartials];
    //int             _beatPeriodPrevious[kPartials];
    float           _absoluteFrequencies[kPartials];
    float           _impliedFrequencies[kPartials];
    
    
    // NEW STUFF FOR FREQ DOMAIN BEAT CALCULATION
    float           _partialComplexHistoryReal[kPartials][kComplexHistoryLength];
    float           _partialComplexHistoryImag[kPartials][kComplexHistoryLength];
    int             _partialComplexHistoryHead;
    DSPSplitComplex _unwrappedDataPaddedTime;
    DSPSplitComplex _unwrappedDataPaddedFreq;
    float           *_unwrappedFreqAbs;
    
    // persistent phase unwrapping terms
    double           _phaseUnwrapTerm[kPartials];
    
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
    self->_floatArrayLimit = kRingBufferLengthHalfFloat - 10.0;
    self->_manualFrequency = kManualFrequency;
    self->_freqToBinFactor = kRingBufferLengthFloat/kFsFloat;
    self->_secondsPerFrame = kSamplesPerAnalysisWindowFloat/kFsFloat;
    //self->_differenceEqnInput = (float*)calloc(kDiffEqnLength, sizeof(float));
    //self->_differenceEqnTerms = (float*)calloc(kDiffEqnLength, sizeof(float));
    //self->_differenceEqnResult = (float*)calloc(kDiffEqnLength, sizeof(float));
    //float differenceEqnTermsFromDefine[] = kDiffEqnTerms;
    //memcpy(self->_differenceEqnTerms, differenceEqnTermsFromDefine, kDiffEqnLength * sizeof(float));
    //self->_derivativeScalingFactor = 1/kDiffEqnDenominator;
    self->_fixedFrequency = kManualFrequency;
    self->_radiansPerFrame = ((double) kSamplesPerAnalysisWindowFloat*M_PI*2.0)/((double)kRingBufferLengthFloat);
    
    // do FFT initialisations
    _FFTSetup = vDSP_create_fftsetup( kLog2of16K, kFFTRadix2 );
    
    // create window
    vDSP_blkman_window (self->_blackmanWindow, kRingBufferLength, 0);
    
    for (int i = 0; i < kRingBufferLength; i++) {
        _flatTopWindow[i] = 1
        - 1.93*cosf(2.0*M_PI*i/kRingBufferLengthFloat)
        + 1.29*cos(2.0*2.0*M_PI*i/kRingBufferLengthFloat)
        - 0.388*cos(4.0*2.0*M_PI*i/kRingBufferLengthFloat)
        + 0.028*cos(6.0*2.0*M_PI*i/kRingBufferLengthFloat);
    }
    
    // allocate phase-unwrapped analysis buffers
    self->_unwrappedDataPaddedTime.realp = (float*)calloc(kUnwrappedPadLength, sizeof(float));
    self->_unwrappedDataPaddedTime.imagp = (float*)calloc(kUnwrappedPadLength, sizeof(float));
    
    self->_unwrappedDataPaddedFreq.realp = (float*)calloc(kUnwrappedPadLength, sizeof(float));
    self->_unwrappedDataPaddedFreq.imagp = (float*)calloc(kUnwrappedPadLength, sizeof(float));
    
    self->_unwrappedFreqAbs = (float*)calloc(kUnwrappedPadLength, sizeof(float));
    
    
    return self;
}


- (void) runAnalysis{
    // feed new samples to main buffer
    [self.audioReceiver feedNewSamples];
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
    //vDSP_zvmags(&(_freqDataComplex),1,_freqDataMag,1,kRingBufferLengthHalf);
    // using Power conversion factor 0, alpha=10, total scaling = 20x MATLAB results
    //vDSP_vdbcon(_freqDataMag,1,&_floatOne,_freqDataLog,1,kRingBufferLengthHalf,0);
    
    
    
    // calculate frequency bins
    for (int i = 0; i < kPartials; i++) {
        // use fixed harmonicity estimate 
        _partialFreqEstimates[i] = _fixedFrequency * (i+1) *
            sqrtf(1 + kManualInharmonicity*(powf((i+1), 2.0f)));
        _partialBinEstimates[i] = _partialFreqEstimates[i] * _freqToBinFactor;
        _partialBinEstimatesClipped[i] = MIN(_partialBinEstimates[i] , _floatArrayLimit);
        _partialBinEstimatesNearest[i] = roundf(_partialBinEstimatesClipped[i]);
        // modification to give sub-nearest bin and thus sufficient distance
        _partialBinEstimatesNearest[i] = _partialBinEstimatesNearest[i] - 1;
    }
    
    // find beats
    for (int i = 0; i < kPartials; i++) {
        // perform phase unwrapping
        
        // get partials terms used
        double newReal = _freqDataComplex.realp[_partialBinEstimatesNearest[i]];
        double newImag = _freqDataComplex.imagp[_partialBinEstimatesNearest[i]];
        
        // construct complex number
        _Complex double newComplexValue = newReal + _Complex_I * newImag;
        
        // convert to magnitude/phase
        double   mag = cabs(newComplexValue);
        double   angle = carg(newComplexValue);
        
        // add phase term in proportion to frequency bin used, and take modulus to keep in (0,M_2_PI)
        _phaseUnwrapTerm[i] = _phaseUnwrapTerm[i] + _radiansPerFrame * ((double) _partialBinEstimatesNearest[i]);
        _phaseUnwrapTerm[i] = fmod(_phaseUnwrapTerm[i], (M_PI*2.0));
        
        // subtract phase
        double angleUnwrapped = angle - _phaseUnwrapTerm[i];
        //float angleUnwrapped = angle;
        
        // return to polar form
        double shiftedReal = mag * cos(angleUnwrapped);
        double shiftedImag = mag * sin(angleUnwrapped);
        
        // add frequency domain data to partials history
        _partialComplexHistoryReal[i][_partialComplexHistoryHead] = shiftedReal;
        _partialComplexHistoryImag[i][_partialComplexHistoryHead] = shiftedImag;
        
        // reorder and add to padded buffers
        // pre-advance buffer head (cannot advance persistent head yet due to multiple partials using this to write)
        int _partialComplexHistoryHeadAdvanced = (_partialComplexHistoryHead+1) % kComplexHistoryLength;
        // data point at _partialComplexHistoryHead is newest sample, belongs at end
        int numUnwrappedSamplesUntilEnd = kComplexHistoryLength - _partialComplexHistoryHeadAdvanced;
        // add oldest data at start
        memcpy(_unwrappedDataPaddedTime.realp, self->_partialComplexHistoryReal[i] + _partialComplexHistoryHeadAdvanced, 
            numUnwrappedSamplesUntilEnd * sizeof(float));
        memcpy(_unwrappedDataPaddedTime.imagp, self->_partialComplexHistoryImag[i] + _partialComplexHistoryHeadAdvanced, 
            numUnwrappedSamplesUntilEnd * sizeof(float));
        // add newest data to end
        memcpy(_unwrappedDataPaddedTime.realp + numUnwrappedSamplesUntilEnd, self->_partialComplexHistoryReal[i], 
            _partialComplexHistoryHeadAdvanced * sizeof(float));
        memcpy(_unwrappedDataPaddedTime.imagp + numUnwrappedSamplesUntilEnd, self->_partialComplexHistoryImag[i], 
            _partialComplexHistoryHeadAdvanced * sizeof(float));

        
        // take FFT of history
        vDSP_fft_zop(_FFTSetup,&(_unwrappedDataPaddedTime),1,&(_unwrappedDataPaddedFreq),1,kLog2ofUnwrappedPadLength,kFFTDirection_Forward);
        
        // convert to absolute magnitude
        vDSP_zvabs (&(_unwrappedDataPaddedFreq),1,_unwrappedFreqAbs,1,kUnwrappedPadLength);

        // copy to test array
        memcpy(_testArrayReal,_unwrappedDataPaddedFreq.realp,kUnwrappedPadLength);
        memcpy(_testArrayImag,_unwrappedDataPaddedFreq.imagp,kUnwrappedPadLength);
        memcpy(_testArrayAbs,_unwrappedFreqAbs,kUnwrappedPadLength);
        int blarg = 0;
    }
    
    // increment complex write head, wrapping around
    _partialComplexHistoryHead++;
    _partialComplexHistoryHead = _partialComplexHistoryHead % kComplexHistoryLength;
    
    
    
    
    // add beat states to results object
    for (int i = 0; i < kPartials; i++) {
        //[self.analysisResults.beatStates replaceObjectAtIndex:(i) withObject:[NSNumber numberWithBool:(_beatState[i])]];
        [self.analysisResults.impliedFrequencies replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:(_impliedFrequencies[i])]];
        [self.analysisResults.absoluteFrequencies replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:(_absoluteFrequencies[i])]];
    }
}


@end
