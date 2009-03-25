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

#import "SearchResult.h"

@interface SearchResult()
@property NSInteger requestId;
@property (copy) NSString* value;
@property (retain) NSArray* movies;
@property (retain) NSArray* theaters;
@property (retain) NSArray* upcomingMovies;
@property (retain) NSArray* dvds;
@property (retain) NSArray* bluray;
@end


@implementation SearchResult

@synthesize requestId;
@synthesize value;
@synthesize movies;
@synthesize theaters;
@synthesize upcomingMovies;
@synthesize dvds;
@synthesize bluray;

- (void) dealloc {
    self.requestId = 0;
    self.value = nil;
    self.movies = nil;
    self.theaters = nil;
    self.upcomingMovies = nil;
    self.dvds = nil;
    self.bluray = nil;

    [super dealloc];
}


- (id) initWithId:(NSInteger) requestId__
            value:(NSString*) value__
           movies:(NSArray*) movies__
         theaters:(NSArray*) theaters__
   upcomingMovies:(NSArray*) upcomingMovies__
             dvds:(NSArray*) dvds__
           bluray:(NSArray*) bluray__ {
    if (self = [super init]) {
        self.requestId = requestId__;
        self.value = value__;
        self.movies = movies__;
        self.theaters = theaters__;
        self.upcomingMovies = upcomingMovies__;
        self.dvds = dvds__;
        self.bluray = bluray__;
    }

    return self;
}


+ (SearchResult*) resultWithId:(NSInteger) requestId
                         value:(NSString*) value
                        movies:(NSArray*) movies
                      theaters:(NSArray*) theaters
                upcomingMovies:(NSArray*) upcomingMovies
                          dvds:(NSArray*) dvds
                        bluray:(NSArray*) bluray {
    return [[[SearchResult alloc] initWithId:requestId
                                       value:value
                                      movies:movies
                                    theaters:theaters
                              upcomingMovies:upcomingMovies
                                        dvds:dvds
                                      bluray:bluray] autorelease];
}

@end