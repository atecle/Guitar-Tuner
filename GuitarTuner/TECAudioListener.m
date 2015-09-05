//
//  TECAudioListener.m
//  GuitarTuner
//
//  Created by Adam on 9/1/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

#import "TECAudioListener.h"



static Float32*     fftResult;


@interface TECAudioListener()
{

    UInt32 log2N;
    UInt32 N;
    
}

@property (readwrite, nonatomic) SInt16*                 samples;
@property (readwrite, nonatomic) int                     sampleCount;
@end

@implementation TECAudioListener

- (instancetype)init
{
    if ((self = [super init]) != nil)
    {
        
        [self configureAudioQueue];
    }
    
    return self;
}

- (BOOL)isRecording
{
    return  _aqData.mIsRunning;
}

- (void)configureAudioQueue
{
    // Set Up an Audio Format for Recording
    log2N = kNumberSamples;
    N = (1 << log2N);
    helperRef = FFTHelperCreate(log2N);
    _aqData.mDataFormat.mFormatID = kAudioFormatLinearPCM;
    _aqData.mDataFormat.mSampleRate = kSampleRate;
    _aqData.mDataFormat.mChannelsPerFrame = kNumberChannels;
    _aqData.mDataFormat.mBitsPerChannel = kBitsPerChannel;
    _aqData.mDataFormat.mBytesPerPacket = 2 * _aqData.mDataFormat.mChannelsPerFrame;
    _aqData.mDataFormat.mBytesPerFrame = 2 * _aqData.mDataFormat.mChannelsPerFrame;
    _aqData.mDataFormat.mChannelsPerFrame = 2;
    _aqData.mDataFormat.mFramesPerPacket = 1;
    
    _aqData.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    
    // Create a Recording Audio Queue
    OSStatus result;
    
    if ((result = AudioQueueNewInput(&_aqData.mDataFormat,
                                     HandleInputBuffer,
                                     &_aqData,
                                     NULL,
                                     kCFRunLoopCommonModes,
                                     0,
                                     &_aqData.mQueue)) != noErr)
    {
        NSLog(@"AudioQueueNewInput failed");
    }
    
    // Set an Audio Queue Buffer Size
    DeriveBufferSize(_aqData.mQueue, &(_aqData.mDataFormat), 0.5, &_aqData.bufferByteSize);
    
    
    // Prepare a Set of Audio Queue Buffers
    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueAllocateBuffer(_aqData.mQueue, _aqData.bufferByteSize, &_aqData.mBuffers[i]);
        AudioQueueEnqueueBuffer(_aqData.mQueue, _aqData.mBuffers[i], 0, NULL);
    }
    
    
}

- (void)startListening
{
    // Record Audio
    _aqData.mCurrentPacket = 0;
    _aqData.mIsRunning = true;
    
    AudioQueueStart(_aqData.mQueue, NULL);
    
}

- (void)stopListening
{
    AudioQueueStop (_aqData.mQueue, true);
    _aqData.mIsRunning = false;
    
    // Clean up
    AudioQueueDispose(_aqData.mQueue, true);
    
}

static void DeriveBufferSize (AudioQueueRef                audioQueue,
                              const AudioStreamBasicDescription  *ASBDescription,
                              Float64                      seconds,
                              UInt32                       *outBufferSize)
{
    
    static const int maxBufferSize = 0x50000;
    
    int maxPacketSize = ASBDescription->mBytesPerPacket;
    
    if (maxPacketSize == 0)
    {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        
        AudioQueueGetProperty (
                               
                               audioQueue,
                               
                               kAudioQueueProperty_MaximumOutputPacketSize,
                               
                               // in Mac OS X v10.5, instead use
                               
                               //   kAudioConverterPropertyMaximumOutputPacketSize
                               
                               &maxPacketSize,
                               
                               &maxVBRPacketSize
                               
                               );
        
    }
    
    Float64 numBytesForTime = ASBDescription->mSampleRate * maxPacketSize * seconds;
    
    *outBufferSize = (UInt32) (numBytesForTime < maxBufferSize ?
                               
                               numBytesForTime : maxBufferSize);
    
}

