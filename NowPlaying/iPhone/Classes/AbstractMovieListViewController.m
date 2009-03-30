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

#import "AbstractMovieListViewController.h"

#import "Application.h"
#import "DateUtilities.h"
#import "ImageCache.h"
#import "LocalSearchDisplayController.h"
#import "LocaleUtilities.h"
#import "Model.h"
#import "Movie.h"
#import "MoviesNavigationController.h"
#import "MutableMultiDictionary.h"
#import "SettingsViewController.h"
#import "StringUtilities.h"
#import "UITableViewCell+Utilities.h"
#import "Utilities.h"


@interface AbstractMovieListViewController()
#ifdef IPHONE_OS_VERSION_3
@property (retain) UISearchBar* searchBar;
@property (retain) LocalSearchDisplayController* searchDisplayController;
#endif
@property (retain) NSArray* sortedMovies;
@property (retain) NSArray* sectionTitles;
@property (retain) MultiDictionary* sectionTitleToContentsMap;
@property (retain) NSArray* indexTitles;
@end


@implementation AbstractMovieListViewController

#ifdef IPHONE_OS_VERSION_3
@synthesize searchBar;
@synthesize searchDisplayController;
#endif
@synthesize sortedMovies;
@synthesize sectionTitles;
@synthesize sectionTitleToContentsMap;
@synthesize indexTitles;

- (void) dealloc {
#ifdef IPHONE_OS_VERSION_3
    self.searchBar = nil;
    self.searchDisplayController = nil;
#endif
    self.sortedMovies = nil;
    self.sectionTitles = nil;
    self.sectionTitleToContentsMap = nil;
    self.indexTitles = nil;

    [super dealloc];
}


- (Model*) model {
    return [Model model];
}


