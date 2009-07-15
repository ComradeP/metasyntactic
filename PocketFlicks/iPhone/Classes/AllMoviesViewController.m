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

#import "AllMoviesViewController.h"

#import "Model.h"
#import "MovieTitleCell.h"

@interface AllMoviesViewController()
@property (retain) UISegmentedControl* segmentedControl;
@end


@implementation AllMoviesViewController

@synthesize segmentedControl;

- (void) dealloc {
    self.segmentedControl = nil;
    [super dealloc];
}


- (Model*) model {
    return [Model model];
}


- (NSArray*) movies {
    return self.model.movies;
}


- (BOOL) sortingByTitle {
    return self.model.allMoviesSortingByTitle;
}


- (BOOL) sortingByReleaseDate {
    return self.model.allMoviesSortingByReleaseDate;
}


- (BOOL) sortingByScore {
    return self.model.allMoviesSortingByScore;
}


- (int(*)(id,id,void*)) sortByReleaseDateFunction {
    return compareMoviesByReleaseDateDescending;
}


- (UISegmentedControl*) setupSegmentedControl {
    UISegmentedControl* control = [[[UISegmentedControl alloc] initWithItems:
                                                   [NSArray arrayWithObjects:
                               LocalizedString(@"Release", @"Must be very short. 1 word max. This is on a button that allows the user to sort movies based on how recently they were released."),
                               LocalizedString(@"Title", @"Must be very short. 1 word max. This is on a button that allows the user to sort movies based on their title."),
                               LocalizedString(@"Score", @"Must be very short. 1 word max. This is on a button that allows users to sort movies by how well they were rated."),
                               nil]] autorelease];

    control.segmentedControlStyle = UISegmentedControlStyleBar;
    control.selectedSegmentIndex = self.model.allMoviesSelectedSegmentIndex;

    [control addTarget:self
                action:@selector(onSortOrderChanged:)
      forControlEvents:UIControlEventValueChanged];

    CGRect rect = control.frame;
    rect.size.width = 310;
    control.frame = rect;

    return control;
}


- (void) onSortOrderChanged:(id) sender {
    self.model.allMoviesSelectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    [self majorRefresh];
}


- (id) init {
    if ((self = [super init])) {
        self.title = LocalizedString(@"Movies", nil);
    }

    return self;
}


- (void) loadView {
    [super loadView];

    self.segmentedControl = [self setupSegmentedControl];
    self.navigationItem.titleView = segmentedControl;
}


- (void) didReceiveMemoryWarningWorker {
    [super didReceiveMemoryWarningWorker];
    self.segmentedControl = nil;
}


- (void) majorRefresh {
    if (self.model.noScores && segmentedControl.numberOfSegments == 3) {
        segmentedControl.selectedSegmentIndex = self.model.allMoviesSelectedSegmentIndex;
        [segmentedControl removeSegmentAtIndex:2 animated:NO];
    } else if (!self.model.noScores && segmentedControl.numberOfSegments == 2) {
        [segmentedControl insertSegmentWithTitle:LocalizedString(@"Score", nil) atIndex:2 animated:NO];
    }

    [super majorRefresh];
}


- (UITableViewCell*) createCell:(Movie*) movie {
    return [MovieTitleCell movieTitleCellForMovie:movie inTableView:self.tableView];
}

@end
