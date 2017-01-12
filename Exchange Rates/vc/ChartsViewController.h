//
//  ChartsViewController.h
//  Exchange Rates
//
//  Created by Viktor on 05/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCharsManager.h"
#import "Model.h"
#import "AppDelegate.h"
#import "PrivatVO.h"
#import "NBUVO.h"

@interface ChartsViewController : UIViewController <UIActionSheetDelegate, ZCharsDataSource, ZCharsManagerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControll;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *chartsView;
@property (weak, nonatomic) IBOutlet UILabel *l_title;

- (IBAction)onSegmentControllChanged:(id)sender;

@end
