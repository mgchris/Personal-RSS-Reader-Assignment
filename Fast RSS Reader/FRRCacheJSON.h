//
//  FRRCacheJSON.h
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface FRRCacheJSON : NSObject


- (void)storeJsonResponse:(NSDictionary*)dictionary forCacheKey:(NSString*)key;
- (NSDictionary*)getJsonResponseForCacheKey:(NSString*)key;

- (void)storeCacheImage:(UIImage*)image withFileName:(NSString*)fileName;
- (UIImage*)getCacheImageWithFileName:(NSString*)fileName;

- (NSDate*)getLastFetchDateForKey:(NSString*)key;
- (void)storeLastFetchDate:(NSDate*)date forKey:(NSString*)key;

@end
