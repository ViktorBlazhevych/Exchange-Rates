//
//  Model.m
//  Exchange Rates
//
//  Created by Viktor on 05/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import "Model.h"

@interface Model()
@property (nonatomic) NSManagedObjectContext *managedContext;
//@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) NSDateFormatter* formatterYYYYMMdd;
@property (nonatomic) NSMutableDictionary* archiveCountDic;
@end

@implementation Model
+(Model* )sharedInstance {
    static dispatch_once_t onceToken;
    static Model *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        instance.currentDate = [NSDate date];

        instance.managedContext = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];
        /*
        instance.operationQueue = [[NSOperationQueue alloc] init];
        instance.operationQueue.name = @"DownloadArchive";
        instance.operationQueue.maxConcurrentOperationCount = 2;
        */
        instance.archiveCountDic = [NSMutableDictionary new];
        
        instance.formatterYYYYMMdd = [NSDateFormatter new];
        [instance.formatterYYYYMMdd setDateFormat:@"YYYYMMdd"];
        
    });
    
    return instance;
}

///
-(void) getExchangeRateForEntity:(NSString*)entityName from:(NSDate*)from to:(NSDate*)to succesBlock:(void (^)(id, id)) succesBlock errorBlock:(void (^)(id, id)) errorBlock{
    NSNumber *fromID = @([[self.formatterYYYYMMdd stringFromDate:from] integerValue]);
    NSNumber *toID = @([[self.formatterYYYYMMdd stringFromDate:to] integerValue]);
    NSAsynchronousFetchResult* results = [self getEntityForName:entityName fromID:fromID toID:toID];
    if(results && results.finalResult.count > 0){
        if([entityName isEqualToString:PrivatEntities]){
            succesBlock(results.finalResult[0], nil);
        }
        if([entityName isEqualToString:NBUEntities]){
            succesBlock(nil, results.finalResult[0]);
        }
    }
    else{
        NSLog(@"Need loads data for  %@ --> %s", ([entityName isEqualToString:PrivatEntities] ? @"PrivatEntities" : @"NBUEntities"), __func__);
        if([entityName isEqualToString:PrivatEntities]){
            [self getExchangeRatePrivatBankForDate:from succesBlock:succesBlock errorBlock:errorBlock];
        }
        else if([entityName isEqualToString:NBUEntities]){
            NSString *today = [self.formatterYYYYMMdd stringFromDate:[NSDate date]];
            NSString *forDate = [self.formatterYYYYMMdd stringFromDate:from];
            if([today isEqualToString:forDate]){
                [self getExchangeRateNBUBank:succesBlock errorBlock:errorBlock];
            }
            else{
                [self getExchangeRatePrivatBankForDate:from succesBlock:succesBlock errorBlock:errorBlock];
            }
        }
    }
}

-(void) getExchangeRateForYear:(NSString*)nameEntitites year:(NSString*)yearAsString succesBlock:(void (^)(id, id)) succesBlock errorBlock:(void (^)(id, id)) errorBlock{
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    
    NSNumber* startYear = [formatter numberFromString:[NSString stringWithFormat:@"%@0000", yearAsString]];
    NSNumber* endYear = [formatter numberFromString:[NSString stringWithFormat:@"%@9999", yearAsString]];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:nameEntitites];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"dateAsID >= %i AND dateAsID <= %i ", [startYear integerValue], [endYear integerValue]];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAsID" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // for full get object
    [request setReturnsObjectsAsFaults:NO];
    //
    
    NSAsynchronousFetchResult* results = nil;
    @try {
        results = [self.managedContext executeRequest:request error:nil];
        if(succesBlock){
            succesBlock(results, nil);
        }
    }
    @catch (NSException *exception) {
        if(errorBlock){
            errorBlock(nil, nil);
        }
    }
}

