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

#import "NetflixMostPopularMoviesViewController.h"

#import "CommonNavigationController.h"
#import "Model.h"
#import "NetflixCell.h"

@interface NetflixMostPopularMoviesViewController()
@property (copy) NSString* category;
@end


@implementation NetflixMostPopularMoviesViewController

@synthesize category;

- (void) dealloc {
  self.category = nil;

  [super dealloc];
}


- (id) initWithCategory:(NSString*) category_ {
  if ((self = [super initWithStyle:UITableViewStylePlain])) {
    self.category = category_;
    self.title = category_;
  }

  return self;
}


- (NetflixRssCache*) netflixRssCache {
  return [NetflixRssCache cache];
}


- (NSArray*) determineMovies {
  return [self.netflixRssCache moviesForRSSTitle:category];
}

@end
