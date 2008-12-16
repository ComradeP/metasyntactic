//
//  Queue.m
//  NowPlaying
//
//  Created by Cyrus Najmabadi on 12/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Queue.h"

#import "Movie.h"
#import "Utilities.h"

@interface Queue()
@property (copy) NSString* feedKey;
@property (copy) NSString* etag;
@property (retain) NSArray* movies;
@end


@implementation Queue

property_definition(feedKey);
property_definition(etag);
property_definition(movies);

- (void) dealloc {
    self.feedKey = nil;
    self.etag = nil;
    self.movies = nil;

    [super dealloc];
}


- (id) initWithFeedKey:(NSString*) feedKey_
                  etag:(NSString*) etag_
                  movies:(NSArray*) movies_ {
    if (self = [super init]) {
        self.feedKey = feedKey_;
        self.etag = [Utilities nonNilString:etag_];
        self.movies = movies_;
    }
    
    return self;
}


+ (Queue*) queueWithFeedKey:(NSString*) feedKey
                       etag:(NSString*) etag
                  movies:(NSArray*) movies {
    return [[[Queue alloc] initWithFeedKey:feedKey etag:etag movies:movies] autorelease];
}


+ (Queue*) queueWithDictionary:(NSDictionary*) dictionary {
    return [Queue queueWithFeedKey:[dictionary objectForKey:feedKey_key]
                              etag:[dictionary objectForKey:etag_key]
                            movies:[Movie decodeArray:[dictionary objectForKey:movies_key]]];
}


- (NSDictionary*) dictionary {
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    [result setObject:feedKey forKey:feedKey_key];
    [result setObject:etag forKey:etag_key];
    [result setObject:[Movie encodeArray:movies] forKey:movies_key];
    return result;
}


- (BOOL) isDVDQueue {
    return [@"http://schemas.netflix.com/feed.queues.disc" isEqual:feedKey];
}


- (BOOL) isInstantQueue {
    return [@"http://schemas.netflix.com/feed.queues.instant" isEqual:feedKey];
}


@end
