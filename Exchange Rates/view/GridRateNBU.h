//
//  GridRateNBU.h
//  Exchange Rates
//
//  Created by Viktor on 06/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBUVO.h"
@interface GridRateNBU : UIView
@property (weak, nonatomic) IBOutlet UILabel *l_dateRate;

@property (weak, nonatomic) IBOutlet UILabel *l_usdName;
@property (weak, nonatomic) IBOutlet UILabel *l_euroName;
@property (weak, nonatomic) IBOutlet UILabel *l_rurName;


@property (weak, nonatomic) IBOutlet UILabel *l_usdBuy;
@property (weak, nonatomic) IBOutlet UILabel *l_euroBuy;
@property (weak, nonatomic) IBOutlet UILabel *l_rurBuy;

-(void) updateView:(NBUVO*)obj;

@end
