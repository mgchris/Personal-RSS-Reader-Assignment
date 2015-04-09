//
//  RSSReaderTableViewController.h
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRRFetchRSS;


@interface RSSReaderTableViewController : UITableViewController

@property (nonatomic, strong) FRRFetchRSS* fetch;

@property (nonatomic, copy) NSURL* topFreeApps;
@property (nonatomic, copy) NSURL* topPodcasts;

@end
