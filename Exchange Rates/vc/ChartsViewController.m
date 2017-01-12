//
//  ChartsViewController.m
//  Exchange Rates
//
//  Created by Viktor on 05/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import "ChartsViewController.h"

@interface ChartsViewController()
@property (nonatomic) NSAsynchronousFetchResult* lastDataResult;
@property(nonatomic) NSArray *dataArray;
@property(nonatomic) UILabel *dataLabel;
@property(nonatomic) ZCharsManager *zcharsManager;
@end
@implementation ChartsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Create Years for UISegmentController
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    for(int i = self.segmentControll.numberOfSegments - 1; i >= 0 ; i --){
        [dateComponents setYear:-(i+1)];
        NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:newDate];
        NSString *newYear = [NSString stringWithFormat:@"%li", (long)[components year]];
        [self.segmentControll setTitle:newYear forSegmentAtIndex:i];
    }
    // Notification when ArchiveRequesеComplete
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showChartForData:)
                                                 name:ArchiveRequesеComplete
                                               object:nil];

}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateConstraintsForView:(UIView*) view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *width =[NSLayoutConstraint
                                constraintWithItem:view
                                attribute:NSLayoutAttributeWidth
                                relatedBy:0
                                toItem:self.chartsView
                                attribute:NSLayoutAttributeWidth
                                multiplier:1.0
                                constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint
                                 constraintWithItem:view
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:0
                                 toItem:self.chartsView
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:1.0
                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:view
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.chartsView
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:view
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.chartsView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    [self.chartsView addConstraint:width];
    [self.chartsView addConstraint:height];
    [self.chartsView addConstraint:top];
    [self.chartsView addConstraint:leading];
}


- (IBAction)onSegmentControllChanged:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    [[Model sharedInstance] getExchangeRateForYear:PrivatEntities year:[segment titleForSegmentAtIndex:segment.selectedSegmentIndex]
     succesBlock:^(id asynchronousFetchResult, id VO2) {
         self.lastDataResult = ((NSAsynchronousFetchResult*)asynchronousFetchResult);
         int countEntities = self.lastDataResult.finalResult.count;
         UIActionSheet *actionSheets = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ year has %i records.\nDid you want update it?\n This may take some time", [segment titleForSegmentAtIndex:segment.selectedSegmentIndex], countEntities] delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles: nil];
             [actionSheets showInView:self.view];
     } errorBlock:^(id VO1, id VO2) {
         NSLog(@"Error in %s", __func__);
     }
     ];
}

-(void) showChartForData:(NSNotification*) notifiction {
    NSString * sellectedYear = [self.segmentControll titleForSegmentAtIndex:self.segmentControll.selectedSegmentIndex];
    if(([notifiction object] && [[notifiction object][@"key"] isEqualToString:sellectedYear]) || !notifiction){
        [self.activityIndicator stopAnimating];
        //
        [[Model sharedInstance] getExchangeRateForYear:PrivatEntities year:sellectedYear succesBlock:^(id result, id obj2) {
            [self buildCharts:(NSAsynchronousFetchResult*)result];
        } errorBlock:^(id obj1, id obj2) {
            NSLog(@"Error archive %s", __func__);
        }
         ];
    }
}

-(void) buildCharts:(NSAsynchronousFetchResult*)result {
    if(self.zcharsManager && [self.zcharsManager superview]){
        self.zcharsManager.delegate = nil;
        self.zcharsManager.dataSource = nil;
        [self.zcharsManager reloadData];
    }

    self.l_title.text = [NSString stringWithFormat:@"Chart for %@ year", [self.segmentControll titleForSegmentAtIndex:self.segmentControll.selectedSegmentIndex]];
    NSMutableArray *usdSale = [[NSMutableArray alloc] init];
    NSMutableArray *usdBuy = [[NSMutableArray alloc] init];
    NSMutableArray *euroSale = [[NSMutableArray alloc] init];
    NSMutableArray *euroBuy = [[NSMutableArray alloc] init];
    NSMutableArray *rurSale = [[NSMutableArray alloc] init];
    NSMutableArray *rurBuy = [[NSMutableArray alloc] init];
    NSMutableArray *label = [[NSMutableArray alloc] init];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"YYYYMMdd"];
    
    NSDateFormatter *formatter2 = [NSDateFormatter new];
    [formatter2 setDateFormat:@"dd MMM"];
    
    for(id item in result.finalResult){
        PrivatVO* pvo = (PrivatVO*) item;
        [usdSale addObject:pvo.usdSale];
        [usdBuy addObject:pvo.usdBuy];
        [euroSale addObject:pvo.euroSale];
        [euroBuy addObject:pvo.euroBuy];
        [rurSale addObject:pvo.rurSale];
        [rurBuy addObject:pvo.rurBuy];
        
        [label addObject:[formatter2 stringFromDate:[formatter dateFromString:[pvo.dateAsID stringValue]]]];
    }
    self.dataArray = @[
                  @{
                      @"data": usdSale,
                      @"unit": @"UAH",
                      @"xAxis": label
                      },
                  @{
                      @"data": usdBuy,
                      @"unit": @"UAH",
                      @"xAxis": label
                      },
                  @{
                      @"data": euroSale,
                      @"unit": @"UAH",
                      @"xAxis": label
                      },
                  @{
                      @"data": euroBuy,
                      @"unit": @"UAH",
                      @"xAxis": label
                      }
                  ];
    
    //
    if(!self.zcharsManager){
        self.zcharsManager = [[ZCharsManager alloc] initWithFrame:CGRectMake(0, 0, self.chartsView.frame.size.width, self.chartsView.frame.size.height)];
        self.zcharsManager.zcharsType = ZCharsTypeLine;

        self.zcharsManager.leftView.backgroundColor = [UIColor whiteColor];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentRight;
        NSDictionary *fontDict = @{
                                   NSFontAttributeName :            [UIFont systemFontOfSize:8.0],
                                   NSForegroundColorAttributeName : UIColorFromRGB(0xa0a0a0),
                                   NSParagraphStyleAttributeName:    paragraph
                                   };
        self.zcharsManager.leftView.fontDict = fontDict;
        //    zcharsManager.leftView.width = 35;

        self.zcharsManager.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ZCharsBg"]];
        //    zcharsManager.leftView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ZCharsBg"]];

        NSMutableParagraphStyle *paragraph2 = [[NSMutableParagraphStyle alloc] init];
        paragraph2.alignment = NSTextAlignmentLeft;
        NSDictionary *fontDict2 = @{
                                    NSFontAttributeName :            [UIFont systemFontOfSize:8.0],
                                    NSForegroundColorAttributeName : UIColorFromRGB(0xa0a0a0),
                                    NSParagraphStyleAttributeName:    paragraph2
                                    };
        self.zcharsManager.rightView.XAxisFont = fontDict2;

        [self.chartsView addSubview:self.zcharsManager];
        [self updateConstraintsForView:self.zcharsManager];
        [self.zcharsManager updateConstraints];
    }
    
    self.zcharsManager.delegate = self;
    self.zcharsManager.dataSource = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.zcharsManager && [self.zcharsManager superview]){
            [self.zcharsManager reloadData];
        }
    });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){
        [self.activityIndicator startAnimating];
        self.l_title.text = [NSString stringWithFormat:@"Progress for %@ year", [self.segmentControll titleForSegmentAtIndex:self.segmentControll.selectedSegmentIndex]];
        [[Model sharedInstance] startUpdateArchiveFor:[self.segmentControll titleForSegmentAtIndex:self.segmentControll.selectedSegmentIndex]];
    }
    else{
        [self showChartForData:nil];
    }
}

