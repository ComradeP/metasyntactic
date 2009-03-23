// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "AbstractCache.h"

@interface UpcomingCache : AbstractCache {
@private
    NSString* hashData;
    NSDictionary* movieMapData;
    NSDictionary* studioKeysData;
    NSDictionary* titleKeysData;

    LinkedSet* prioritizedMovies;

    NSMutableDictionary* bookmarksData;
}

+ (UpcomingCache*) cacheWithModel:(NowPlayingModel*) model;

- (void) update;

- (NSArray*) movies;

- (UIImage*) posterForMovie:(Movie*) movie;
- (UIImage*) smallPosterForMovie:(Movie*) movie;

- (NSString*) synopsisForMovie:(Movie*) movie;
- (NSArray*) trailersForMovie:(Movie*) movie;
- (NSArray*) directorsForMovie:(Movie*) movie;
- (NSArray*) castForMovie:(Movie*) movie;
- (NSArray*) genresForMovie:(Movie*) movie;
- (NSString*) imdbAddressForMovie:(Movie*) movie;
- (NSDate*) releaseDateForMovie:(Movie*) movie;

- (void) prioritizeMovie:(Movie*) movie;

- (void) addBookmark:(NSString*) canonicalTitle;
- (void) removeBookmark:(NSString*) canonicalTitle;
@end