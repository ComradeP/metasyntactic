//
//  NetflixCache.h
//  NowPlaying
//
//  Created by Cyrus Najmabadi on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AbstractCache.h"

@interface NetflixCache : AbstractCache {
@private
    NSArray* feedsData;
    NSMutableDictionary* queues;
    
    // movies whose details we want to update
    LinkedSet* normalMovies;
    LinkedSet* searchMovies;
    LinkedSet* prioritizedMovies;
    
    NSCondition* updateDetailsLock;
}

+ (NetflixCache*) cacheWithModel:(NowPlayingModel*) model;

+ (NSString*) recommendationKey;

- (void) prioritizeMovie:(Movie*) movie;

- (void) update;
- (NSArray*) feeds;
- (Queue*) queueForFeed:(Feed*) feed;
- (Feed*) feedForKey:(NSString*) key;

- (UIImage*) posterForMovie:(Movie*) movie;
- (UIImage*) smallPosterForMovie:(Movie*) movie;
- (NSArray*) castForMovie:(Movie*) movie;
- (NSArray*) directorsForMovie:(Movie*) movie;
- (NSString*) imdbAddressForMovie:(Movie*) movie;
- (NSString*) synopsisForMovie:(Movie*) movie;

- (NSString*) noInformationFound;

- (void) updateQueue:(Queue*) queue
            fromFeed:(Feed*) feed
  byMovingMovieToTop:(Movie*) movie
            delegate:(id<NetflixModifyQueueDelegate>) delegate;

- (void) updateQueue:(Queue*) queue
            fromFeed:(Feed*) feed
    byDeletingMovies:(IdentitySet*) deletedMovies
 andReorderingMovies:(IdentitySet*) reorderedMovies
                  to:(NSArray*) movies
            delegate:(id<NetflixModifyQueueDelegate>) delegate;


@end
