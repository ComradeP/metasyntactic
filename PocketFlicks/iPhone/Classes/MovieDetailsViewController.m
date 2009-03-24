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

#import "MovieDetailsViewController.h"

#import "AbstractNavigationController.h"
#import "ActionsView.h"
#import "ActivityIndicatorViewWithBackground.h"
#import "AlertUtilities.h"
#import "Application.h"
#import "CollapsedMovieDetailsCell.h"
#import "ColorCache.h"
#import "DateUtilities.h"
#import "ExpandedMovieDetailsCell.h"
#import "GlobalActivityIndicator.h"
#import "ImageCache.h"
#import "LargePosterCache.h"
#import "Movie.h"
#import "MovieOverviewCell.h"
#import "MutableNetflixCache.h"
#import "NetflixCell.h"
#import "NetflixRatingsCell.h"
#import "NetflixStatusCell.h"
#import "AppDelegate.h"
#import "Model.h"
#import "OperationQueue.h"
#import "PosterCache.h"
#import "Status.h"
#import "TappableImageView.h"
#import "Utilities.h"
#import "ViewControllerUtilities.h"

@interface MovieDetailsViewController()
@property (retain) Movie* movie;
@property (retain) Movie* netflixMovie;
@property (retain) NSArray* netflixStatusCells;
@property (retain) NetflixRatingsCell* netflixRatingsCell;
@property (copy) NSString* trailer;
@property (retain) NSDictionary* websites;
@property (retain) UIView* actionsView;
@property (retain) NSLock* posterDownloadLock;
@property (retain) UIImage* posterImage;
@property (retain) TappableImageView* posterImageView;
@property (retain) ActivityIndicatorViewWithBackground* posterActivityView;
@property (retain) CollapsedMovieDetailsCell* collapsedMovieDetailsCell;
@property (retain) ExpandedMovieDetailsCell* expandedMovieDetailsCell;
@end


@implementation MovieDetailsViewController

const NSInteger ADD_TO_NETFLIX_DISC_QUEUE_TAG = 1;
const NSInteger ADD_TO_NETFLIX_DISC_OR_INSTANT_QUEUE_TAG = 2;
const NSInteger ADD_TO_NETFLIX_INSTANT_QUEUE_TAG = 3;
const NSInteger VISIT_WEBSITES_TAG = 4;

const NSInteger POSTER_TAG = -1;

@synthesize movie;
@synthesize netflixMovie;
@synthesize netflixStatusCells;
@synthesize netflixRatingsCell;
@synthesize trailer;
@synthesize websites;
@synthesize actionsView;
@synthesize posterActivityView;
@synthesize posterDownloadLock;
@synthesize posterImage;
@synthesize posterImageView;
@synthesize collapsedMovieDetailsCell;
@synthesize expandedMovieDetailsCell;

- (void) dealloc {
    self.movie = nil;
    self.netflixMovie = nil;
    self.netflixStatusCells = nil;
    self.netflixRatingsCell = nil;
    self.trailer = nil;
    self.websites = nil;
    self.actionsView = nil;
    self.posterActivityView = nil;
    self.posterDownloadLock = nil;
    self.posterImage = nil;
    self.posterImageView = nil;
    self.collapsedMovieDetailsCell = nil;
    self.expandedMovieDetailsCell = nil;

    [super dealloc];
}


