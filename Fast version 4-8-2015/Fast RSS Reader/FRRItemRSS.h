//
//  FRRItemRSS.h
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRRItemRSS : NSObject

@property (nonatomic, copy, readonly) NSString* title;
@property (nonatomic, copy, readonly) NSString* summary;
@property (nonatomic, copy, readonly) NSURL* imageUrl;
@property (nonatomic, strong, readonly) NSURL* appstoreUrl;

        
- (id)initWithDictionary:(NSDictionary*)dict;


@end
