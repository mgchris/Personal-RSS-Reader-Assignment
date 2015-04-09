//
//  RSSReaderTableViewController.m
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//

#import "RSSReaderTableViewController.h"
#import "FRRItemRSS.h"
#import "FRRFetchRSS.h"

@interface RSSReaderTableViewController ()
@property (nonatomic, copy) NSArray* rssItems;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectedFeeds;

@property (nonatomic, strong) NSObject* notificationObserver;

- (IBAction)feedSelectionChanged:(id)sender;
@end

static NSString * const cellIdentifier = @"RSSCellIdentifier";

@implementation RSSReaderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForNotifications];
    [self updateRssFromCache];
    
    if(self.refreshControl == nil) {
        UIRefreshControl* control = [[UIRefreshControl alloc] init];
        [control addTarget:self action:@selector(refreshFetchFeed:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = control;
    }
}

- (void)dealloc {
    [self unregisterForNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateRefreshControlForUrl:[self selectedFeedUrl]];
}

#pragma mark - Actions
- (IBAction)feedSelectionChanged:(id)sender {
    [self updateRssFromCache];
}

- (IBAction)refreshFetchFeed:(id)sender {
    NSURL* url = [self selectedFeedUrl];
    [self fetchRssFeed:url];
    [self updateRefreshControlForUrl:url];
}

#pragma mark - Feeds
- (void)fetchRssFeed:(NSURL*)url {
    [self.refreshControl beginRefreshing];
    [self.fetch fetchRSSWithUrl:url
                 withCompletion:^(NSError *error, NSArray *frrItems) {
                     if(error) {
                         if(error.code != kFRRFetchRSSErrorCodeIsFetchingData) { // Only care about already fetching errors
                             [[[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:nil] show];
                         }
                     } else {
                         // Make sure we didn't switch between different feeds
                         if ([[self selectedFeedUrl].absoluteString isEqualToString:url.absoluteString] == YES) {
                             self.rssItems = frrItems;
                             
                             [self.tableView reloadData];
                         }
                     }
                     
                     [self.refreshControl endRefreshing];
                 }];
}

- (void)updateRssFromCache {
    NSURL* url = [self selectedFeedUrl];
    [self updateRefreshControlForUrl:url];
    NSArray* cached = [self.fetch cachedRSSContentForUrl:url];
    
    if (cached.count == 0) { // No data we need to fetch
        [self fetchRssFeed:url];
    } else {
        self.rssItems = cached;
        [self.tableView reloadData];
    }
}

- (void)updateRefreshControlForUrl:(NSURL*)url {
    NSDate* lastFetch = [self.fetch getLastFetchDateForUrl:url];
    NSAttributedString* attributedString = nil;
    if(lastFetch) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateIntervalFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateIntervalFormatterShortStyle;
        NSString* string = [dateFormatter stringFromDate:lastFetch];
        attributedString = [[NSAttributedString alloc] initWithString:string];
    } else {
        attributedString = [[NSAttributedString alloc] initWithString:@"Pull down to refresh"];
    }
    
    self.refreshControl.attributedTitle = attributedString;
}

#pragma mark - Lazy loading
- (FRRFetchRSS*)fetch {
    if(_fetch == nil) {
        _fetch = [[FRRFetchRSS alloc] init];
    }
    return _fetch;
}

- (NSURL*)selectedFeedUrl {
    return self.selectedFeeds.selectedSegmentIndex == 0 ? self.topFreeApps : self.topPodcasts;
}

- (NSURL*)topFreeApps {
    if(_topFreeApps == nil) {
        _topFreeApps = [NSURL URLWithString:@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topfreeapplications/limit=25/json"];
    }
    return _topFreeApps;
}

- (NSURL*)topPodcasts {
    if(_topPodcasts == nil) {
        _topPodcasts = [NSURL URLWithString:@"https://itunes.apple.com/us/rss/toppodcasts/limit=25/json"];
    }
    return _topPodcasts;
}


#pragma mark - Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rssItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    FRRItemRSS* item = self.rssItems[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.summary;
    cell.imageView.image = [self.fetch cacheImageForUrl:item.imageUrl];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FRRItemRSS* item = self.rssItems[indexPath.row];
    if(TARGET_IPHONE_SIMULATOR) {
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Selected: %@", item.title]
                                    message:@"Cannot open app store on simulator"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        [[UIApplication sharedApplication] openURL:item.appstoreUrl];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateVisibleCellForImage:(UIImage*)image fromUrl:(NSURL*)url {
    NSArray* visibleCells = [self.tableView visibleCells];
    
    for (UITableViewCell* cell in visibleCells) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        FRRItemRSS* item = self.rssItems[indexPath.row];
        if([item.imageUrl.absoluteString isEqualToString:url.absoluteString]) {
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
    }
}

#pragma mark - Notifications
- (void)registerForNotifications {
    if(self.notificationObserver == nil) {
        self.notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:FRRFetchRSSNotificationDownloadedImage
                                                                                      object:nil
                                                                                       queue:[NSOperationQueue mainQueue]
                                                                                  usingBlock:^(NSNotification *note) {
                                                                                      
                                                                                      NSDictionary* dictionary = note.object;
                                                                                      [self updateVisibleCellForImage:dictionary[FRRFetchRSSNotificationDownloadedImageKeyImage]
                                                                                                              fromUrl:dictionary[FRRFetchRSSNotificationDownloadedImageKeyUrl]];
                                                                                  }];
    }
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver];
}

@end



