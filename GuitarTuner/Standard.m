//
//  Standard.m
//  GuitarTuner
//
//  Created by Adam on 8/20/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tuning.h"

@interface Standard : NSObject <Tuning>

@end

@interface Standard()

@property (nonatomic, strong, readwrite) NSArray *notes;
@property (nonatomic, strong, readwrite) NSArray *frequencies;

@end

@implementation Standard

- (NSArray *)notes
{
    if (!_notes)
    {
        _notes = [[NSArray alloc] initWithObjects: @[@"E2", @"A2", @"D3", @"G3", @"B3", @"E4"], nil];
    }
    
    return _notes;
}

- (NSArray *)frequencies
{
    if (_frequencies)
    {
        _frequencies = [NSArray arrayWithObjects:[NSNumber numberWithFloat:329.63], [NSNumber numberWithFloat:246.94], [NSNumber numberWithFloat:196.00], [NSNumber numberWithFloat:146.83],
                        [NSNumber numberWithFloat:110.00], [NSNumber numberWithFloat:82.41], nil];
    }
    
    return _frequencies;
}



@end