- (void) startUpdateArchiveFor:(NSString*)year{
    int _year = [year integerValue];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSDateComponents *dateComponentsNewDate = [[NSDateComponents alloc] init];

    [dateComponents setYear:_year];
    [dateComponentsNewDate setYear:_year];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PrivatEntities];
       
    NSAsynchronousFetchResult* results = nil;
    @try {
        results = [self.managedContext executeRequest:request error:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Error executeRequest: %@ --> %s", [exception description], __func__);
    }

    NSSet* existingEntities = [NSSet setWithArray:[results.finalResult valueForKeyPath:@"dateAsID"]];

    if(![[self.archiveCountDic allKeys] containsObject:year]) {
        self.archiveCountDic[year] = @0;
    }
    
    int day = 1;
    NSDate *date = nil;
     while([dateComponentsNewDate year] == _year) {
        [dateComponents setDay:day];
        date = [calendar dateFromComponents:dateComponents];
        dateComponentsNewDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
        day++;
         if([dateComponentsNewDate year] == _year){
             NSNumber *dateAsID = @([[self.formatterYYYYMMdd stringFromDate:date] integerValue]);
             
             if(![existingEntities containsObject:dateAsID]){
                 NSNumber *c = [self.archiveCountDic objectForKey:year];
                 c = [NSNumber numberWithInteger:([c integerValue] + 1)];
                 [self.archiveCountDic setObject:c forKey:year];
                 [self getExchangeRatePrivatBankForDate:date succesBlock:^(id a, id b) {
                     [self onCompleteArchiveRequest:year];
                 } errorBlock:^(id a, id b) {
                     [self onCompleteArchiveRequest:year];
                 }
                  ];
                 
                /*
                 __weak typeof (self) weakSelf = self;
                 NSBlockOperation *operation = [NSBlockOperation new];
                 [operation addExecutionBlock:^{
                     [weakSelf getExchangeRatePrivatBankForDate:date succesBlock:^(id a, id b) {
                         
                     } errorBlock:^(id a, id b) {
                                              }
                      ];
                 }
                  ];
                 
                 [operation setCompletionBlock:^{
                     NSLog(@"END OPERATIONN !!!!");
                 }];
                 
                 [self.operationQueue addOperation:operation];
                 */
                 
             }
         }
    }
    if([[self.archiveCountDic objectForKey:year] isEqual: @0]){
        [[NSNotificationCenter defaultCenter] postNotificationName:ArchiveRequesеComplete object:@{@"key":year}];
    }
    
   //[self.operationQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
}

/*
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.operationQueue && [keyPath isEqualToString:@"operationCount"]) {
         NSInteger operationCount = [change[NSKeyValueChangeNewKey] integerValue];
        if (operationCount == 0) {
            // Do something here when your queue has completed
            NSLog(@"queue has completed");
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}
*/

-(void) onCompleteArchiveRequest:(NSString*) key{
    NSNumber *c = [self.archiveCountDic objectForKey:key];
    c = [NSNumber numberWithInteger:([c integerValue] - 1)];
    [self.archiveCountDic setObject:c forKey:key];
    if([[self.archiveCountDic objectForKey:key] isEqual: @0]){
        [[NSNotificationCenter defaultCenter] postNotificationName:ArchiveRequesеComplete object:@{@"key":key}];
    }
}

