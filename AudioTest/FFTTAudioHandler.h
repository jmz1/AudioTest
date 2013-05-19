//
//  FFTTAudioHandler.h
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TheAmazingAudioEngine.h"

@interface FFTTAudioHandler : NSObject <AEAudioReceiver>

- (id)init;

- (AEAudioControllerAudioCallback)receiverCallback;

@end
