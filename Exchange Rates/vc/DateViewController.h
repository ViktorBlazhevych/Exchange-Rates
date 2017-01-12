//
//  DateViewController.h
//  Exchange Rates
//
//  Created by Viktor on 05/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Model.h"
#import "DateTextField.h"
#import "GridRateNBU.h"
#import "GridRatePrivat.h"
#import "PrivatVO.h"
#import "NBUVO.h"

@interface DateViewController : UIViewController <DateTextFieldProtocol>
@property(nonatomic) Model *model;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet DateTextField *tf_Date;
@property (strong, nonatomic) IBOutlet GridRateNBU *gridRateNBU;
@property (strong, nonatomic) IBOutlet GridRatePrivat *gridRatePrivat;
@property (weak, nonatomic) IBOutlet UIView *gridHolderView;

- (IBAction)onSwipeGesture:(id)sender;

@end