#pragma mark -- Privat API
-(void) getExchangeRatePrivatBankForDate:(NSDate*)date succesBlock:(void (^)(id, id)) succesBlock errorBlock:(void (^)(id, id)) errorBlock{
    NSString *today = [self.formatterYYYYMMdd stringFromDate:[NSDate date]];
    NSString *forDate = [self.formatterYYYYMMdd stringFromDate:date];
    
    //__block __weak typeof (self) weakSelf = self;

    // Block for parseDate
    void (^parseBlock)(NSString*dateString, id responseObject);
    parseBlock = ^(NSString*dateString, id responseObject) {
        PrivatVO * privatVO = [NSEntityDescription insertNewObjectForEntityForName:PrivatEntities inManagedObjectContext:self.managedContext];
        privatVO.dateAsID = @([forDate integerValue]);
        
        NBUVO * nbuVO = nil;
        NSAsynchronousFetchResult* results = [self getEntityForName:NBUEntities fromID:@([forDate integerValue]) toID:@([forDate integerValue])];
        if(!results || results.finalResult.count == 0){
            nbuVO = [NSEntityDescription insertNewObjectForEntityForName:NBUEntities inManagedObjectContext:self.managedContext];
            nbuVO.dateAsID = @([forDate integerValue]);
        }
        
        //
        if([today isEqualToString:forDate]){
            if(nbuVO){
                [self.managedContext deleteObject:nbuVO];
            }
            // parse for toDay
            for(id item in responseObject){
                if([item[@"ccy"] isEqualToString:@"EUR"]){
                    privatVO.euroName = item[@"ccy"] ;
                    privatVO.euroBuy = @([item[@"buy"] floatValue]);
                    privatVO.euroSale = @([item[@"sale"] floatValue]);
                }
                else if([item[@"ccy"] isEqualToString:@"USD"]){
                    privatVO.usdName = item[@"ccy"];
                    privatVO.usdBuy = @([item[@"buy"] floatValue]);
                    privatVO.usdSale = @([item[@"sale"] floatValue]);
                }
                else if([item[@"ccy"] isEqualToString:@"RUR"]){
                    privatVO.rurName = item[@"ccy"];
                    privatVO.rurBuy = @([item[@"buy"] floatValue]);
                    privatVO.rurSale = @([item[@"sale"] floatValue]);
                }
            }
        }
        else{
            // parse for notToDay
            //
            for(id item in responseObject[@"exchangeRate"]){
                if([item[@"currency"] isEqualToString:@"EUR"]){
                    privatVO.euroName = item[@"currency"] ;
                    privatVO.euroBuy = @([item[@"purchaseRate"] floatValue]);
                    privatVO.euroSale = @([item[@"saleRate"] floatValue]);
                    if(nbuVO){
                        nbuVO.euroName = item[@"currency"] ;
                        nbuVO.euroBuy = @([item[@"purchaseRateNB"] floatValue]);
                    }
                }
                else if([item[@"currency"] isEqualToString:@"USD"]){
                    privatVO.usdName = item[@"currency"];
                    privatVO.usdBuy = @([item[@"purchaseRate"] floatValue]);
                    privatVO.usdSale = @([item[@"saleRate"] floatValue]);
                    if(nbuVO){
                        nbuVO.usdName = item[@"currency"] ;
                        nbuVO.usdBuy = @([item[@"purchaseRateNB"] floatValue]);
                    }
                }
                else if([item[@"currency"] isEqualToString:@"RUR"] || [item[@"currency"] isEqualToString:@"RUB"]){
                    privatVO.rurName = item[@"currency"];
                    privatVO.rurBuy = @([item[@"purchaseRate"] floatValue]);
                    privatVO.rurSale = @([item[@"saleRate"] floatValue]);
                    if(nbuVO){
                        nbuVO.rurName = item[@"currency"] ;
                        nbuVO.rurBuy = @([item[@"purchaseRateNB"] floatValue]);
                    }
                }
            }
        }
        if(![privatVO.euroBuy isEqual:@0] && ![privatVO.euroSale isEqual:@0]){
            [self saveManagedContext];
            succesBlock(privatVO, nbuVO);
        }
        else {
            // remove empty object
            for(id i in self.managedContext.insertedObjects){
                [self.managedContext deleteObject:i];
            }
            errorBlock(nil, nil);
        }
    };
    //
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString* urlRequest = @"";
    if([today isEqualToString:forDate]){
        urlRequest = @"https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=11";
    }
    else{
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"dd.MM.YYYY"];
        NSString* strForDate = [formatter stringFromDate:date];
        urlRequest = [NSString stringWithFormat:@"https://api.privatbank.ua/p24api/exchange_rates?json&date=%@", strForDate ];
    }
    [manager GET:urlRequest parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        parseBlock(forDate, responseObject);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorBlock(nil, nil);
        NSLog(@"Error: %@ --> %s", @"Empty in getExchangeRatePrivatBankForDate", __func__);
    }];
}

#pragma mark -- NBU API

