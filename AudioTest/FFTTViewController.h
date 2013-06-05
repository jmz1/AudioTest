//
//  FFTTViewController.h
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FFTTAnalysisEngine.h"

@class FFTTAnalysisResults;

@interface FFTTViewController : UIViewController

@property (nonatomic, retain) IBOutletCollection(UILabel) NSMutableArray *beatLabels;

- (void) updateDisplayWithResults:(FFTTAnalysisResults*)analysisResults;

@end
