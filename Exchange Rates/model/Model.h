//
//  Model.h
//  Exchange Rates
//
//  Created by Viktor on 05/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "PrivatVO.h"
#import "NBUVO.h"
#import "NSXMLParser+Object.h"


#define PrivatEntities @"PrivatEntities"
#define NBUEntities @"NBUEntities"
#define ArchiveRequesеComplete @"ArchiveRequesеComplete"

@interface Model : NSObject <NSXMLParserDelegate>

@property (nonatomic) NSDate* currentDate;

+ (Model*)sharedInstance;

-(void) getExchangeRateForEntity:(NSString*)entityName from:(NSDate*)from to:(NSDate*)to succesBlock:(void (^)(id, id)) succesBlock errorBlock:(void (^)(id, id)) errorBlock;

-(void) getExchangeRateForYear:(NSString*)nameEntitites year:(NSString*)yearAsString succesBlock:(void (^)(id, id))succesBlock errorBlock:(void (^)(id, id))errorBlock;

- (void) startUpdateArchiveFor:(NSString*)year;

@end
