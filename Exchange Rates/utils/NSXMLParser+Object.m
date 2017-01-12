//
//  NSXMLParser+Object.m
//  Exchange Rates
//
//  Created by Viktor on 07/01/17.
//  Copyright © 2017 Viktor. All rights reserved.
//

#import "NSXMLParser+Object.h"
#import <objc/runtime.h>

static void * TargetObjectPropertyKey = &TargetObjectPropertyKey;
@implementation NSXMLParser (Object)

- (id)targetObject {
    return objc_getAssociatedObject(self, TargetObjectPropertyKey);
}

- (void)setTargetObject:(id)obj {
    objc_setAssociatedObject(self, TargetObjectPropertyKey, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
