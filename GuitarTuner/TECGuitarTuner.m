//
//  GuitarTuner.m
//  GuitarTuner
//
//  Created by Adam on 8/15/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

#import "TECGuitarTuner.h"

@interface TECGuitarTuner()
@property (strong, nonatomic) EZAudioPlayer *audioPlayer;
@end


static vDSP_Length const FFTViewControllerFFTWindowSize = 4096;

@implementation TECGuitarTuner

- (instancetype) init {
    
    if ((self = [super init]) != nil)
    {
        [self configureAudioSession];
    }
    
    return self;
    
}

- (void) configureAudioSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    

    //
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    //
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    
    //
    // Create an instance of the EZAudioFFTRolling to keep a history of the incoming audio data and calculate the FFT.
    //
    self.fft = [EZAudioFFTRolling fftWithWindowSize:FFTViewControllerFFTWindowSize
                                         sampleRate:self.microphone.audioStreamBasicDescription.mSampleRate
                                           delegate:self];
    
    
}

- (void) startTuning
{
    //
    // Start the mic
    //
    [self.microphone startFetchingAudio];

}


//------------------------------------------------------------------------------
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Calculate the FFT, will trigger EZAudioFFTDelegate
    //
    [self.fft computeFFTWithBuffer:buffer[0] withBufferSize:bufferSize];
    
//    __weak typeof (self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [weakSelf.audioPlotTime updateBuffer:buffer[0]
//                              withBufferSize:bufferSize];
//    });
}


//------------------------------------------------------------------------------
#pragma mark - EZAudioFFTDelegate
//------------------------------------------------------------------------------

- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize
{
    float maxFrequency = [fft maxFrequency];
    NSString *noteName = [EZAudioUtilities noteNameStringForFrequency:maxFrequency
                                                        includeOctave:YES];
    NSLog(@"note : %@", noteName);
    id<NoteDisplayDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
  
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([strongDelegate respondsToSelector:@selector(displayNote:)]) {
            [strongDelegate displayNote:noteName];
        }
    });
}

//------------------------------------------------------------------------------


- (void) play:(NSString *)note
{

    NSString *path = [[NSBundle mainBundle] pathForResource:note ofType:@"mp3"];
    NSURL *soundURL = [NSURL fileURLWithPath:path];
    
    if (!_audioPlayer)
    {
        _audioPlayer = [[EZAudioPlayer alloc] initWithAudioFile:[[EZAudioFile alloc] initWithURL: soundURL]];

    }
    else
    {
        self.audioPlayer.audioFile = [[EZAudioFile alloc] initWithURL:soundURL];
    }
    
    [self.audioPlayer play];
    
    
 
}

@end
