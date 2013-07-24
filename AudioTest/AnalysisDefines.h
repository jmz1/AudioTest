//
//  AnalysisDefines.h
//  AudioTest
//
//  Created by James Ormrod on 20/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

// TODO: flag for manual frequency selection replacing lower bounding

#ifndef AudioTest_AnalysisDefines_h
#define AudioTest_AnalysisDefines_h

#define kBoolUseSamples				TRUE

#define kPartials 					6

#define kManualFrequency            220.0
//#define kManualFrequency            58.27

#define kManualInharmonicity        0.00013

#define kRingBufferLength           	8192
#define kRingBufferLengthFloat      	8192.0
#define kRingBufferLengthHalf       	4096
#define kRingBufferLengthHalfFloat  	4096.0
#define kRingBufferLengthBytes 			(kRingBufferLength * sizeof(float))
#define kRingBufferLengthDouble     	(kRingBufferLength * 2)
#define kRingBufferLengthDoubleBytes    (kRingBufferLength * 2 * sizeof(float))

#define kSamplesPerAudioCallback       	512
#define kSamplesPerAudioCallbackFloat  	512.0

#define kSamplesPerAnalysisWindow      	128
#define kSamplesPerAnalysisWindowFloat 	128.0

// needs to be ratio of kSamplesPerAudioCallback/kSamplesPerAnalysisWindow
#define kBufferAnalysisMultiple         4

#define kLog2of16K 					14
#define kLog2of8K  					13

#define kFs         				44100
#define kFsFloat    				44100.0

// 1 8 27 48 42

//# define kDiffEqnLength 			11
//# define kDiffEqnTerms  {1.0, 8.0, 27.0, 48.0, 42.0, 0, -42.0, -48.0, -27.0, -8.0, -1.0}
//# define kDiffEqnDenominator         512.0

#define kDefaultMinAcorFrequency	200
#define kDefaultMaxAcorFrequency	4000

#define kMinContiguousFreq			25

#define kPartialHistoryLength		200

#define kDiffEqnLength 			19
#define kDiffEqnTerms  {1.0, 16.0, 119.0, 544.0, 1700.0, 3808.0, 6188.0, 7072.0, 4862.0, 0, -4862.0, -7072.0, -6188.0, -3808.0, -1700.0, -544.0, -119.0, -16.0, -1.0}
#define kDiffEqnDenominator         131072.0


#define kTestHistoryLength  		200

#define kEdgeDetectUp       		-0.04
#define kEdgeDetectDown     		-0.08

//#define kEdgeDetectUp       		1.0
//#define kEdgeDetectDown     		0.0

#endif
