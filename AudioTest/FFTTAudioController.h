//
//  FFTTAudioController.h
//  AudioTest
//
//  Created by Daniel Clelland on 19/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

#import "FFTTAudioReceiver.h"

@interface FFTTAudioController : NSObject

@property (nonatomic, retain) AEAudioController *audioController;
@property (nonatomic, retain) AEAudioFilePlayer *audioFilePlayer;
@property (nonatomic, retain) FFTTAudioReceiver *audioReceiver;

- (void)start;
- (void)stop;

@end