- (void) setupActionsView {
    NSMutableArray* selectors = [NSMutableArray array];
    NSMutableArray* titles = [NSMutableArray array];
    NSMutableArray* arguments = [NSMutableArray array];

    if (trailer.length > 0) {
        [selectors addObject:[NSValue valueWithPointer:@selector(playTrailer)]];
        [titles addObject:NSLocalizedString(@"Play trailer", nil)];
        [arguments addObject:[NSNull null]];
    }

    if (netflixMovie != nil && netflixStatusCells.count == 0) {
        [selectors addObject:[NSValue valueWithPointer:@selector(addToQueue)]];
        [titles addObject:NSLocalizedString(@"Add to Netflix", nil)];
        [arguments addObject:[NSNull null]];
    }

    if ((selectors.count + websites.count) > 6) {
        // condense to one button
        [selectors addObject:[NSValue valueWithPointer:@selector(visitWebsites)]];
        [titles addObject:NSLocalizedString(@"Websites", nil)];
        [arguments addObject:[NSNull null]];
    } else {
        // show individual buttons
        for (NSString* name in [websites.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
            [selectors addObject:[NSValue valueWithPointer:@selector(visitWebsite:)]];
            NSString* title = [NSString stringWithFormat:NSLocalizedString(@"Visit %@", nil), name];
            [titles addObject:title];
            [arguments addObject:[websites objectForKey:name]];
        }
    }

    if (selectors.count == 0) {
        return;
    }

    self.actionsView = [ActionsView viewWithTarget:self
                                         selectors:selectors
                                            titles:titles
                                         arguments:arguments];

    [actionsView sizeToFit];
}


+ (UIImage*) posterForMovie:(Movie*) movie model:(Model*) model {
    UIImage* image = [model posterForMovie:movie];
    if (image == nil) {
        image = [ImageCache imageNotAvailable];
    }
    return image;
}


- (void) initializeWebsites {
    NSMutableDictionary* map = [NSMutableDictionary dictionary];
    NSString* imdbAddress = [self.model imdbAddressForMovie:movie];
    if (imdbAddress.length > 0) {
        [map setObject:imdbAddress forKey:@"IMDb"];
    }

    NSString* amazonAddress = [self.model amazonAddressForMovie:movie];
    if (amazonAddress.length > 0) {
        [map setObject:amazonAddress forKey:@"Amazon"];
    }

    NSString* wikipediaAddress = [self.model wikipediaAddressForMovie:movie];
    if (wikipediaAddress.length > 0) {
        [map setObject:wikipediaAddress forKey:@"Wikipedia"];
    }

    NSString* netflixAddress = [self.model netflixAddressForMovie:movie];
    if (netflixAddress.length > 0) {
        [map setObject:netflixAddress forKey:@"Netflix"];
    }

    self.websites = map;
}


- (void) updateImage {
    self.posterImage = [MovieDetailsViewController posterForMovie:movie model:self.model];
    self.posterImageView.image = posterImage;
}


- (void) initializeNetflixStatusCells {
    NSArray* statuses = [self.model.netflixCache statusesForMovie:movie];

    NSMutableArray* cells = [NSMutableArray array];
    for (NSInteger i = 0; i < statuses.count; i++) {
        Status* status = [statuses objectAtIndex:i];
        NetflixStatusCell* cell = [[[NetflixStatusCell alloc] initWithStatus:status] autorelease];
        cell.moveImageView.delegate = self;
        cell.deleteImageView.delegate = self;

        cell.moveImageView.tag = 2 * i;
        cell.deleteImageView.tag = 2 * i + 1;

        [cells addObject:cell];
    }

    self.netflixStatusCells = cells;
}


- (void) initializeData {
    self.netflixMovie = [self.model.netflixCache netflixMovieForMovie:movie];
    [self initializeNetflixStatusCells];

    NSArray* trailers = [self.model trailersForMovie:movie];
    if (trailers.count > 0) {
        self.trailer = [trailers objectAtIndex:0];
    }

    [self initializeWebsites];
    [self updateImage];
    [self setupActionsView];
}


- (void) setupPosterView {
    self.posterImage = [MovieDetailsViewController posterForMovie:movie model:self.model];
    self.posterImageView = [[[TappableImageView alloc] initWithImage:posterImage] autorelease];
    posterImageView.tag = POSTER_TAG;
    posterImageView.delegate = self;
}


- (id) initWithNavigationController:(AbstractNavigationController*) controller
                              movie:(Movie*) movie_ {
    if (self = [super initWithNavigationController:controller]) {
        self.movie = movie_;
        self.posterDownloadLock = [[[NSRecursiveLock alloc] init] autorelease];

        // Only want to do this once.
        self.posterActivityView = [[[ActivityIndicatorViewWithBackground alloc] init] autorelease];
        [posterActivityView startAnimating];
        [posterActivityView sizeToFit];
    }

    return self;
}


- (void) setupTitle {
    if (readonlyMode) {
        UILabel* label = [ViewControllerUtilities viewControllerTitleLabel];
        label.text = NSLocalizedString(@"Please Wait", nil);

        self.navigationItem.titleView = label;
    } else {
        UILabel* label = [ViewControllerUtilities viewControllerTitleLabel];
        label.text = movie.displayTitle;

        self.title = movie.displayTitle;
        self.navigationItem.titleView = label;
    }
}


- (void) setupButtons {
    if (readonlyMode) {
        UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGRect frame = activityIndicatorView.frame;
        frame.size.width += 4;
        [activityIndicatorView startAnimating];

        UIView* activityView = [[UIView alloc] initWithFrame:frame];
        [activityView addSubview:activityIndicatorView];

        UIBarButtonItem* right = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
        [self.navigationItem setRightBarButtonItem:right animated:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];
    } else {
        UIBarButtonItem* right = [[[UIBarButtonItem alloc] initWithCustomView:[AppDelegate globalActivityView]] autorelease];
        [self.navigationItem setRightBarButtonItem:right animated:YES];
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}


- (void) loadView {
    [super loadView];

    [self setupTitle];
    [self setupPosterView];
    [self setupButtons];

    [self.model prioritizeMovie:movie];
}


- (void) viewDidAppear:(BOOL) animated {
    visible = YES;
}


- (void) viewDidDisappear:(BOOL) animated {
    visible = NO;
}


- (void) didReceiveMemoryWarning {
    if (visible) {
        return;
    }

    if (readonlyMode) {
        return;
    }

    self.trailer = nil;
    self.websites = nil;
    self.actionsView = nil;
    self.posterImage = nil;
    self.posterImageView = nil;
    self.posterActivityView = nil;

    [super didReceiveMemoryWarning];
}


- (void) downloadPosterBackgroundEntryPoint {
    [self.model.largePosterCache downloadFirstPosterForMovie:movie];
    NSInteger posterCount_ = [self.model.largePosterCache posterCountForMovie:movie];

    [self performSelectorOnMainThread:@selector(reportPoster:)
                           withObject:[NSNumber numberWithInt:posterCount_]
                        waitUntilDone:NO];
}


- (void) reportPoster:(NSNumber*) posterNumber {
    NSAssert([NSThread isMainThread], nil);
    if (!self.visible) { return; }
    posterCount = [posterNumber intValue];
    [posterActivityView stopAnimating];
    [self minorRefresh];
}


- (void) downloadPoster {
    if (posterLoaded) {
        return;
    }
    posterLoaded = YES;
    
    [[AppDelegate operationQueue] performSelector:@selector(downloadPosterBackgroundEntryPoint)
                                         onTarget:self
                                             gate:nil
                                         priority:High];
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    
    [self downloadPoster];
    [self majorRefresh];
}


- (void) removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
}


- (void) viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
    [posterActivityView stopAnimating];

    [self removeNotifications];
}


