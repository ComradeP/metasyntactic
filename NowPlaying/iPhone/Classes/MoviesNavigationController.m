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
#import "MoviesNavigationController.h"

#import "AllMoviesViewController.h"
#import "Model.h"
#import "Movie.h"

@interface MoviesNavigationController()
@property (retain) AllMoviesViewController* allMoviesViewController;
@end


@implementation MoviesNavigationController

@synthesize allMoviesViewController;

- (void) dealloc {
    self.allMoviesViewController = nil;

    [super dealloc];
}


- (id) init {
    if (self = [super init]) {
        self.title = NSLocalizedString(@"Movies", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"Movies.png"];
    }

    return self;
}


- (Model*) model {
    return [Model model];
}


- (void) loadView {
    [super loadView];

    if (allMoviesViewController == nil) {
        self.allMoviesViewController = [[[AllMoviesViewController alloc] init] autorelease];
        [self pushViewController:allMoviesViewController animated:NO];
    }
}


- (Movie*) movieForTitle:(NSString*) canonicalTitle {
    for (Movie* movie in self.model.movies) {
        if ([movie.canonicalTitle isEqual:canonicalTitle]) {
            return movie;
        }
    }

    return nil;
}

@end