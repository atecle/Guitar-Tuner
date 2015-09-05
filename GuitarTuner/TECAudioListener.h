//
//  TECAudioListener.h
//  GuitarTuner
//
//  Created by Adam on 9/1/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>

#define AUDIO_DATA_TYPE_FORMAT SInt16

static const int kNumberChannels = 2;
static const int kNumberSamples = 10; //1024 samples
static const int kBufferSize = 4096;
static const int kMaxNumber = 4096;
static const int kSampleRate = 44100;
static const int kNumberBuffers = 3;
static const int kBitsPerChannel = 16;

//Custom structure to manage AudioQueue state
typedef struct AQRecorderState {
    
    AudioStreamBasicDescription  mDataFormat;
    
    AudioQueueRef                mQueue;
    
    AudioQueueBufferRef          mBuffers[kNumberBuffers];
    
    UInt32                       bufferByteSize;
    
    SInt64                       mCurrentPacket;
    
    bool                         mIsRunning;
    
    //Custom fields. To be passed back to TECGuitarTuner
    
    SInt16*                      mCurrentSamples;
    
    int                          mSampleCount;
    
} AQRecorderState;

//Custom structure to manage FFT parameters
typedef struct FFTHelperRef {
    
    FFTSetup fftSetup; // Accelerate opaque type that contains setup information for a given FFT transform.
    
    COMPLEX_SPLIT complexA; // Accelerate type for complex number
    
    Float32 *outFFTData; // Your fft output data
    
    Float32 *invertedCheckData; // This thing is to verify correctness of output. Compare it with input.
    
} FFTHelperRef;

@interface TECAudioListener : NSObject
{
    
@private
    FFTHelperRef *helperRef;
    AQRecorderState _aqData;
    
}

@property (readonly, nonatomic) SInt16*                 samples;
@property (readonly, nonatomic) int                     sampleCount;
@property (readonly, getter=isRecording) BOOL           recording;

- (void) startListening;
- (void) stopListening;

@end