- (void) minorRefresh {
    [self majorRefresh];
}


- (void) majorRefresh {
    if (readonlyMode) {
        return;
    }

    [self initializeData];
    [netflixRatingsCell refresh];
    [self.tableView reloadData];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 2;
}


- (BOOL) hasNetflixRating {
    return [self.model.netflixCache netflixRatingForMovie:movie].length > 0;
}


- (NSInteger)     tableView:(UITableView*) tableView
      numberOfRowsInSection:(NSInteger) section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1 + netflixStatusCells.count;
    }

    return 0;
}


- (UITableViewCell*) createNetflixRatingsCell {
    if (netflixRatingsCell == nil) {
        self.netflixRatingsCell =
        [[[NetflixRatingsCell alloc] initWithFrame:CGRectZero
                                             movie:movie] autorelease];
    }

    return netflixRatingsCell;
}


- (UITableViewCell*) createExpandedMovieDetailsCell {
    if (expandedMovieDetailsCell == nil) {
        self.expandedMovieDetailsCell =
        [[[ExpandedMovieDetailsCell alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
                                                   movie:movie] autorelease];
    }

    return expandedMovieDetailsCell;
}


- (UITableViewCell*) createCollapsedMovieDetailsCell {
    if (collapsedMovieDetailsCell == nil) {
        self.collapsedMovieDetailsCell =
        [[[CollapsedMovieDetailsCell alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
                                                    movie:movie] autorelease];
    }

    return collapsedMovieDetailsCell;
}


- (UITableViewCell*) cellForHeaderRow:(NSInteger) row {
    if (row == 0) {
        return [MovieOverviewCell cellWithMovie:movie
                                          model:self.model
                                          frame:[UIScreen mainScreen].applicationFrame
                                    posterImage:posterImage
                                posterImageView:posterImageView
                                   activityView:posterActivityView];
    }

    if (expandedDetails) {
        return [self createExpandedMovieDetailsCell];
    } else {
        return [self createCollapsedMovieDetailsCell];
    }
}


- (CGFloat) heightForNetflixRatingRow {
    if ([self hasNetflixRating]) {
        return self.tableView.rowHeight;
    } else {
        return 0;
    }
}


- (CGFloat) heightForRowInNetflixSection:(NSInteger) row {
    if (row == 0) {
        return [self heightForNetflixRatingRow];
    } else {
        return self.tableView.rowHeight;
    }
}


- (CGFloat) heightForRowInHeaderSection:(NSInteger) row {
    if (row == 0) {
        return [MovieOverviewCell heightForMovie:movie model:self.model];
    }

    AbstractMovieDetailsCell* cell = (AbstractMovieDetailsCell*)[self cellForHeaderRow:row];
    return [cell height:self.tableView];
}


- (CGFloat)         tableView:(UITableView*) tableView
      heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        return [self heightForRowInHeaderSection:indexPath.row];
    } else {
        return [self heightForRowInNetflixSection:indexPath.row];
    }
}


