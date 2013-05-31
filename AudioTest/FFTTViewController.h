//
//  FFTTViewController.h
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTTAnalysisEngine.h"

@interface FFTTViewController : UIViewController



- (void) updateDisplayWithResults:(analysisReturnStruct_t)analyisResult;

@end
