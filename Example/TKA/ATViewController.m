//
//  ATViewController.m
//  TKA
//
//  Created by piaomiaoatian667 on 11/27/2019.
//  Copyright (c) 2019 piaomiaoatian667. All rights reserved.
//

#import "ATViewController.h"
#import "DopTrack.h"
@interface ATViewController ()

@end

@implementation ATViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *APPKEY = @"8qFfSMpoud75"; /*Gi1nghWSZCsz*/

    // Do any additional setup after loading the view, typically from a nib.
    DopTrack *track = [DopTrack defaultDopTracker];
    [track setDefaultTrackURLStr];
//    //    [track exitApp];
    [track startWithAppkey:APPKEY reportPolicy:REALTIME marketId:@"7777"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