- (UIView*)        tableView:(UITableView*) tableView
      viewForFooterInSection:(NSInteger) section {
    if (section == 0) {
        return actionsView;
    }

    return nil;
}


- (CGFloat)          tableView:(UITableView*) tableView
      heightForFooterInSection:(NSInteger) section {
    if (section == 0) {
        CGFloat height = [actionsView height];

        return height + 8;
    }

    return -1;
}


- (UITableViewCell*) cellForNetflixRow:(NSInteger) row {
    if (row == 0) {
        return [self createNetflixRatingsCell];
    } else {
        return [netflixStatusCells objectAtIndex:row - 1];
    }
}


- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        return [self cellForHeaderRow:indexPath.row];
    } else if (indexPath.section == 1) {
        return [self cellForNetflixRow:indexPath.row];
    }

    return nil;
}


- (void) playTrailer {
    NSString* urlString = trailer;
    MPMoviePlayerController* moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:urlString]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedPlaying:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];

    [moviePlayer play];
}


- (void) movieFinishedPlaying:(NSNotification*) notification {
    [self removeNotifications];

    MPMoviePlayerController* moviePlayer = notification.object;
    [moviePlayer stop];
    [moviePlayer autorelease];
}


- (void) visitWebsite:(NSString*) website {
    [navigationController pushBrowser:website animated:YES];
}


- (void) visitWebsites {
    UIActionSheet* actionSheet =
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:nil
                   destructiveButtonTitle:nil
                        otherButtonTitles:nil] autorelease];
    actionSheet.tag = VISIT_WEBSITES_TAG;

    NSArray* keys = [websites.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString* key in keys) {
        [actionSheet addButtonWithTitle:key];
    }

    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = keys.count;

    [actionSheet showInView:[AppDelegate window]];
}


- (void) setupStatusCells {
    for (NetflixStatusCell* cell in netflixStatusCells) {
        [cell enterReadonlyMode];
    }
}