- (NSArray*) movies {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (BOOL) sortingByTitle {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (BOOL) sortingByReleaseDate {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (BOOL) sortingByScore {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (void) onSortOrderChanged:(id) sender {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (UITableViewCell*) createCell:(Movie*) movie {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (int(*)(id,id,void*)) sortByReleaseDateFunction {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (void) removeUnusedSectionTitles {
    NSMutableArray* array = [NSMutableArray arrayWithArray:sectionTitles];

    for (NSInteger i = array.count - 1; i >= 0; --i) {
        NSString* title = [array objectAtIndex:i];

        if ([[sectionTitleToContentsMap objectsForKey:title] count] == 0) {
            [array removeObjectAtIndex:i];
        }
    }

    self.sectionTitles = array;
}


- (unichar) firstCharacter:(NSString*) string {
    unichar c1 = toupper([string characterAtIndex:0]);
    if (c1 < 'A' || c1 > 'Z') {
        // remove an accent if it exists.
        NSString* asciiString = [StringUtilities asciiString:string];
        unichar c2 = toupper([asciiString characterAtIndex:0]);
        if (c2 >= 'A' && c2 <= 'Z') {
            return c2;
        }
    }

    return c1;
}


- (void) sortMoviesByTitle {
    self.sortedMovies = [self.movies sortedArrayUsingFunction:compareMoviesByTitle context:nil];

    BOOL prioritizeBookmarks = self.model.prioritizeBookmarks;
    MutableMultiDictionary* map = [MutableMultiDictionary dictionary];

    for (Movie* movie in sortedMovies) {
        if (prioritizeBookmarks && [self.model isBookmarked:movie]) {
            [map addObject:movie forKey:[Application starString]];
            continue;
        }

        NSString* title = movie.displayTitle;
        unichar firstChar = [self firstCharacter:title];

        if ([LocaleUtilities isJapanese]) {
            if (CFCharacterSetIsCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetLetter), firstChar)) {
                NSString* sectionTitle = [[[NSString alloc] initWithCharacters:&firstChar length:1] autorelease];
                [map addObject:movie forKey:sectionTitle];
            } else {
                [map addObject:movie forKey:@"#"];
            }
        } else {
            if (firstChar >= 'A' && firstChar <= 'Z') {
                NSString* sectionTitle = [NSString stringWithFormat:@"%c", firstChar];
                [map addObject:movie forKey:sectionTitle];
            } else {
                [map addObject:movie forKey:@"#"];
            }
        }
    }

    if ([LocaleUtilities isJapanese]) {
        NSMutableArray* array = [NSMutableArray arrayWithArray:sectionTitleToContentsMap.allKeys];
        [array sortUsingSelector:@selector(compare:)];
        [array insertObject:[Application starString] atIndex:0];

        self.sectionTitles = array;
    } else {
        self.sectionTitles = self.indexTitles;
    }

    self.sectionTitleToContentsMap = map;
}


- (void) sortMoviesByScore {
    self.sortedMovies = [self.movies sortedArrayUsingFunction:compareMoviesByScore context:self.model];

    BOOL prioritizeBookmarks = self.model.prioritizeBookmarks;

    NSString* bookmarksString = [Application starString];
    NSString* moviesString = NSLocalizedString(@"Movies", nil);

    self.sectionTitles = [NSMutableArray arrayWithObjects:bookmarksString, moviesString, nil];
    MutableMultiDictionary* map = [MutableMultiDictionary dictionary];

    for (Movie* movie in sortedMovies) {
        if (prioritizeBookmarks && [self.model isBookmarked:movie]) {
            [map addObject:movie forKey:bookmarksString];
        } else {
            [map addObject:movie forKey:moviesString];
        }
    }

    self.sectionTitleToContentsMap = map;
}


- (void) sortMoviesByReleaseDate {
    self.sortedMovies = [self.movies sortedArrayUsingFunction:self.sortByReleaseDateFunction context:self.model];

    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:kCFDateFormatterMediumStyle];
    [formatter setTimeStyle:kCFDateFormatterNoStyle];

    NSDate* today = [DateUtilities today];

    BOOL prioritizeBookmarks = self.model.prioritizeBookmarks;

    NSString* starString = [Application starString];

    NSMutableArray* array = [NSMutableArray array];
    MutableMultiDictionary* map = [MutableMultiDictionary dictionary];

    for (Movie* movie in sortedMovies) {
        if (prioritizeBookmarks && [self.model isBookmarked:movie]) {
            [map addObject:movie forKey:starString];
            if (![array containsObject:starString]) {
                [array insertObject:starString atIndex:0];
            }
        } else {
            NSString* title = NSLocalizedString(@"Unknown Release Ddate", nil);
            NSDate* releaseDate = [self.model releaseDateForMovie:movie];

            if (releaseDate != nil) {
                if ([releaseDate compare:today] == NSOrderedDescending) {
                    title = [DateUtilities formatFullDate:releaseDate];
                } else {
                    title = [DateUtilities timeSinceNow:releaseDate];
                }
            }

            [map addObject:movie forKey:title];

            if (![array containsObject:title]) {
                [array addObject:title];
            }
        }
    }
    self.sectionTitles = array;

    for (NSString* key in map.allKeys) {
        if (![starString isEqual:key]) {
            NSMutableArray* values = [map mutableObjectsForKey:key];
            [values sortUsingFunction:compareMoviesByScore context:self.model];
        }
    }

    self.sectionTitleToContentsMap = map;
}


- (void) setupIndexTitles {
    if ([LocaleUtilities isJapanese]) {
        self.indexTitles = nil;
    } else {
        NSMutableArray* array = [NSMutableArray array];

#ifdef IPHONE_OS_VERSION_3
        [array addObject:UITableViewIndexSearch];
#endif
        if (self.model.prioritizeBookmarks) {
            [array addObject:[Application starString]];
        }

        [array addObjectsFromArray:[NSArray arrayWithObjects:
                                 @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H",
                                 @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q",
                                 @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil]];

        self.indexTitles = array;
    }
}


- (void) sortMovies {
    [self setupIndexTitles];
    self.sectionTitles = [NSMutableArray array];

    if (self.sortingByTitle) {
        [self sortMoviesByTitle];
    } else if (self.sortingByReleaseDate) {
        [self sortMoviesByReleaseDate];
    } else if (self.sortingByScore) {
        [self sortMoviesByScore];
    }

    [self removeUnusedSectionTitles];

    if (sectionTitles.count == 0) {
        self.sectionTitles = [NSArray arrayWithObject:self.model.noInformationFound];
    }
}


- (id) init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
    }

    return self;
}


- (void) initializeInfoButton {
    UIButton* infoButton = [[UIButton buttonWithType:UIButtonTypeInfoLight] retain];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];

    infoButton.contentMode = UIViewContentModeCenter;
    CGRect frame = infoButton.frame;
    frame.size.width += 4;
    infoButton.frame = frame;
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease];
}


- (void) initializeSearchDisplay {
#ifdef IPHONE_OS_VERSION_3
    self.searchBar = [[[UISearchBar alloc] init] autorelease];
    [searchBar sizeToFit];
    self.tableView.tableHeaderView = searchBar;

    self.searchDisplayController = [[[LocalSearchDisplayController alloc] initWithSearchBar:searchBar
                                                                         contentsController:self] autorelease];
#else
    UIButton* searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.showsTouchWhenHighlighted = YES;
    UIImage* image = [ImageCache searchImage];
    [searchButton setImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self.navigationController action:@selector(showSearchView) forControlEvents:UIControlEventTouchUpInside];

    CGRect frame = searchButton.frame;
    frame.origin.x += 0.5;
    frame.size = image.size;
    frame.size.width += 7;
    frame.size.height += 7;
    searchButton.frame = frame;

    UIBarButtonItem* item = [[[UIBarButtonItem alloc] initWithCustomView:searchButton] autorelease];
    self.navigationItem.rightBarButtonItem = item;
#endif
}


