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
    DSPSplitComplex         _windowedDataTime;
    DSPSplitComplex         _windowedDataFreq;
    DSPSplitComplex         _unwindowedDataTime;
    DSPSplitComplex         _unwindowedDataFreq;
    DSPSplitComplex         _powerSpectralDensity;
    DSPSplitComplex         _autoCorrelation;
    float                   *_freqDataMag;
    float                   *_freqDataLog;
    float                   *_differenceEqnInput;
    float                   *_differenceEqnTerms;
    float                   *_differenceEqnResult;
    float                   _differenceEqnSum;
    float                   _derivativeScaled;
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
    float           _derivativeScalingFactor;

    
    // test arrays
    float           _diffHistory[kPartials][kTestHistoryLength];
    //float           _testInharmFactor[kPartials];
    float           _testAcor[kRingBufferLength];

    // bounds for frequency detection
    float           _minimumAcorFrequency;
    float           _maximumAcorFrequency;

    // fundamental period estimate history
    int             _periodHistory[kMinContiguousFreq];
    int             _periodHistoryIndex;
    int             _periodEstimate;
    
    // bin calculation arrays
    float           _manualFrequency;
    float           _partialFreqEstimates[kPartials];
    float           _partialBinEstimates[kPartials];
    float           _partialBinEstimatesClipped[kPartials];
    int             _partialBinEstimatesNearest[kPartials];
    
    // partials history
    float           _partialsHistory[kPartials][kPartialHistoryLength];
    int             _partialHistoryIndex;
    float           _partialHistoryAverage[kPartials];
    
    // beat period calculation arrays
    int             _beatPeriodCounters[kPartials];
    int             _beatPeriodPrevious[kPartials];
    float           _absoluteFrequencies[kPartials];
    float           _impliedFrequencies[kPartials];
    
}

@end


@implementation FFTTAnalysisEngine

