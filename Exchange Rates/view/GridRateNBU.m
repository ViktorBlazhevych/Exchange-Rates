//
//  GridRateNBU.m
//  Exchange Rates
//
//  Created by Viktor on 06/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import "GridRateNBU.h"

@implementation GridRateNBU

-(void) updateView:(NBUVO*) obj {
    if(obj){
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMinimumFractionDigits:2];
        [formatter setMaximumFractionDigits:2];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYYMMdd"];
        NSDate* date = [dateFormatter dateFromString:[obj.dateAsID stringValue]];
        
        NSDateFormatter *dateFormatter_2 = [NSDateFormatter new];
        [dateFormatter_2 setDateFormat:@"dd MMM YYYY"];
        
        self.l_dateRate.text = [dateFormatter_2 stringFromDate:date];
        
        self.l_usdName.text = obj.usdName;
        self.l_euroName.text = obj.euroName;
        self.l_rurName.text = obj.rurName;
        
        
        self.l_usdBuy.text = [formatter stringForObjectValue:obj.usdBuy];
        self.l_euroBuy.text = [formatter stringForObjectValue:obj.euroBuy];
        self.l_rurBuy.text = [formatter stringForObjectValue:obj.rurBuy];        
    }
    else{
        self.l_dateRate.text = @"--";
        self.l_usdName.text = @"USD";
        self.l_euroName.text = @"EUR";
        self.l_rurName.text = @"RUR";
        
        
        self.l_usdBuy.text = @"--";
        self.l_euroBuy.text = @"--";
        self.l_rurBuy.text = @"--";
    }
    
}

@end
