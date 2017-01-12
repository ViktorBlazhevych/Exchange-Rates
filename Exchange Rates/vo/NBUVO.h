//
//  NBUVO.h
//  Exchange Rates
//
//  Created by Viktor on 07/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NBUVO : NSManagedObject
@property(nonatomic) NSNumber *dateAsID;

@property(nonatomic) NSString *usdName;
@property(nonatomic) NSString *euroName;
@property(nonatomic) NSString *rurName;

@property(nonatomic) NSNumber *usdBuy;
@property(nonatomic) NSNumber *euroBuy;
@property(nonatomic) NSNumber *rurBuy;
@end