- (id) initWithAudioReceiver:(FFTTAudioReceiver *) receiver andResultsObject:(FFTTAnalysisResults *) results {
    if ( !(self = [super init]) ) return nil;
    
    // set receiver to get data from
    self.audioReceiver = receiver;
    
    // set analysis results object for sharing data
    self.analysisResults = results;

    // do initialisations for buffers
    self->_inputBufferHead = 0;
    self->_inputBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_orderedBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_windowedData = (float*)calloc(kRingBufferLength, sizeof(float));

    self->_windowedDataTime.realp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_windowedDataTime.imagp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_windowedDataFreq.realp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_windowedDataFreq.imagp = (float*)calloc(kRingBufferLength, sizeof(float));

    self->_unwindowedDataTime.realp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_unwindowedDataTime.imagp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_unwindowedDataFreq.realp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_unwindowedDataFreq.imagp = (float*)calloc(kRingBufferLength, sizeof(float));

    self->_powerSpectralDensity.realp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_powerSpectralDensity.imagp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_autoCorrelation.realp = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_autoCorrelation.imagp = (float*)calloc(kRingBufferLength, sizeof(float));

    self->_freqDataMag = (float*)calloc(kRingBufferLengthHalf, sizeof(float));
    self->_freqDataLog = (float*)calloc(kRingBufferLengthHalf, sizeof(float));

    self->_blackmanWindow = (float*)calloc(kRingBufferLength, sizeof(float));
    self->_flatTopWindow = (float*)calloc(kRingBufferLength, sizeof(float));

    // calculate precomputed factors

    self->_floatOne = 1.0;
    self->_floatZero = 0.0;
    self->_floatArrayLimit = kRingBufferLengthHalfFloat - 10.0;;
    self->_manualFrequency = kManualFrequency;
    self->_freqToBinFactor = kRingBufferLengthFloat/kFsFloat;
    self->_secondsPerFrame = kSamplesPerAnalysisWindowFloat/kFsFloat;
    self->_differenceEqnInput = (float*)calloc(kDiffEqnLength, sizeof(float));
    self->_differenceEqnTerms = (float*)calloc(kDiffEqnLength, sizeof(float));
    self->_differenceEqnResult = (float*)calloc(kDiffEqnLength, sizeof(float));
    float differenceEqnTermsFromDefine[] = kDiffEqnTerms;
    memcpy(self->_differenceEqnTerms, differenceEqnTermsFromDefine, kDiffEqnLength * sizeof(float));
    self->_derivativeScalingFactor = 1/kDiffEqnDenominator;
    //_fixedFrequency = kManualFrequency;
    
    self->_maximumAcorFrequency = kDefaultMaxAcorFrequency;
    self->_minimumAcorFrequency = kDefaultMinAcorFrequency;

    // initialise indexes
    self->_periodHistoryIndex = 0;
    self->_periodEstimate = 1;
    self->_partialHistoryIndex = 0;

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
    memcpy(_windowedDataTime.realp, _windowedData, kRingBufferLengthBytes);
    // perform FFT
    vDSP_fft_zop(_FFTSetup,&(_windowedDataTime),1,&(_windowedDataFreq),1,kLog2of8K,kFFTDirection_Forward);
    
    // convert to absolute magnitude, does not take square root, log(x) =  2*log(x^(1/2))
    vDSP_zvmags(&(_windowedDataFreq),1,_freqDataMag,1,kRingBufferLengthHalf);
    // using Power conversion factor 0, alpha=10, total scaling = 20x MATLAB results
    vDSP_vdbcon(_freqDataMag,1,&_floatOne,_freqDataLog,1,kRingBufferLengthHalf,0);
    
    
    // calculate signal autocorrelation from power IFFT

    // copy unwindowed signal to buffer
    memcpy( _unwindowedDataTime.realp, _orderedBuffer,kRingBufferLengthBytes);
    // perform FFT
    vDSP_fft_zop(_FFTSetup,&(_unwindowedDataTime),1,&(_unwindowedDataFreq),1,kLog2of8K,kFFTDirection_Forward);
    // take squared magnitude of spectrum to get PSD
    vDSP_zvmags(&(_unwindowedDataFreq),1,_powerSpectralDensity.realp,1,kRingBufferLength);
    // zero DC component of PSD
    _powerSpectralDensity.realp[0] = 0.0;
    // perform IFFT to generator autocorrelation
    vDSP_fft_zop(_FFTSetup,&(_powerSpectralDensity),1,&(_autoCorrelation),1,kLog2of8K,kFFTDirection_Inverse);
    // copy to test array
    memcpy( &(_testAcor), _autoCorrelation.realp,kRingBufferLengthBytes);

    // find peak of autocorrelation

    int minimumAcorPeriod = kFs/_maximumAcorFrequency;
    int maximumAcorPeriod = kFs/_minimumAcorFrequency;

    // zero out initial values (lowest periods)
    for (int i = 0; i < minimumAcorPeriod; i++)
    {
        _autoCorrelation.realp[i] = 0.0;
    }

    float acorMaxValue = 0.0;
    vDSP_Length acorMaxIndex = 1;
    // find maximum autocorrelation value
    vDSP_maxvi((_autoCorrelation.realp),1,&acorMaxValue,&acorMaxIndex,maximumAcorPeriod);

    // store index in rolling buffer to check for contiguity of estimate
    _periodHistory[_periodHistoryIndex] = acorMaxIndex;
    // increment index
    _periodHistoryIndex++;
    _periodHistoryIndex = (_periodHistoryIndex % kMinContiguousFreq);

    // check if all entries in rolling buffer are the same value
    BOOL bufferValuesIdentical = YES;
    for (int i = 0; i < kMinContiguousFreq; i++)
    {
        if (_periodHistory[i] != _periodHistory[(i+1)%kMinContiguousFreq])
        {
            bufferValuesIdentical = NO;
        }
    }

    // only update if number of identical estimates have been achieved
    if (bufferValuesIdentical == YES)
    {
        // only update if change is greater than 2 periods
        if ((acorMaxIndex != (_periodEstimate+2)) && (acorMaxIndex != (_periodEstimate+1)) 
            && (acorMaxIndex != (_periodEstimate-1)) && (acorMaxIndex != (_periodEstimate-2)) && (acorMaxIndex != minimumAcorPeriod))
        {
            _periodEstimate = acorMaxIndex;
        }
    }

    float frequencyEstimate = kFsFloat/((float) _periodEstimate);
    



    // calculate frequency bins
    for (int i = 0; i < kPartials; i++) {
        // use fixed harmonicity estimate 
        _partialFreqEstimates[i] = frequencyEstimate * (i+1) *
            sqrtf(1 + kManualInharmonicity*(powf((i+1), 2.0f)));
        _partialBinEstimates[i] = _partialFreqEstimates[i] * _freqToBinFactor;
        _partialBinEstimatesClipped[i] = MIN(_partialBinEstimates[i] , _floatArrayLimit);
        _partialBinEstimatesNearest[i] = roundf(_partialBinEstimatesClipped[i]);
    }
    
    // find beats
    for (int i = 0; i < kPartials; i++) {

        float averagedPartialHistory = 0;

        // shift partials history into past while adding to average
        for (int j = kPartialHistoryLength - 1; j > 0; j--) {
            _partialsHistory[i][j] = _partialsHistory[i][j-1];
            averagedPartialHistory += _partialsHistory[i][j-1];
        }
        // add latest sample to front
        _partialsHistory[i][0] = _freqDataLog[_partialBinEstimatesNearest[i]];

        // compute average and offset new sample
        float averaged = averagedPartialHistory/((float) kPartialHistoryLength);
        _derivativeScaled = _freqDataLog[_partialBinEstimatesNearest[i]] - averaged;
        
        // -- for debugging purposes --        
        // shift derivative history into past
        for (int j = kTestHistoryLength - 1; j > 0; j--) {
            _diffHistory[i][j] = _diffHistory[i][j-1];
        }
        // add latest sample to front
        _diffHistory[i][0] = _derivativeScaled;
        






        // increment period counter
        _beatPeriodCounters[i]++;
        
        // detect beat transitions
        if (_beatState[i]) {
            if (_derivativeScaled < kEdgeDetectDown)
                _beatState[i] = NO;
        }
        else {
            if (_derivativeScaled > kEdgeDetectUp){
                _beatState[i] = YES;
                float beatPeriodAverage = (_beatPeriodCounters[i] + _beatPeriodPrevious[i])/2;
                _absoluteFrequencies[i] = 1/(_secondsPerFrame * beatPeriodAverage);
                _impliedFrequencies[i] = 1/(_secondsPerFrame * beatPeriodAverage * (i+1));
//                _absoluteFrequencies[i] = 1/(_secondsPerFrame * _beatPeriodCounters[i]);
//                _impliedFrequencies[i] = 1/(_secondsPerFrame * _beatPeriodCounters[i] * (i+1));

                _beatPeriodPrevious[i] = _beatPeriodCounters[i];
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

    self.analysisResults.detectedFrequency = [NSNumber numberWithFloat:((float)frequencyEstimate)];

    
    // test to output period
    //[self.analysisResults.absoluteFrequencies replaceObjectAtIndex:(0) withObject:[NSNumber numberWithFloat:((float)_periodEstimate)]];
}


@end