-(void) getExchangeRateNBUBank:(void (^)(id, id)) succesBlock errorBlock:(void (^)(id, id)) errorBlock{
    
    __block __weak typeof (self) weakSelf = self;

    NBUVO *nbuVO = [NSEntityDescription insertNewObjectForEntityForName:NBUEntities inManagedObjectContext:self.managedContext];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/xml"];
    [manager GET:@"https://privat24.privatbank.ua/p24/accountorder?oper=prp&PUREXML&apicour&country=ua" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSString *fetchedXML = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
        NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:responseObject];
        xmlparser.delegate = weakSelf;
        xmlparser.targetObject = nbuVO;
        [xmlparser parse];
        // check for Entities
        NSAsynchronousFetchResult* results = [self getEntityForName:NBUEntities fromID:nbuVO.dateAsID toID:nbuVO.dateAsID];
        if(results && results.finalResult.count > 1){
            [self.managedContext deleteObject:nbuVO];
            succesBlock(nil, results.finalResult[0]);
            return;
        }
        //
        if(![nbuVO.euroBuy isEqual:@0] && ![nbuVO.usdBuy isEqual:@0]){
            [self saveManagedContext];
            succesBlock(nil, nbuVO);
        }
        else{
            // remove empty object
            for(id i in self.managedContext.insertedObjects){
                [self.managedContext deleteObject:i];
            }
            errorBlock(nil, nil);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@ --> %s", @"Empty in getExchangeRateNBUBank", __func__);
        errorBlock(nil, nil);
    }];
}

#pragma mark -- NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"exchangerate"]) {
        NBUVO* nbuVO = (NBUVO*)parser.targetObject;
        if([attributeDict[@"ccy"] isEqualToString:@"EUR"]){
            nbuVO.euroName = attributeDict[@"ccy"] ;
            nbuVO.euroBuy = @(([attributeDict[@"buy"] floatValue]/[attributeDict[@"unit"] floatValue])/10000.00);
        }
        else if([attributeDict[@"ccy"] isEqualToString:@"USD"]){
            nbuVO.usdName = attributeDict[@"ccy"];
            nbuVO.usdBuy= @(([attributeDict[@"buy"] floatValue]/[attributeDict[@"unit"] floatValue])/10000.00);
        }
        else if([attributeDict[@"ccy"] isEqualToString:@"RUR"]){
            nbuVO.rurName = attributeDict[@"ccy"];
            nbuVO.rurBuy = @(([attributeDict[@"buy"] floatValue]/[attributeDict[@"unit"] floatValue])/10000.00);
        }
        
        if(attributeDict[@"date"]){
            nbuVO.dateAsID = @([[NSString stringWithString:[attributeDict[@"date"] stringByReplacingOccurrencesOfString:@"." withString:@""]] integerValue]);
        }
    }
}

#pragma mark -- CoreData

-(id) getEntityForName:(NSString*)entityName fromID:(NSNumber*)fromID toID:(NSNumber*)toID {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"dateAsID >= %i AND dateAsID <= %i ", [fromID integerValue], [toID integerValue]];
    [request setPredicate:predicate];
    // for full get object
    [request setReturnsObjectsAsFaults:NO];
    //
    
    NSAsynchronousFetchResult* results = nil;
    @try {
        results = [self.managedContext executeRequest:request error:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Error executeRequest: %@ --> %s", [exception description], __func__);
    }
    return results;
}

-(void) saveManagedContext {
    if ([self.managedContext hasChanges]) {
        
        NSError *error = nil;
        if(![self.managedContext save:&error]){
            NSLog(@"Save CoreData Error : %@ --> %s", [error localizedDescription], __func__);
        }
        
        //
        //  Debug
        //
        /*
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PrivatEntities"];
        [request setReturnsObjectsAsFaults:NO];
        NSAsynchronousFetchResult* results = nil;
        @try {
            results = [self.managedContext executeRequest:request error:nil];
            NSSet* privatEntities = [NSSet setWithArray:[results.finalResult valueForKeyPath:@"dateAsID"]];
            NSLog(@"\n\nPrivatEntities -- Q = %i\n%@\n", results.finalResult.count, [privatEntities description]);
        }
        @catch (NSException *exception) {
            
        }
        
        
        NSFetchRequest *requestNBU = [NSFetchRequest fetchRequestWithEntityName:@"NBUEntities"];
        [requestNBU setReturnsObjectsAsFaults:NO];
        NSAsynchronousFetchResult* resultsNBU = nil;
        @try {
            resultsNBU = [self.managedContext executeRequest:requestNBU error:nil];
            NSSet* nbuEntities = [NSSet setWithArray:[resultsNBU.finalResult valueForKeyPath:@"dateAsID"]];
            NSLog(@"\n\nNBUEntities -- Q = %i\n%@\n", resultsNBU.finalResult.count, [nbuEntities description]);
        }
        @catch (NSException *exception) {
            
        }
         */
    }
}


@end
