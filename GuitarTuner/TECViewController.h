//
//  ViewController.h
//  GuitarTuner
//
//  Created by Adam on 8/15/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

// Framework includes
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioQueue.h>

// Local includes
//#import "AudioController.h"
#import "TECGuitarTuner.h"
#import "TECTuningManager.h"



@interface TECViewController : UIViewController <NoteDisplayDelegate>

@property (strong, nonatomic) TECTuningManager *tuningManager;
@property (strong, nonatomic) IBOutlet UILabel                          *noteLabel;

@end

