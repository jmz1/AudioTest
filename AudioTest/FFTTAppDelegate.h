//
//  FFTTAppDelegate.h
//  AudioTest
//
//  Created by James Ormrod on 15/05/13.
//  Copyright (c) 2013 James Ormrod. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFTTViewController;
@class FFTTAudioController;

@interface FFTTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FFTTViewController *viewController;
@property (strong, nonatomic) FFTTAudioController *audioController;
 
@end
