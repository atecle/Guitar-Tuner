//
//  GuitarTuner.h
//  GuitarTuner
//
//  Created by Adam on 8/15/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

//Framework Includes
#import <AVFoundation/AVFoundation.h>

//Local Includes
#import "TECTuningManager.h"
#import "EZAudio.h"

@protocol NoteDisplayDelegate;

@interface TECGuitarTuner : NSObject <EZMicrophoneDelegate, EZAudioFFTDelegate>

/**
 The microphone used to get input.
 */
@property (nonatomic,strong) EZMicrophone *microphone;

/**
 Used to calculate a rolling FFT of the incoming audio data.
 */
@property (nonatomic, strong) EZAudioFFTRolling *fft;

/**
 Delegate for updating ViewController with currently detected note;
 */
@property (weak, nonatomic) id <NoteDisplayDelegate> delegate;

- (void) play: (NSString*) note;
- (void) startTuning;
@end

@protocol NoteDisplayDelegate <NSObject>

- (void)displayNote:(NSString*)note;

@end