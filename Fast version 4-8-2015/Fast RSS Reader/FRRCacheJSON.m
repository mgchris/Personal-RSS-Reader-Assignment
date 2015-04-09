//
//  FRRCacheJSON.m
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//

#import "FRRCacheJSON.h"

@implementation FRRCacheJSON

#pragma mark - Json Response
- (NSString*)jsonResponseFileNameForCacheKey:(NSString*)key {
    NSString* fileName = [NSString stringWithFormat:@"%@-response.json", key];
    return fileName;
}

- (void)storeJsonResponse:(NSDictionary*)dictionary forCacheKey:(NSString*)key {
    NSString* fileName = [self jsonResponseFileNameForCacheKey:key];
    NSURL* location = [NSURL URLWithString:fileName relativeToURL:[self userDocumentUrl]];
    [dictionary writeToURL:location atomically:YES];
}

- (NSDictionary*)getJsonResponseForCacheKey:(NSString*)key {
    NSString* fileName = [self jsonResponseFileNameForCacheKey:key];
    NSURL* location = [NSURL URLWithString:fileName relativeToURL:[self userDocumentUrl]];
    NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfURL:location];
    return dictionary;
}

#pragma mark - Images
- (void)storeCacheImage:(UIImage*)image withFileName:(NSString*)fileName {
    NSURL* location = [NSURL URLWithString:fileName relativeToURL:[self userCacheUrl]];
    NSData* data = UIImagePNGRepresentation(image);
    [data writeToURL:location atomically:YES];
}

- (UIImage*)getCacheImageWithFileName:(NSString*)fileName {
    NSURL* location = [NSURL URLWithString:fileName relativeToURL:[self userCacheUrl]];
    NSData* data = [NSData dataWithContentsOfURL:location];
    UIImage* image = [UIImage imageWithData:data];
    return image;
}

#pragma mark - Date
- (NSDate*)getLastFetchDateForKey:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)storeLastFetchDate:(NSDate*)date forKey:(NSString*)key {
    if(date) {
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Helpers
- (NSURL*)userDocumentUrl {
    NSArray* directories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* document = [directories lastObject];
    return document;
}

- (NSURL*)userCacheUrl {
    NSArray* directories = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL* cache = [directories lastObject];
    return cache;
}

@end
