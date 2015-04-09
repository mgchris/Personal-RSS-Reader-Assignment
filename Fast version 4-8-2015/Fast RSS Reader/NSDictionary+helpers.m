//
//  NSDictionary+helpers.m
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//

#import "NSDictionary+helpers.h"

@implementation NSDictionary (helpers)

- (id)mgValueCheck:(NSString*)key {
    id value = self[key];
    
    if(value == [NSNull null]) {
        value = nil;
    }
    
    return value;
}

@end
