//
//  FFTTAudioReceiver.h
//  AudioTest
//
//  Created by Daniel Clelland on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

@interface FFTTAudioReceiver : NSObject <AEAudioReceiver>

- (int) getTestCount;

- (float) getTestValue;


@end
