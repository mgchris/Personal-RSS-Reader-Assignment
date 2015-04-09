//
//  FRRFetchRSS.m
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//

#import "FRRFetchRSS.h"
#import "FRRItemRSS.h"
#import "NSDictionary+helpers.h"
#import "FRRCacheJSON.h"

@interface FRRFetchRSS ()

@property (nonatomic, strong) FRRCacheJSON* cache;
@property (nonatomic, copy) NSMutableDictionary* requesting;
@end


@implementation FRRFetchRSS

#pragma mark - 
- (NSDate*)getLastFetchDateForUrl:(NSURL*)url {
    return [self.cache getLastFetchDateForKey:[self cacheKeyForUrl:url]];
}


#pragma mark - Request throttling
- (NSMutableDictionary*)requesting {
    if(_requesting) {
        _requesting = [NSMutableDictionary dictionary];
    }
    return _requesting;
}

- (BOOL)isFetchingForUrl:(NSURL*)url {
    NSString* key = [self cacheKeyForUrl:url];
    BOOL isFetching = self.requesting[key] != nil;
    return isFetching;
}

- (void)storeFetchingUrl:(NSURL*)url {
    NSString* key = [self cacheKeyForUrl:url];
    self.requesting[key] = url;
}

- (void)removeFetchingUrl:(NSURL*)url {
    NSString* key = [self cacheKeyForUrl:url];
    [self.requesting removeObjectForKey:key];
}

#pragma mark - Fetching
- (void)fetchRSSWithUrl:(NSURL*)url withCompletion:(FRRFetchCompletionBlock)completion {
    
    if([self isFetchingForUrl:url] == NO) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self storeFetchingUrl:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *error) {
                                   NSArray* rssItems = nil;
                                   NSError* handleError = nil;
                                   
                                   if(error || data.length == 0) {
                                       handleError = [self generalErrorMessage];
                                   } else {
                                       NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&handleError];
                                       
                                       if(handleError || json == nil) {
                                           handleError = [self generalErrorMessage];
                                       } else {
                                           rssItems = [self processJSON:json];
                                           [self.cache storeJsonResponse:json forCacheKey:[self cacheKeyForUrl:url]];
                                       }
                                   }
                                   
                                   if(completion) {
                                       [self.cache storeLastFetchDate:[NSDate date] forKey:[self cacheKeyForUrl:url]];
                                       [self removeFetchingUrl:url];
                                       completion(handleError, rssItems);
                                   }
                               }];
    } else {
        NSError* error = [self generalIsFetchingErrorMessage];
        if(completion) {
            completion(error, nil);
        }
    }
}

- (NSArray*)processJSON:(NSDictionary*)rss {
    NSMutableArray* rssItems = nil;
    
    if(rss) {
        rssItems = [NSMutableArray array];
        NSDictionary* feed = [rss mgValueCheck:@"feed"];
        NSArray* entries = [feed mgValueCheck:@"entry"];
        for (NSDictionary* dictionary in entries) {
            FRRItemRSS* item = [[FRRItemRSS alloc] initWithDictionary:dictionary];
            if (item) {
                [rssItems addObject:item];
            }
        }
    }
    
    return rssItems.count > 0 ? [rssItems copy] : nil; // return nil if we don't have anything
}

- (NSError*)generalErrorMessage {
    NSError* error = [NSError errorWithDomain:FRRFetchRSSErrorDomain
                                         code:kFRRFetchRSSErrorCodeUnexpectedData
                                     userInfo:@{NSLocalizedDescriptionKey: @"Unexpected data from server, try again later"}];
    return error;
}

- (NSError*)generalIsFetchingErrorMessage {
    NSError* error = [NSError errorWithDomain:FRRFetchRSSErrorDomain
                                         code:kFRRFetchRSSErrorCodeIsFetchingData
                                     userInfo:@{NSLocalizedDescriptionKey: @"Currently fetching data please wait"}];
    return error;
}




#pragma mark - Cache
- (NSArray*)cachedRSSContentForUrl:(NSURL*)url {
    NSString* key = [self cacheKeyForUrl:url];
    NSDictionary* json = [self.cache getJsonResponseForCacheKey:key];
    NSArray* rss = [self processJSON:json];
    return rss;
}

- (NSString*)cacheKeyForUrl:(NSURL*)url {
    NSUInteger hash = url.hash;
    NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)hash];
    return key;
}

- (FRRCacheJSON*)cache {
    if(_cache == nil) {
        _cache = [[FRRCacheJSON alloc] init];
    }
    return _cache;
}

#pragma mark - Images
- (UIImage*)cacheImageForUrl:(NSURL*)url {
    NSString* key = [self cacheKeyForUrl:url];
    UIImage* image = [self.cache getCacheImageWithFileName:key];
    
    
    if(image == nil) { // download the image
        if([self isFetchingForUrl:url] == NO) {
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [self storeFetchingUrl:url];
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response,
                                                       NSData *data,
                                                       NSError *error) {
                                       
                                       if(error == nil) {
                                           UIImage* image = [UIImage imageWithData:data];
                                           
                                           if(image != nil) {
                                               NSString* fileName = [self cacheKeyForUrl:url];
                                               [self.cache storeCacheImage:image withFileName:fileName];
                                               [self postNotificationDownloadedImage:image forUrl:url];
                                           }
                                       }
                                       [self removeFetchingUrl:url];
                                   }];
        }
    }
    
    return image;
}

- (void)postNotificationDownloadedImage:(UIImage*)image forUrl:(NSURL*)url {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FRRFetchRSSNotificationDownloadedImage
                                                        object:@{FRRFetchRSSNotificationDownloadedImageKeyImage:image,
                                                                 FRRFetchRSSNotificationDownloadedImageKeyUrl:url }];
}

@end