- (void) enterReadonlyMode {
    if (readonlyMode) {
        return;
    }
    readonlyMode = YES;

    [self setupTitle];
    [self setupButtons];
    [self setupStatusCells];
}


- (void) exitReadonlyMode {
    readonlyMode = NO;
    [self setupTitle];
    [self setupButtons];
}


- (void) netflixOperationSucceeded {
    [self exitReadonlyMode];
    [self majorRefresh];
}


- (void) netflixOperationFailedWithError:(NSString*) error {
    [AlertUtilities showOkAlert:error];
    [self exitReadonlyMode];
    [self majorRefresh];
}


- (void) addSucceeded {
    [self netflixOperationSucceeded];
}


- (void) addFailedWithError:(NSString*) error {
    [self netflixOperationFailedWithError:error];
}


- (void) moveSucceededForMovie:(Movie*) movie {
    [self netflixOperationSucceeded];
}


- (void) moveFailedWithError:(NSString*) error {
    [self netflixOperationFailedWithError:error];
}


- (void) modifySucceeded {
    [self netflixOperationSucceeded];
}


- (void) modifyFailedWithError:(NSString*) error {
    [self netflixOperationFailedWithError:error];
}


- (void) addToQueue {
    if (readonlyMode) {
        return;
    }

    UIActionSheet* actionSheet =
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:nil
                   destructiveButtonTitle:nil
                        otherButtonTitles:nil] autorelease];

    NSArray* formats = [self.model.netflixCache formatsForMovie:netflixMovie];

    if ([formats containsObject:@"instant"]) {
        if (formats.count == 1) {
            actionSheet.tag = ADD_TO_NETFLIX_INSTANT_QUEUE_TAG;
        } else {
            actionSheet.tag = ADD_TO_NETFLIX_DISC_OR_INSTANT_QUEUE_TAG;
        }
    } else {
        actionSheet.tag = ADD_TO_NETFLIX_DISC_QUEUE_TAG;
    }

    // we always offer the Disc queue unless the movie is instant-only.
    // (rare, but it does happen).
    if (!(formats.count == 1 && [formats containsObject:@"instant"])) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Disc Queue", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Top of Disc Queue", nil)];
    }

    if ([formats containsObject:@"instant"]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Instant Queue", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Top of Instant Queue", nil)];
    }

    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;

    [actionSheet showInView:[AppDelegate window]];
}


- (void) didDismissAddToNetflixQueue:(Queue*) queue
                     withButtonIndex:(NSInteger) buttonIndex {
    [self enterReadonlyMode];
    if (buttonIndex % 2 == 0) {
        [self.model.netflixCache updateQueue:queue byAddingMovie:netflixMovie delegate:self];
    } else {
        [self.model.netflixCache updateQueue:queue byAddingMovie:netflixMovie toPosition:0 delegate:self];
    }
}


- (void) didDismissAddToNetflixDiscQueueActionSheet:(UIActionSheet*) actionSheet
                                             withButtonIndex:(NSInteger) buttonIndex {
    Queue* queue = [self.model.netflixCache queueForKey:[NetflixCache dvdQueueKey]];
    [self didDismissAddToNetflixQueue:queue withButtonIndex:buttonIndex];
}


- (void) didDismissAddToNetflixInstantQueueActionSheet:(UIActionSheet*) actionSheet
                                    withButtonIndex:(NSInteger) buttonIndex {
    Queue* queue = [self.model.netflixCache queueForKey:[NetflixCache instantQueueKey]];
    [self didDismissAddToNetflixQueue:queue withButtonIndex:buttonIndex];

}


- (void) didDismissAddToNetflixDiscOrInstantQueueActionSheet:(UIActionSheet*) actionSheet
                           withButtonIndex:(NSInteger) buttonIndex {
    Queue* queue;
    if (buttonIndex <= 1) {
        queue = [self.model.netflixCache queueForKey:[NetflixCache dvdQueueKey]];
    } else {
        queue = [self.model.netflixCache queueForKey:[NetflixCache instantQueueKey]];
    }
    [self didDismissAddToNetflixQueue:queue withButtonIndex:buttonIndex];
}


