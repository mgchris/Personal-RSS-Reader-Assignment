//
//  FRRFetchRSS.h
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FRRFetchCompletionBlock)(NSError* error, NSArray* frrItems);
typedef void(^FRRFetchImageCompletionBlock)(UIImage* image);

static NSString * const FRRFetchRSSErrorDomain = @"FRRFetchRSSErrorDomain";

static NSString * const FRRFetchRSSNotificationDownloadedImage          = @"FRRFetchRSSDownloadedImage";
static NSString * const FRRFetchRSSNotificationDownloadedImageKeyImage  = @"FRRFetchRSSNotificationDownloadedImageKeyImage";
static NSString * const FRRFetchRSSNotificationDownloadedImageKeyUrl    = @"FRRFetchRSSNotificationDownloadedImageKeyUrl";

#define kFRRFetchRSSErrorCodeUnexpectedData -1
#define kFRRFetchRSSErrorCodeIsFetchingData -2


@interface FRRFetchRSS : NSObject

- (BOOL)isFetchingForUrl:(NSURL*)url;
- (NSDate*)getLastFetchDateForUrl:(NSURL*)url;

- (void)fetchRSSWithUrl:(NSURL*)url withCompletion:(FRRFetchCompletionBlock)completion;

- (NSArray*)cachedRSSContentForUrl:(NSURL*)url;
- (UIImage*)cacheImageForUrl:(NSURL*)url;

@end
