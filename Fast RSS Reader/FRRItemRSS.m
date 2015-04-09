//
//  FRRItemRSS.m
//  Fast RSS Reader
//
//  Created by chrise26 on 4/8/15.
//  Copyright (c) 2015 Usana. All rights reserved.
//

#import "FRRItemRSS.h"
#import "NSDictionary+helpers.h"

@interface FRRItemRSS ()
@property (copy) NSString* title;
@property (copy) NSString* summary;
@property (copy) NSURL* imageUrl;
@property (strong) NSURL* appstoreUrl;

@property (copy) NSDictionary* content;

@end


@implementation FRRItemRSS

- (id)initWithDictionary:(NSDictionary*)dict {
    
    if(dict) {
        self = [super init];
        if(self) {
            _content = dict;
        }
    } else {
        self = nil;
    }
    
    return self;
}

- (NSString*)title {
    
    if(_title == nil) {
        NSDictionary* attributes = [self.content mgValueCheck:@"im:name"];
        _title = [attributes mgValueCheck:@"label"];
    }
    
    return _title;
}

- (NSString*)summary {
    if(_summary == nil) {
        NSDictionary* attributes = [self.content mgValueCheck:@"summary"];
        _summary = [attributes mgValueCheck:@"label"];
    }
    
    return _summary;
}

- (NSURL*)imageUrl {
    if(_imageUrl == nil) {
        NSArray* images = [self.content mgValueCheck:@"im:image"];
        
        for (NSDictionary* imageInfo in images) {
            NSDictionary* attributes = [imageInfo mgValueCheck:@"attributes"];
            NSString* height = [attributes mgValueCheck:@"height"];
            if([height isEqualToString:@"53"] || [height isEqualToString:@"55"]) { // Maybe it would be better to allow the ViewController to pick the right size.
                NSString* path = [imageInfo mgValueCheck:@"label"];
                _imageUrl = [NSURL URLWithString:path];
                break;
            }
        }
    }
    
    return _imageUrl;
}

- (NSURL*)appstoreUrl {
    if(_appstoreUrl == nil) {
        NSDictionary* link = [self.content mgValueCheck:@"link"];
        NSDictionary* attributes = [link mgValueCheck:@"attributes"];
        NSString* href = [attributes mgValueCheck:@"href"];
        if (href) {
            _appstoreUrl = [NSURL URLWithString:href];
        }
    }
    
    return _appstoreUrl;
}


@end
