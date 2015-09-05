//
//  ViewController.m
//  GuitarTuner
//
//  Created by Adam on 8/15/15.
//  Copyright (c) 2015 ClassroomA. All rights reserved.
//

#import "TECViewController.h"

//TODO make properties
@interface TECViewController ()

@property (strong, nonatomic) IBOutlet UILabel*                         floatLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray*     guitarStrings;
@property (strong, nonatomic) TECGuitarTuner*                              tuner;
@property (strong, nonatomic) NSString*                                 currentTuning;

@end


@implementation TECViewController

- (TECGuitarTuner *)tuner
{
    if (!_tuner) {
        
        _tuner = [[TECGuitarTuner alloc] init];

    }
    
    return _tuner;
}

- (TECTuningManager *)tuningManager
{
    if (!_tuningManager)
    {
        _tuningManager = [[TECTuningManager alloc] init];
    }
    
    return _tuningManager;
}

- (IBAction)noteButton:(UIButton *)sender
{
    NSString* note = [self.tuningManager.tunings[self.currentTuning] objectForKey:[NSNumber numberWithInteger:sender.tag]];
    
    [self.tuner play:note];
    
}

- (void)displayNote:(NSString *)note
{
    self.noteLabel.text = note;
    [self.noteLabel setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tuner.delegate = self;
    //the following should be pulled from NSUserDefaults
    self.currentTuning = @"Standard";
    [self.tuner startTuning];

   
}


@end
