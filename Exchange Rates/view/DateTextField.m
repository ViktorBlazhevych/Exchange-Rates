//
//  DateTextField.m
//  Exchange Rates
//
//  Created by Viktor on 05/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import "DateTextField.h"

@interface DateTextField ()
@property(nonatomic) UIDatePicker *datePicker;
@end

@implementation DateTextField

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configDateFieldResponder];
    }
    return self;
}

-(void) configDateFieldResponder {
    // Config Date picker and Toolbar text field
    self.datePicker = [UIDatePicker new];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    //self.datePicker.maximumDate = [NSDate date];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width, 44)];
    UIBarButtonItem *btn_done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDateSelected:)];
    
    UIBarButtonItem *btn_toDay = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleDone target:self action:@selector(onDateSelectedToDay:)];
    [btn_toDay setTintColor:[UIColor grayColor]];
    
    UIBarButtonItem *btn_yesterday = [[UIBarButtonItem alloc] initWithTitle:@"Yesterday" style:UIBarButtonItemStyleDone target:self action:@selector(onDateSelectedYesterday:)];
    [btn_yesterday setTintColor:[UIColor grayColor]];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:@[btn_yesterday, space, btn_toDay, space, btn_done]];
    
    [self setInputView:self.datePicker];
    [self setInputAccessoryView:toolBar];
    
    // Hide menu and cursore
    self.delegate = self;
    self.tintColor = [UIColor clearColor];

}

-(void) onDateSelected:(id)sender {
    if(self.dateFieldDelegate){
        [self.dateFieldDelegate onDateChanged:self.datePicker.date];
    }
    [self resignFirstResponder];
}

-(void) onDateSelectedToDay:(id)sender {
    if(self.dateFieldDelegate){
        self.datePicker.date = [NSDate date];
        [self.dateFieldDelegate onDateChanged:self.datePicker.date];
    }
    [self resignFirstResponder];
}

-(void) onDateSelectedYesterday:(id)sender {
    if(self.dateFieldDelegate){
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:-1];
        NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];

        self.datePicker.date = yesterday;
        [self.dateFieldDelegate onDateChanged:self.datePicker.date];
    }
    [self resignFirstResponder];
}

#pragma mark - UITextFieldDelegate 

// blocked menu and edit textField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIMenuController sharedMenuController].menuVisible = NO;
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
    /*
    if (action == @selector(paste:)){
        return NO;
     }
    return [super canPerformAction:action withSender:sender];
     */
}
@end
