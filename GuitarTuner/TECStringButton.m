//
//  AGTStringButton.m
//  GuitarTuner
//
//  Created by Adam on 8/30/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

#import "TECStringButton.h"


@implementation TECStringButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]) != nil)
    {
        [self commonInitialization];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self commonInitialization];
    }
    
    return self;
    
}

- (void)commonInitialization
{
    self.titleLabel.font = [UIFont fontWithName:@"DS-Digital" size:30.0];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self configureBorder];
}

- (void)configureBorder
{
    self.layer.cornerRadius = self.bounds.size.width/2.0;
    self.layer.borderWidth = 2.0;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1.0,0.4,.30,1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    self.layer.borderColor = color;
}

@end
