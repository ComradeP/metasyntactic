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

#import "NetflixQueueViewController.h"

#import "AbstractNavigationController.h"
#import "AlertUtilities.h"
#import "AppDelegate.h"
#import "ImageCache.h"
#import "Feed.h"
#import "GlobalActivityIndicator.h"
#import "MutableNetflixCache.h"
#import "NetflixCell.h"
#import "Model.h"
#import "IdentitySet.h"
#import "Queue.h"
#import "TappableImageView.h"
#import "ViewControllerUtilities.h"

@interface NetflixQueueViewController()
@property (assign) AbstractNavigationController* navigationController;
@property (copy) NSString* feedKey;
@property (retain) Feed* feed;
@property (retain) Queue* queue;
@property (retain) NSMutableArray* mutableMovies;
@property (retain) NSMutableArray* mutableSaved;
@property (retain) IdentitySet* deletedMovies;
@property (retain) IdentitySet* reorderedMovies;
@property (retain) UIBarButtonItem* backButton;
@property (retain) NSArray* visibleIndexPaths;
@end


@implementation NetflixQueueViewController

@synthesize navigationController;
@synthesize feedKey;
@synthesize feed;
@synthesize queue;
@synthesize mutableMovies;
@synthesize mutableSaved;
@synthesize deletedMovies;
@synthesize reorderedMovies;
@synthesize backButton;
@synthesize visibleIndexPaths;

- (void) dealloc {
    self.navigationController = nil;
    self.feedKey = nil;
    self.feed = nil;
    self.queue = nil;
    self.mutableMovies = nil;
    self.mutableSaved = nil;
    self.deletedMovies = nil;
    self.reorderedMovies = nil;
    self.backButton = nil;
    self.visibleIndexPaths = nil;
    
    [super dealloc];
}


- (BOOL) isEditable {
    return queue.isDVDQueue || queue.isInstantQueue;
}


- (void) setupButtons {
    if (readonlyMode) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        
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
        [self.navigationItem setHidesBackButton:NO animated:NO];
        UIBarButtonItem* left;
        UIBarButtonItem* right;
        if (self.tableView.editing) {
            left = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)] autorelease];
            right = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSave:)] autorelease];
        } else if (self.isEditable) {
            left = backButton;
            right = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit:)] autorelease];
        } else {
            left = backButton;
            right = nil;
        }
        
        [self.navigationItem setLeftBarButtonItem:left animated:YES];
        [self.navigationItem setRightBarButtonItem:right animated:YES];
    }
}


- (id) initWithNavigationController:(AbstractNavigationController*) navigationController_
                            feedKey:(NSString*) feedKey_ {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.navigationController = navigationController_;
        self.feedKey = feedKey_;
        self.backButton = self.navigationItem.leftBarButtonItem;
        [self setupButtons];
    }
    
    return self;
}


- (Model*) model {
    return navigationController.model;
}


- (Controller*) controller {
    return navigationController.controller;
}


- (void) setupTitle {
    NSString* text;
    if (readonlyMode) {
        text = NSLocalizedString(@"Please Wait", nil);
    } else {
        text = [self.model.netflixCache titleForKey:feedKey includeCount:NO];
    }
    
    self.title = text;
}


- (void) initializeData {
    self.feed = [self.model.netflixCache feedForKey:feedKey];
    self.queue = [self.model.netflixCache queueForFeed:feed];
    self.mutableMovies = [NSMutableArray arrayWithArray:queue.movies];
    self.mutableSaved = [NSMutableArray arrayWithArray:queue.saved];
    [self setupTitle];
    [self setupButtons];
}


- (void) majorRefreshWorker {
    // do nothing.  we don't want to refresh the view (because it causes an
    // ugly flash).  Instead, just refresh things when teh view becomes visible
}


