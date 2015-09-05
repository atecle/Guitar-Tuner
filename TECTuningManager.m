//
//  Tuning.m
//  GuitarTuner
//
//  Created by Adam on 8/24/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TECTuningManager.h"

@interface TECTuningManager()

@property (strong, nonatomic, readwrite) NSDictionary *tunings;
@property (strong, nonatomic, readwrite) NSDictionary *frequencies;

@end


@implementation TECTuningManager

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _tunings = @{@"Standard" :
                             @{ @0 : @"E2", @1 : @"A2",
                                @2 : @"D3", @3 : @"G3",
                                @4 : @"B3", @5 : @"E4"}};
        
        _frequencies = @{@"E2" : [NSNumber numberWithFloat:82.41], @"A2" : [NSNumber numberWithFloat:110.00],
                             @"D3" : [NSNumber numberWithFloat:146.83], @"G3" : [NSNumber numberWithFloat:196.00],
                             @"B3" : [NSNumber numberWithFloat:246.94], @"E4" : [NSNumber numberWithFloat:329.63]};
    }
    
    return self;
}

@end