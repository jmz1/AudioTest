//
//  FFTTAnalysisResults.h
//  AudioTest
//
//  Created by James Ormrod on 31/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnalysisDefines.h"

@interface FFTTAnalysisResults : NSObject{

}

@property(nonatomic, retain) NSMutableArray*    beatStates;
@property(nonatomic, retain) NSMutableArray*    impliedFrequency;

-(id) init;
    
@end
