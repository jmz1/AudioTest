//
//  FFTTAudioHandler.m
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import "FFTTAudioHandler.h"
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import <Accelerate/Accelerate.h>
#include <libkern/OSAtomic.h>


static const int kInputChannelsChangedContext;
#define kAuxiliaryViewTag 251

#define kRingBufferLength 8192
#define kMaxConversionSize 4096


@interface FFTTAudioHandler () {
    AudioFileID _audioUnitFile;
    AEChannelGroupRef _group;

    id           _timer;
    float       *_scratchBuffer;
    AudioBufferList *_conversionBuffer;
    float       *_ringBuffer;
    int          _ringBufferHead;
}

@property (nonatomic, retain) AEAudioController *audioController;
@property (nonatomic, retain) AEAudioFilePlayer *sample1;
@property (nonatomic, retain) AEFloatConverter *floatConverter;

@end


@implementation FFTTAudioHandler


- (id)init {
    if ( !(self = [super init]) ) return nil;
    
    // initialise AEAudioController, but don't start yet
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]inputEnabled:YES];

    // initialise conversion buffers
    self.floatConverter = [[AEFloatConverter alloc] initWithSourceFormat:self.audioController.audioDescription];
    _conversionBuffer = AEAllocateAndInitAudioBufferList(_floatConverter.floatingPointAudioDescription, kMaxConversionSize);
    _ringBuffer = (float*)calloc(kRingBufferLength, sizeof(float));
    _scratchBuffer = (float*)malloc(kRingBufferLength * sizeof(float) * 2);


    // send signal to start controller
    NSError *error = NULL;
    BOOL result = [_audioController start:&error];
    if ( !result ) {
        // Report error
    }
    
    // create source from file
    self.sample1 = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] 
        URLForResource:@"Samples/A4d" withExtension:@"aiff"] audioController:_audioController error:NULL];
    _sample1.volume = 1.0;
    _sample1.channelIsMuted = NO;
    _sample1.loop = YES;
    
    // Create an audio unit channel (a file player)
    // self.audioUnitPlayer = [[AEAudioUnitChannel alloc]
    //     initWithComponentDescription:AEAudioComponentDescriptionMake
    //(kAudioUnitManufacturer_Apple, kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer)
    //         audioController:_audioController
    //         error:NULL];
    
    // Create a group for sample1, iPhone audio source*
    _group = [_audioController createChannelGroup];
    [_audioController addChannels:[NSArray arrayWithObjects:_sample1, nil] toChannelGroup:_group];
    
    // Finally, add the audio unit player
    //[_audioController addChannels:[NSArray arrayWithObjects:_audioUnitPlayer, nil]];
    
    [_audioController addObserver:self forKeyPath:@"numberOfInputChannels" options:0 context:(void*)&kInputChannelsChangedContext];

    // add this instance of FFTTAudioHandler as receiver for channel group
    //[_audioController addOutputReceiver:(id< AEAudioReceiver >) self
    //forChannelGroup: _group];

    //[_audioController addInputReceiver:(id< AEAudioReceiver >) self];

    [_audioController addInputReceiver:(id< AEAudioReceiver >) self
        forChannels:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]];
        
    return self;
}

static void receiverCallback(id                        receiver,
                             AEAudioController        *audioController,
                             void                     *source,
                             const AudioTimeStamp     *time,
                             UInt32                    frames,
                             AudioBufferList          *audio) {
    FFTTAudioHandler *THIS = (FFTTAudioHandler*)receiver;
    
    // convert incoming data to floating point
    AEFloatConverterToFloatBufferList(THIS->_floatConverter, audio, THIS->_conversionBuffer, frames);
    
    // Get a pointer to the audio buffer that we can advance
    float *audioPtr = THIS->_conversionBuffer->mBuffers[0].mData;
    
    // Copy in contiguous segments, wrapping around if necessary
    int remainingFrames = frames;
    while ( remainingFrames > 0 ) {
        int framesToCopy = MIN(remainingFrames, kRingBufferLength - THIS->_ringBufferHead);
        
        memcpy(THIS->_ringBuffer + THIS->_ringBufferHead, audioPtr, framesToCopy * sizeof(float));
        audioPtr += framesToCopy;
        
        int buffer_head = THIS->_ringBufferHead + framesToCopy;
        if ( buffer_head == kRingBufferLength ) buffer_head = 0;
        OSMemoryBarrier();
        THIS->_ringBufferHead = buffer_head;
        remainingFrames -= framesToCopy;
    }

}

// should the return value be referenced with & ?
-(AEAudioControllerAudioCallback)receiverCallback {
    return receiverCallback;
}

@end