- (void) loadView {
    [super loadView];

    self.sortedMovies = [NSArray array];

    [self initializeSearchDisplay];
    [self initializeInfoButton];
}


- (void) didReceiveMemoryWarningWorker {
    [super didReceiveMemoryWarningWorker];
    self.sortedMovies = nil;
    self.sectionTitles = nil;
    self.sectionTitleToContentsMap = nil;
    self.indexTitles = nil;
}


- (BOOL) tryScrollToCurrentDate {
    if (self.sortingByReleaseDate) {
        if (scrollToCurrentDateOnRefresh) {
            scrollToCurrentDateOnRefresh = NO;

            NSArray* movies = [self.movies sortedArrayUsingFunction:self.sortByReleaseDateFunction context:self.model];
            NSDate* today = [DateUtilities today];

            NSDate* date = nil;
            for (Movie* movie in movies) {
                NSDate* releaseDate = [self.model releaseDateForMovie:movie];

                if (releaseDate != nil) {
                    if ([releaseDate compare:today] == NSOrderedDescending) {
                        date = releaseDate;
                        break;
                    }
                }
            }

            if (date != nil) {
                NSString* title = [DateUtilities formatFullDate:date];
                NSInteger section = [sectionTitles indexOfObject:title];

                if (section >= 0 && section < sectionTitles.count) {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    return YES;
                }
            }
        }
    }

    return NO;
}


- (void) minorRefreshWorker {
#ifdef IPHONE_OS_VERSION_3
    [searchDisplayController minorRefresh];
#endif
}


- (void) majorRefreshWorker {
    [self sortMovies];
    [self reloadTableViewData];

    [self tryScrollToCurrentDate];


#ifdef IPHONE_OS_VERSION_3
    [searchDisplayController majorRefresh];
#endif
}


- (BOOL) outOfBounds:(NSIndexPath*) indexPath {
    if (indexPath.section < 0 || indexPath.section >= sectionTitles.count) {
        return YES;
    }

    NSArray* movies = [sectionTitleToContentsMap objectsForKey:[sectionTitles objectAtIndex:indexPath.section]];
    if (indexPath.row < 0 || indexPath.row >= movies.count) {
        return YES;
    }

    return NO;
}


- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    if ([self outOfBounds:indexPath]) {
        return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    }

    Movie* movie = [[sectionTitleToContentsMap objectsForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    UITableViewCell* cell = [self createCell:movie];
    if (self.sortingByTitle && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if ([self outOfBounds:indexPath]) {
        return;
    }

    Movie* movie = [[sectionTitleToContentsMap objectsForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    [self.abstractNavigationController pushMovieDetails:movie animated:YES];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return sectionTitles.count;
}


- (NSInteger)     tableView:(UITableView*) tableView
      numberOfRowsInSection:(NSInteger) section {
    return [[sectionTitleToContentsMap objectsForKey:[sectionTitles objectAtIndex:section]] count];
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
    NSString* title = [sectionTitles objectAtIndex:section];

    if (self.sortingByScore) {
        // Hide the header if sorting by score and we have no bookmarked movies
        if (sectionTitles.count == 1 && [NSLocalizedString(@"Movies", nil) isEqual:title]) {
            return nil;
        }
    }

    if ([title isEqual:[Application starString]]) {
        return NSLocalizedString(@"Bookmarks", nil);
    }

    return title;
}


- (NSArray*) sectionIndexTitlesForTableView:(UITableView*) tableView {
    if (self.sortingByTitle &&
        self.sortedMovies.count > 0 &&
        UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return indexTitles;
    }

    return nil;
}


- (NSInteger)           tableView:(UITableView*) tableView
      sectionForSectionIndexTitle:(NSString*) title
                          atIndex:(NSInteger) index {
    unichar firstChar = [title characterAtIndex:0];

#ifdef IPHONE_OS_VERSION_3
    if ([UITableViewIndexSearch isEqual:title]) {
        [self.tableView scrollRectToVisible:searchBar.frame animated:NO];
        return -1;
    } else
#endif
    if (firstChar == '#') {
        return [sectionTitles indexOfObject:@"#"];
    } else if (firstChar == [Application starCharacter]) {
        return [sectionTitles indexOfObject:[Application starString]];
    } else {
        for (unichar c = firstChar; c >= 'A'; c--) {
            NSString* s = [NSString stringWithFormat:@"%c", c];

            NSInteger result = [sectionTitles indexOfObject:s];
            if (result != NSNotFound) {
                return result;
            }
        }

        return NSNotFound;
    }
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    [self majorRefresh];
}


- (void) showInfo {
    [self.abstractNavigationController pushInfoControllerAnimated:YES];
}

@end