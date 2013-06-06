//
//  FFTTAnalysisResults.m
//  AudioTest
//
//  Created by James Ormrod on 31/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAnalysisResults.h"
#import "AnalysisDefines.h"


@interface FFTTAnalysisResults (){
    
}
@end


@implementation FFTTAnalysisResults

-(id) init{
    if ( !(self = [super init]) ) return nil;
    
    self.beatStates = [[NSMutableArray alloc] init];
    self.impliedFrequency = [[NSMutableArray alloc] init];
    
    BOOL boolZero = NO;
    
    for (int i = 0; i < kPartials; i++) {
        [self.beatStates addObject:[NSNumber numberWithBool:boolZero]];
        [self.impliedFrequency addObject:[NSNumber numberWithFloat:(0.0)]];
    }
    
    return self;
}

@end
