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

@interface AbstractDataProvider : AbstractCache {
@private
    // Accessed from multiple threads.  needs lock
    NSArray* moviesData;
    NSArray* theatersData;
    NSDictionary* synchronizationInformationData;
    NSDictionary* bookmarksData;
    NSMutableDictionary* performancesData;

    NSMutableDictionary* cachedIsStale;
}

- (NSArray*) movies;
- (NSArray*) theaters;
- (NSArray*) moviePerformances:(Movie*) movie forTheater:(Theater*) theater;
- (NSDate*) synchronizationDateForTheater:(Theater*) theater;

- (NSDate*) lastLookupDate;

- (BOOL) isStale:(Theater*) theater;

- (void) update:(NSDate*) searchDate delegate:(id<DataProviderUpdateDelegate>) delegate context:(id) context force:(BOOL) force;
- (void) saveResult:(LookupResult*) result;

- (void) addBookmark:(NSString*) canonicalTitle;
- (void) removeBookmark:(NSString*) canonicalTitle;

@end