#pragma mark ZCharsManagerDelegate

- (void)didScrollViewDidScroll:(NSIndexPath *)indexPath paopaoView:(UIImageView *)paopaoView {
    if (self.dataLabel == nil) {
        self.dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, paopaoView.frame.size.width, 65)];
        self.dataLabel.font = [UIFont systemFontOfSize:8.0];
        self.dataLabel.textColor = [UIColor whiteColor];
        self.dataLabel.numberOfLines = -1;
        
    }
    if(![self.dataLabel superview]){
        [paopaoView addSubview:self.dataLabel];
    }
    self.dataLabel.text = [NSString stringWithFormat:@"%@        %@\n\n   usd buy:%@\n   usd sale:%@\n euro buy:%@\n euro sale:%@",
                      self.dataArray[0][@"xAxis"][indexPath.row],
                      self.dataArray[1][@"unit"],
                      self.dataArray[1][@"data"][indexPath.row],
                      self.dataArray[0][@"data"][indexPath.row],
                      self.dataArray[3][@"data"][indexPath.row],
                      self.dataArray[2][@"data"][indexPath.row]
    ];
}

// count value YAxis
- (NSInteger)rowContInZCharsManager:(ZCharsManager *)zcharsManager {
    
    return 5;
}
// width colums
- (CGFloat)columnWidthInZCharsManager:(ZCharsManager *)zcharsManager {
    
    return 40;
}

// min max value
- (ZChasValue)valueSectionInZCharsManager:(ZCharsManager *)zcharsManager {
    
    int maxValue =  [[self.dataArray[2][@"data"] valueForKeyPath:@"@max.intValue"] intValue] + 1;
    int minValue =  [[self.dataArray[1][@"data"] valueForKeyPath:@"@min.intValue"] intValue] - 1;
    
    return ZChasValueMake(minValue, maxValue);
}


- (UIEdgeInsets)rightInsetsInZCharsManager:(ZCharsManager *)zcharsManager {
    
    return UIEdgeInsetsMake(0, 70, 45, 45);
}

- (UIImageView *)paopaoViewInZCharsManager:(ZCharsManager *)zcharsManager {
        return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ZcharsPaopao"]];
}


- (NSString *)headerViewInZCharsManager:(ZCharsManager *)zcharsManager {
    return @"ZCharsHeaderView";
}

#pragma mark - ZCharsDataSource
- (NSInteger)lineNumberOfInZCharsManager:(ZCharsManager *)zcharsManager {
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.dataArray[section][@"data"] count];
}

- (CGFloat)dataOflineNumberZCharsManager:(NSIndexPath *)indexPath lineNumber:(NSInteger)lineNumber {
    return [self.dataArray[lineNumber][@"data"][indexPath.row] floatValue];
    //    ZChasValue value = {
    //        [dataArray[lineNumber][@"data"][cell.indexPath.row] floatValue],
    //        [dataArray[lineNumber][@"data"][cell.indexPath.row + 1] floatValue]
    //    };
    
    //    return value;
}

- (NSString *)xAxisOflineNumberZCharsManager:(ZCharsLineViewCell *)cell lineNumber:(NSInteger)lineNumber {
    
    return self.dataArray[lineNumber][@"xAxis"][cell.indexPath.row];
}


- (UIColor *)lineColorOflineNumber:(NSInteger)lineNumber {
    if (lineNumber == 0) {
        return UIColorFromRGB(0x63b755);
    }
    else if(lineNumber == 1) {
        return UIColorFromRGB(0x519a45);
    }
    else if(lineNumber == 2) {
        return UIColorFromRGB(0x0099ff);
    }
    else if(lineNumber == 3) {
        return UIColorFromRGB(0x00eeff);
    }
    else{
        return UIColorFromRGB(0xff0000);
    }
}

@end
