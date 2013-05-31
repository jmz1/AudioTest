//
//  AnalysisDefines.h
//  AudioTest
//
//  Created by James Ormrod on 20/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#ifndef AudioTest_AnalysisDefines_h
#define AudioTest_AnalysisDefines_h

#define kManualFrequency            440.0

#define kRingBufferLength           8192
#define kRingBufferLengthFloat      8192.0
#define kRingBufferLengthHalf       4096
#define kRingBufferLengthHalfFloat  4096.0
#define kRingBufferLengthBytes (kRingBufferLength * sizeof(float))

#define kSamplesPerWindow       512
#define kSamplesPerWindowFloat  512.0

#define kLog2of16K 14
#define kLog2of8K  13

#define kPartials 10

#define kFs         44100
#define kFsFloat    44100.0

// 1 8 27 48 42

# define kDiffEqnLength 11
# define kDiffEqnTerms  {1.0, 8.0, 27.0, 48.0, 42.0, 0, -42.0, -48.0, -27.0, -8.0, -1.0}

#define kTestHistoryLength  100

#define kEdgeDetectUp       10.0
#define kEdgeDetectDown     30.0

#endif
