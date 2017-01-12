//
//  DateViewController.m
//  Exchange Rates
//
//  Created by Viktor on 05/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import "DateViewController.h"

@interface DateViewController ()

@end

@implementation DateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewWillAppear:(BOOL)animated{
    [self.gridRateNBU setFrame:CGRectMake(0, 0, self.gridHolderView.frame.size.width, self.gridHolderView.frame.size.height)];
    [self.gridRatePrivat setFrame:CGRectMake(0, 0, self.gridHolderView.frame.size.width, self.gridHolderView.frame.size.height)];
    if(self.gridHolderView.subviews.count == 0){
        [self.gridRateNBU updateView:nil];
        [self.gridRatePrivat updateView:nil];
        // set first gridView
        [self.gridHolderView addSubview:self.gridRatePrivat];
        [self updateConstraintsForView:self.gridRatePrivat];
        
        self.tf_Date.dateFieldDelegate = self;
        [self onDateChanged:[Model sharedInstance].currentDate];
    }
}

-(void) onDateChanged:(NSDate *)date {
    [Model sharedInstance].currentDate = date;
    
    NSDateFormatter *formater = [NSDateFormatter new];
    [formater setDateFormat:@"dd/MM/YYY"];
    NSString *dateString = [formater stringFromDate:date];
    
    self.tf_Date.text = dateString;
    [self requestDataForView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestDataForView {
    [self.activityIndicator startAnimating];
    [[Model sharedInstance] getExchangeRateForEntity:(([self.gridHolderView subviews][0] == self.gridRateNBU) ? NBUEntities : PrivatEntities) from:[Model sharedInstance].currentDate to:[Model sharedInstance].currentDate succesBlock:^(id privateVO, id nbuVO) {
            if(![privateVO isEqual:[NSNull null]] && ([self.gridHolderView subviews][0] == self.gridRatePrivat)){
                [self.gridRatePrivat updateView:(PrivatVO*)privateVO];
            }
            if(![nbuVO isEqual:[NSNull null]] && ([self.gridHolderView subviews][0] == self.gridRateNBU)){
                [self.gridRateNBU updateView:(NBUVO*)nbuVO];
            }
            [self.activityIndicator stopAnimating];
        } errorBlock:^(id privateVO, id nbuVO) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"dd MMM YYYY"];
            NSString* titleString = [NSString stringWithFormat:@"No Rates for %@", [dateFormatter stringFromDate:[Model sharedInstance].currentDate]];
            [self.gridRatePrivat updateView:nil];
            self.gridRatePrivat.l_dateRate.text = titleString;
            
            [self.gridRateNBU updateView:nil];
            self.gridRateNBU.l_dateRate.text = titleString;
            [self.activityIndicator stopAnimating];
        }] ;
}

- (IBAction)onSwipeGesture:(id)sender {
    UISwipeGestureRecognizer *gesture = nil;
    if([sender isKindOfClass:[UISwipeGestureRecognizer class]]){
        gesture = (UISwipeGestureRecognizer*) sender;
    }
    if(gesture){
        int optionsTransition = 0;
        if(gesture.direction == UISwipeGestureRecognizerDirectionRight){
            optionsTransition = UIViewAnimationOptionTransitionFlipFromLeft;
        }
        if(gesture.direction == UISwipeGestureRecognizerDirectionLeft){
            optionsTransition = UIViewAnimationOptionTransitionFlipFromRight;
        }
        
        UIView * fromView = ([self.gridHolderView subviews][0] == self.gridRateNBU) ? self.gridRateNBU : self.gridRatePrivat;
        UIView * toView = ([self.gridHolderView subviews][0] == self.gridRateNBU) ? self.gridRatePrivat : self.gridRateNBU;
        
        [UIView transitionWithView:self.gridHolderView
                          duration:0.2
                           options:optionsTransition
                        animations:^{
                            [fromView removeFromSuperview];
                            [toView performSelector:@selector(updateView:) withObject:nil];
                            
                            [self.gridHolderView addSubview:toView];
                            [self updateConstraintsForView:toView];
                            [self requestDataForView];
                        }
                        completion:^(BOOL finished){}
         ];
    }
}

-(void) updateConstraintsForView:(UIView*) view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *width =[NSLayoutConstraint
                                constraintWithItem:view
                                attribute:NSLayoutAttributeWidth
                                relatedBy:0
                                toItem:self.gridHolderView
                                attribute:NSLayoutAttributeWidth
                                multiplier:1.0
                                constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint
                                 constraintWithItem:view
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:0
                                 toItem:self.gridHolderView
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:1.0
                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:view
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.gridHolderView
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:view
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.gridHolderView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    [self.gridHolderView addConstraint:width];
    [self.gridHolderView addConstraint:height];
    [self.gridHolderView addConstraint:top];
    [self.gridHolderView addConstraint:leading];
}

@end
