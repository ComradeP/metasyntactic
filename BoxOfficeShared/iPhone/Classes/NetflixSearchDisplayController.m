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

#import "NetflixSearchDisplayController.h"

#import "CacheUpdater.h"
#import "CommonNavigationController.h"
#import "Model.h"
#import "NetflixCell.h"
#import "NetflixSearchEngine.h"
#import "SearchResult.h"

@interface NetflixSearchDisplayController()
@property (retain) NSArray* movies;
@property (retain) NSArray* discMovies;
@property (retain) NSArray* instantMovies;
@end


@implementation NetflixSearchDisplayController

@synthesize movies;
@synthesize discMovies;
@synthesize instantMovies;

- (void) dealloc {
  self.movies = nil;
  self.discMovies = nil;
  self.instantMovies = nil;

  [super dealloc];
}


- (Model*) model {
  return [Model model];
}


- (void) setupDefaultScopeButtonTitles {
  self.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:LocalizedString(@"All", @"Option to show 'All' (i.e. non-filtered) results from a search"), LocalizedString(@"Disc", @"i.e. DVD or Bluray movie that comes on a 'Disc'"), LocalizedString(@"Instant", @"i.e. a streamable movie that can be watched 'Instant'ly"), nil];
}


- (id) initWithSearchBar:(UISearchBar*) searchBar_
     contentsController:(UIViewController*) viewController_ {
  if ((self = [super initWithSearchBar:searchBar_
                    contentsController:viewController_])) {
    self.searchBar.selectedScopeButtonIndex = self.model.netflixSearchSelectedScopeButtonIndex;
    self.searchBar.placeholder = LocalizedString(@"Search Netflix", nil);
  }

  return self;
}


- (AbstractSearchEngine*) createSearchEngine {
  return [NetflixSearchEngine engineWithDelegate:self];
}


- (void) searchBar:(UISearchBar*) searchBar selectedScopeButtonIndexDidChange:(NSInteger) selectedScope {
  self.model.netflixSearchSelectedScopeButtonIndex = selectedScope;
  [self reloadTableViewData];
}


- (BOOL) shouldShowAll {
  return self.searchBar.selectedScopeButtonIndex == 0;
}


- (BOOL) shouldShowDisc {
  return self.searchBar.selectedScopeButtonIndex == 1;
}


- (BOOL) shouldShowInstant {
  return self.searchBar.selectedScopeButtonIndex == 2;
}


- (BOOL) noResults {
  return
  searchResult != nil &&
  (movies.count == 0 || ![self shouldShowAll]) &&
  (discMovies.count == 0 || ![self shouldShowDisc]) &&
  (instantMovies.count == 0 || ![self shouldShowInstant]);
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
  return 1;
}


- (NSInteger)     tableView:(UITableView*) tableView
      numberOfRowsInSection:(NSInteger) section {
  if (searchResult == nil) {
    return 0;
  }

  if ([self noResults]) {
    return 0;
  }

  if ([self shouldShowAll]) {
    return movies.count;
  } else if ([self shouldShowDisc]) {
    return discMovies.count;
  } else if ([self shouldShowInstant]) {
    return instantMovies.count;
  } else {
    return 0;
  }
}


- (UITableViewCell*) netflixCellForMovie:(Movie*) movie {
  static NSString* reuseIdentifier = @"reuseIdentifier";

  NetflixCell* cell = (id)[self.searchResultsTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[NetflixCell alloc] initWithReuseIdentifier:reuseIdentifier] autorelease];
  }

  [cell setMovie:movie owner:nil];
  return cell;
}


- (UITableViewCell*) noResultsCell {
  UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
  cell.textLabel.text = [NSString stringWithFormat:LocalizedString(@"No results found for '%@'", nil), searchResult.value];
  return cell;
}


- (UITableViewCell*) tableView:(UITableView*) tableView_
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
  if ([self noResults]) {
    return [self noResultsCell];
  }

  Movie* movie = nil;
  if ([self shouldShowAll]) {
    movie = [movies objectAtIndex:indexPath.row];
  } else if ([self shouldShowDisc]) {
    movie = [discMovies objectAtIndex:indexPath.row];
  } else if ([self shouldShowInstant]) {
    movie = [instantMovies objectAtIndex:indexPath.row];
  } else {
    [[[UITableViewCell alloc] init] autorelease];
  }

  return [self netflixCellForMovie:movie];
}


- (void)            tableView:(UITableView*) tableView_
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
  Movie* movie = nil;
  if ([self shouldShowAll]) {
    movie = [movies objectAtIndex:indexPath.row];
  } else if ([self shouldShowDisc]) {
    movie = [discMovies objectAtIndex:indexPath.row];
  } else if ([self shouldShowInstant]) {
    movie = [instantMovies objectAtIndex:indexPath.row];
  } else {
    return;
  }

  [self.commonNavigationController pushMovieDetails:movie animated:YES];
}


- (CGFloat)         tableView:(UITableView*) tableView_
      heightForRowAtIndexPath:(NSIndexPath*) indexPath {
  if (searchResult != nil) {
    return 100;
  }

  return self.searchResultsTableView.rowHeight;
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
  if ([self noResults]) {
    return LocalizedString(@"No information found", nil);
  }

  return nil;
}


- (void) initializeData:(SearchResult*) result {
  NSMutableArray* discs = [NSMutableArray array];
  NSMutableArray* instant = [NSMutableArray array];

  for (Movie* movie in result.movies) {
    NSArray* formats = [self.model.netflixCache formatsForMovie:movie];
    if ([formats containsObject:@"instant"]) {
      [instant addObject:movie];
    } else {
      [discs addObject:movie];
    }
  }

  self.movies = result.movies;
  self.discMovies = discs;
  self.instantMovies = instant;

  self.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:
                                      [NSString stringWithFormat:LocalizedString(@"All (%d)", @"Used to display the count of all search results.  i.e.: All (15)"), movies.count],
                                      [NSString stringWithFormat:LocalizedString(@"Disc (%d)", @"Used to display the count of all dvd search results.  i.e.: Disc (15)"), discs.count],
                                      [NSString stringWithFormat:LocalizedString(@"Instant (%d)", @"Used to display the count of all instant watch search results.  i.e.: Instant (15)"), instant.count],
                                      nil];
}


- (void) reportResult:(SearchResult*) result {
  [self initializeData:result];
  [super reportResult:result];

  if (result.movies.count > 0) {
    // download the details for these movies in teh background.
    [[CacheUpdater cacheUpdater] addSearchMovies:result.movies];
  }
}

@end