- (void) internalRefresh {
    if (self.tableView.editing || readonlyMode) {
        return;
    }
    
    [self initializeData];
    [self.tableView reloadData];
    
    if (visibleIndexPaths.count > 0) {
        NSIndexPath* path = [visibleIndexPaths objectAtIndex:0];
        if (path.section >= 0 && path.section < self.tableView.numberOfSections &&
            path.row >= 0 && path.row < [self.tableView numberOfRowsInSection:path.section]) {
            [self.tableView scrollToRowAtIndexPath:[visibleIndexPaths objectAtIndex:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
        
        self.visibleIndexPaths = nil;
    }
}


- (void) minorRefreshWorker {
    if (!visible) {
        return;
    }
    
    for (id cell in self.tableView.visibleCells) {
        [cell refresh];
    }
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    
    if (!self.isEditable) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:[AppDelegate globalActivityView]] autorelease];
    }
    
    self.tableView.rowHeight = 100;
    [self internalRefresh];
}


- (void) viewDidAppear:(BOOL) animated {
    visible = YES;
}


- (void) viewDidDisappear:(BOOL) animated {
    visible = NO;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }
    
    return self.model.screenRotationEnabled;
}


- (void) didReceiveMemoryWarning {
    if (visible) {
        return;
    }
    
    // I don't want to clean anything else up here due to the complicated
    // state being kep around.
    
    // Store the currently visible cells so we can scroll back to them when
    // we're reloaded.
    self.visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView*) tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    if (section == 0) {
        return mutableMovies.count;
    } else {
        return mutableSaved.count;
    }
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
    if (mutableMovies.count == 0 && mutableSaved.count == 0) {
        if (section == 0) {
            return [self.model.netflixCache noInformationFound];
        }
    } else if (mutableSaved.count > 0 && section == 1) {
        return NSLocalizedString(@"Saved", nil);
    }
    
    return nil;
}


- (void) setAccessoryForCell:(NetflixCell*) cell
                 atIndexPath:(NSIndexPath*) path {
    if (self.isEditable) {
        if (path.section == 1 || path.row == 0) {
            cell.accessoryView = nil;
        } else {
            cell.accessoryView = cell.tappableArrow;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}


- (BOOL) indexPathOutOfBounds:(NSIndexPath*) path {
    return path.row < 0 ||
    (path.section == 0 && path.row >= mutableMovies.count) ||
    (path.section == 1 && path.row >= mutableSaved.count);
}


// Customize the appearance of table view cells.
- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    if ([self indexPathOutOfBounds:indexPath]) {
        return [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    static NSString* reuseIdentifier = @"reuseIdentifier";
    
    NetflixCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[NetflixCell alloc] initWithFrame:CGRectZero
                                   reuseIdentifier:reuseIdentifier
                                             model:self.model] autorelease];
        cell.tappableArrow.delegate = self;
    }
    
    [self setAccessoryForCell:cell atIndexPath:indexPath];
    
    Movie* movie;
    if (indexPath.section == 0) {
        movie = [mutableMovies objectAtIndex:indexPath.row];
    } else {
        movie = [mutableSaved objectAtIndex:indexPath.row];
    }
    
    [cell setMovie:movie owner:self];
    
    return cell;
}


- (void) resetVisibleAccessories {
    for (NSIndexPath* path in self.tableView.indexPathsForVisibleRows) {
        id cell = [self.tableView cellForRowAtIndexPath:path];
        [self setAccessoryForCell:cell atIndexPath:path];
    }
}


- (void) enterReadonlyMode {
    readonlyMode = YES;
    [self setupButtons];
    [self setupTitle];
}


- (void) exitReadonlyMode {
    readonlyMode = NO;
    [self setupButtons];
    [self setupTitle];
    [self resetVisibleAccessories];
}


- (void) upArrowTappedForRowAtIndexPath:(NSIndexPath*) indexPath {
    [self enterReadonlyMode];
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [activityIndicator startAnimating];
    cell.accessoryView = activityIndicator;
    
    Movie* movie = [mutableMovies objectAtIndex:indexPath.row];
    [self.model.netflixCache updateQueue:queue byMovingMovieToTop:movie delegate:self];
}


- (void) moveSucceededForMovie:(Movie*) movie {
    self.queue = [self.model.netflixCache queueForFeed:feed];
    NSInteger row = [mutableMovies indexOfObjectIdenticalTo:movie];
    
    [self.tableView beginUpdates];
    {
        NSIndexPath* firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath* currentRow = [NSIndexPath indexPathForRow:row inSection:0];
        
        [mutableMovies removeObjectAtIndex:row];
        [mutableMovies insertObject:movie atIndex:0];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:currentRow] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:firstRow] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];
    
    [self exitReadonlyMode];
}


