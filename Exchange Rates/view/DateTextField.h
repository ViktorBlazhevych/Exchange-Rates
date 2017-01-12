//
//  DateTextField.h
//  Exchange Rates
//
//  Created by Viktor on 05/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DateTextFieldProtocol;

@interface DateTextField : UITextField <UITextFieldDelegate>
@property(nonatomic, weak) id <DateTextFieldProtocol> dateFieldDelegate;
@end

@protocol DateTextFieldProtocol
@optional
-(void) onDateChanged:(NSDate*)date;
@end