//
//  AnalysisDefines.h
//  AudioTest
//
//  Created by James Ormrod on 20/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#ifndef AudioTest_AnalysisDefines_h
#define AudioTest_AnalysisDefines_h

#define kRingBufferLength 8192
//#define kRingBufferLength 1024
#define kRingBufferLengthBytes (kRingBufferLength * sizeof(float))

#define kSamplesPerWindow 512
#define kSamplesPerWindowFloat 512.0

#define kLog2of16K 14
#define kLog2of8K  13

#endif
