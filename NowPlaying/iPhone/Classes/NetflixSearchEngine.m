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
#import "NetflixSearchEngine.h"

#import "Model.h"
#import "NetflixCache.h"
#import "SearchRequest.h"

@implementation NetflixSearchEngine

- (void) dealloc {
    [super dealloc];
}


+ (NetflixSearchEngine*) engineWithDelegate:(id<SearchEngineDelegate>) delegate {
    return [[[NetflixSearchEngine alloc] initWithDelegate:delegate] autorelease];
}


- (Model*) model {
    return [Model model];
}


- (void) searchWorker:(SearchRequest*) currentlyExecutingRequest {
    NSString* error;
    NSArray* movies = [self.model.netflixCache movieSearch:currentlyExecutingRequest.lowercaseValue error:&error];
    if ([self abortEarly:currentlyExecutingRequest]) { return; }
    NSArray* people = [self.model.netflixCache peopleSearch:currentlyExecutingRequest.lowercaseValue];
    if ([self abortEarly:currentlyExecutingRequest]) { return; }

    [self reportResult:currentlyExecutingRequest
                movies:movies
              theaters:[NSArray array]
        upcomingMovies:[NSArray array]
                  dvds:[NSArray array]
                bluray:[NSArray array]
                people:people];
}

@end