- (void) didDismissVisitWebsitesActionSheet:(UIActionSheet*) actionSheet
                            withButtonIndex:(NSInteger) buttonIndex {
    NSString* url = [websites objectForKey:[actionSheet buttonTitleAtIndex:buttonIndex]];
    [navigationController pushBrowser:url animated:YES];
}


- (void)            actionSheet:(UIActionSheet*) actionSheet
      didDismissWithButtonIndex:(NSInteger) buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }

    if (actionSheet.tag == ADD_TO_NETFLIX_DISC_QUEUE_TAG) {
        [self didDismissAddToNetflixDiscQueueActionSheet:actionSheet
                                withButtonIndex:buttonIndex];
    } else if (actionSheet.tag == ADD_TO_NETFLIX_DISC_OR_INSTANT_QUEUE_TAG) {
        [self didDismissAddToNetflixDiscOrInstantQueueActionSheet:actionSheet
                                         withButtonIndex:buttonIndex];

    } else if (actionSheet.tag == ADD_TO_NETFLIX_INSTANT_QUEUE_TAG) {
        [self didDismissAddToNetflixInstantQueueActionSheet:actionSheet
                                         withButtonIndex:buttonIndex];
    } else if (actionSheet.tag == VISIT_WEBSITES_TAG) {
        [self didDismissVisitWebsitesActionSheet:actionSheet
                                 withButtonIndex:buttonIndex];
    }
}


- (void)       tableView:(UITableView*) tableView
      didSelectHeaderRow:(NSInteger) row {
    if (row == 1) {
        expandedDetails = !expandedDetails;

        NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:0];
        [tableView beginUpdates];
        {
            NSArray* paths = [NSArray arrayWithObject:path];
            [tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        }
        [tableView endUpdates];

        //[tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        // hack: when shrinking the details pane, the 'actions view' can
        // sometimes go missing.  To prevent that, we refresh explicitly.
        if (!expandedDetails) {
            [self.tableView reloadData];
        }
    }
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        [self tableView:tableView didSelectHeaderRow:indexPath.row];
    }
}


- (UITableViewCellAccessoryType) tableView:(UITableView*) tableView
          accessoryTypeForRowWithIndexPath:(NSIndexPath*) indexPath {
    return UITableViewCellAccessoryNone;
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    [self majorRefresh];
}


- (void) posterImageViewWasTapped {
    if (!UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return;
    }

    if (posterCount == 0) {
        return;
    }
    
    [[AppDelegate operationQueue] performSelector:@selector(downloadAllPostersForMovie:)
                                         onTarget:self.model.largePosterCache
                                       withObject:movie
                                             gate:nil
                                         priority:High];

    [navigationController showPostersView:movie posterCount:posterCount];
}


- (void) moveMovieWasTappedForRow:(NSInteger) row {
    [self enterReadonlyMode];

    NetflixStatusCell* cell = [netflixStatusCells objectAtIndex:row];
    Status* status = [cell status];
    [self.model.netflixCache updateQueue:status.queue byMovingMovieToTop:status.movie delegate:self];
}


- (void) deleteMovieWasTappedForRow:(NSInteger) row {
    [self enterReadonlyMode];

    NetflixStatusCell* cell = [netflixStatusCells objectAtIndex:row];
    Status* status = [cell status];
    [self.model.netflixCache updateQueue:status.queue byDeletingMovie:status.movie delegate:self];
}


- (void) imageView:(TappableImageView*) imageView
         wasTapped:(NSInteger) tapCount {
    if (imageView.tag == POSTER_TAG) {
        [self posterImageViewWasTapped];
    } else if (imageView.tag % 2 == 0) {
        [self moveMovieWasTappedForRow:imageView.tag / 2];
    } else {
        [self deleteMovieWasTappedForRow:imageView.tag / 2];
    }
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
    if (section == 1) {
        return NSLocalizedString(@"Netflix", nil);
    }

    return nil;
}

@end