- (void) onModifyFailure:(NSString*) error {
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"Reordering queue failed:\n\n%@", nil), error];
    [AlertUtilities showOkAlert:message];
    
    [self exitReadonlyMode];
    
    // make sure we're in a good state.
    [self internalRefresh];
}


- (void) moveFailedWithError:(NSString*) error {
    [self onModifyFailure:error];
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (readonlyMode) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
        return;
    }
    
    if (upArrowTapped) {
        upArrowTapped = NO;
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
        [self upArrowTappedForRowAtIndexPath:indexPath];
    } else {
        if ([self indexPathOutOfBounds:indexPath]) {
            return;
        }
        
        Movie* movie;
        if (indexPath.section == 0) {
            movie = [queue.movies objectAtIndex:indexPath.row];
        } else {
            movie = [queue.saved objectAtIndex:indexPath.row];
        }
        
        [navigationController pushMovieDetails:movie animated:YES];
    }
}



- (BOOL)          tableView:(UITableView*) tableView
      canEditRowAtIndexPath:(NSIndexPath*) indexPath {
    return tableView.editing;
}


- (BOOL)          tableView:(UITableView*) tableView
      canMoveRowAtIndexPath:(NSIndexPath*) indexPath {
    return indexPath.section == 0;
}


// Override to support editing the table view.
- (void)       tableView:(UITableView*) tableView
      commitEditingStyle:(UITableViewCellEditingStyle) editingStyle
       forRowAtIndexPath:(NSIndexPath*) indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Movie* movie;
        if (indexPath.section == 0) {
            movie = [mutableMovies objectAtIndex:indexPath.row];
            [mutableMovies removeObjectAtIndex:indexPath.row];
        } else {
            movie = [mutableSaved objectAtIndex:indexPath.row];
            [mutableSaved removeObjectAtIndex:indexPath.row];
        }
        
        [deletedMovies addObject:movie];
        [reorderedMovies removeObject:movie];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}


// Override to support rearranging the table view.
- (void)       tableView:(UITableView*) tableView
      moveRowAtIndexPath:(NSIndexPath*) fromIndexPath
             toIndexPath:(NSIndexPath*) toIndexPath {
    NSInteger from = fromIndexPath.row;
    NSInteger to = toIndexPath.row;
    
    if (from == to) {
        return;
    }
    
    Movie* movie = [mutableMovies objectAtIndex:from];
    [mutableMovies removeObjectAtIndex:from];
    [mutableMovies insertObject:movie atIndex:to];
    
    [reorderedMovies addObject:movie];
}


- (void) onEdit:(id) sender {
    self.reorderedMovies = [IdentitySet set];
    self.deletedMovies = [IdentitySet set];
    [self.tableView setEditing:YES animated:YES];
    [self setupButtons];
}


- (void) onCancel:(id) sender {
    [self.tableView setEditing:NO animated:YES];
    [self internalRefresh];
}


- (void) onSave:(id) sender {
    if (deletedMovies.count == 0 && reorderedMovies.count == 0) {
        // user didn't do anything.  same as a cancel:
        [self onCancel:sender];
    } else {
        [self.tableView setEditing:NO animated:YES];
        [self enterReadonlyMode];
        
        [self.model.netflixCache updateQueue:queue byDeletingMovies:deletedMovies andReorderingMovies:reorderedMovies to:mutableMovies delegate:self];
    }
}


- (void) modifySucceeded {
    [self initializeData];
    [self exitReadonlyMode];
}


- (void) modifyFailedWithError:(NSString*) error {
    [self onModifyFailure:error];
}


- (NSIndexPath*)                     tableView:(UITableView*) tableView
      targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*) sourceIndexPath
                           toProposedIndexPath:(NSIndexPath*) proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section == 1) {
        return [NSIndexPath indexPathForRow:(mutableMovies.count - 1) inSection:0];
    }
    
    return proposedDestinationIndexPath;
}


- (void) imageView:(TappableImageView*) imageView
         wasTapped:(NSInteger) tapCount {
    upArrowTapped = YES;
}

@end
