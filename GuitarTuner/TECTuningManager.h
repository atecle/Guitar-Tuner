//
//  Tuning.h
//  GuitarTuner
//
//  Created by Adam on 8/20/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

//Singleton class to manage information about tunings -- the notes that comprise them and their respective frequencies.

#import <Foundation/Foundation.h>

@interface TECTuningManager : NSObject

@property (strong, nonatomic, readonly) NSDictionary *tunings;
@property (strong, nonatomic, readonly) NSDictionary *frequencies;

@end