static void HandleInputBuffer  (void                                *aqData,
                                void                                *helperRef,
                                AudioQueueRef                       inAQ,
                                AudioQueueBufferRef                 inBuffer,
                                const AudioTimeStamp                *inStartTime,
                                UInt32                              inNumPackets,
                                const AudioStreamPacketDescription  *inPacketDesc)
{
    AQRecorderState *pAqData = (AQRecorderState *) aqData;
    FFTHelperRef    *pHelperRef = (FFTHelperRef *) helperRef;
    
    NSLog(@"inNumPackets = %d, bytesper packet = %d", inNumPackets, pAqData->mDataFormat.mBytesPerPacket);
    
    if (inNumPackets == 0 && pAqData->mDataFormat.mBytesPerPacket != 0)
    {
        NSLog(@"pack");
        inNumPackets = inBuffer->mAudioDataByteSize / pAqData->mDataFormat.mBytesPerPacket;
    }
    
    int sampleCount = inBuffer->mAudioDataBytesCapacity / sizeof(AUDIO_DATA_TYPE_FORMAT);
  
    //pAqData->mSampleCount = sampleCount;
    
    SInt16* samples = inBuffer->mAudioData;
    //pAqData->mCurrentSamples = samples;

    Float32* frames = malloc(sizeof(Float32) * sampleCount);
    
    for (int i = 0; i < sampleCount; i++) {
        frames[i] = samples[i] / 32768.0f;
    }
    
    Float32* result = computeFFT(pHelperRef, frames, sampleCount);
    fftResult = result;
    NSLog(@"%.6f", result);
    
    if (pAqData->mIsRunning == 0) return;
    
    AudioQueueEnqueueBuffer (pAqData->mQueue, inBuffer, 0, NULL);

}

FFTHelperRef * FFTHelperCreate(long numberOfSamples) {
    
    FFTHelperRef *helperRef = (FFTHelperRef*) malloc(sizeof(FFTHelperRef));
    vDSP_Length log2n = log2f(numberOfSamples);
    helperRef->fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    int nOver2 = numberOfSamples/2;
    helperRef->complexA.realp = (Float32*) malloc(nOver2*sizeof(Float32) );
    helperRef->complexA.imagp = (Float32*) malloc(nOver2*sizeof(Float32) );
    
    helperRef->outFFTData = (Float32 *) malloc(nOver2*sizeof(Float32) );
    memset(helperRef->outFFTData, 0, nOver2*sizeof(Float32) );
    
    helperRef->invertedCheckData = (Float32*) malloc(numberOfSamples*sizeof(Float32) );
    
    return  helperRef;
}

static Float32 * computeFFT(FFTHelperRef *fftHelperRef, Float32 *timeDomainData, long numSamples)
{
    vDSP_Length log2n = log2f(numSamples);
    Float32 mFFTNormFactor = 1.0/(2*numSamples);
    
    //Convert float array of reals samples to COMPLEX_SPLIT array A
    vDSP_ctoz((COMPLEX*)timeDomainData, 2, &(fftHelperRef->complexA), 1, numSamples/2);
    
    //Perform FFT using fftSetup and A
    //Results are returned in A
    vDSP_fft_zrip(fftHelperRef->fftSetup, &(fftHelperRef->complexA), 1, log2n, FFT_FORWARD);
    
    //scale fft
    vDSP_vsmul(fftHelperRef->complexA.realp, 1, &mFFTNormFactor, fftHelperRef->complexA.realp, 1, numSamples/2);
    vDSP_vsmul(fftHelperRef->complexA.imagp, 1, &mFFTNormFactor, fftHelperRef->complexA.imagp, 1, numSamples/2);
    
    vDSP_zvmags(&(fftHelperRef->complexA), 1, fftHelperRef->outFFTData, 1, numSamples/2);
    
    //to check everything =============================
    vDSP_fft_zrip(fftHelperRef->fftSetup, &(fftHelperRef->complexA), 1, log2n, FFT_INVERSE);
    vDSP_ztoc( &(fftHelperRef->complexA), 1, (COMPLEX *) fftHelperRef->invertedCheckData , 2, numSamples/2);
    //=================================================
    
    return fftHelperRef->outFFTData;
}

//
//static void MyInterruptionListener (void     *inClientData,
//                                    UInt32   inInterruptionState)
//{
//    
//}



@end
