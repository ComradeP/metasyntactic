// Copyright 2010 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "PocketFlicksViewController.h"

#import "Application.h"
#import "BoxOfficeStockImages.h"
#import "Model.h"
#import "NetflixFeedsViewController.h"
#import "NetflixMostPopularViewController.h"
#import "NetflixQueueViewController.h"
#import "NetflixRecommendationsViewController.h"
#import "NetflixSearchDisplayController.h"
#import "NetflixSettingsViewController.h"
#import "PocketFlicksCreditsViewController.h"
#import "PocketFlicksSettingsViewController.h"

@interface PocketFlicksViewController()
@property (retain) NetflixAccount* account;
@property (retain) UISearchBar* searchBar;
@end


@implementation PocketFlicksViewController

static const NSInteger ROW_HEIGHT = 46;

typedef enum {
  MostPopularSection,
  DVDSection,
  InstantSection,
  RecommendationsSection,
  AtHomeSection,
  RentalHistorySection,
  AboutSendFeedbackSection,
  AccountsSection,
  LastSection
} Sections;

@synthesize account;
@synthesize searchBar;

- (void) dealloc {
  self.account = nil;
  self.searchBar = nil;

  [super dealloc];
}


- (BOOL) theming {
  return [[Model model] netflixTheming];
}


- (void) setupTableStyle {
  self.tableView.rowHeight = ROW_HEIGHT;

  if (self.theming) {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [ColorCache netflixRed];
  } else {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor clearColor];
  }
}


- (id) init {
  if ((self = [super initWithStyle:UITableViewStylePlain])) {
    self.title = [Application name];
    [self setupTableStyle];
  }

  return self;
}


- (void) setupSearchStyle {
  searchBar.tintColor = [StyleSheet searchBarTintColor];
}


- (void) initializeSearchDisplay {
  self.searchBar = [[[UISearchBar alloc] init] autorelease];
  [self setupSearchStyle];
  [searchBar sizeToFit];

  self.searchDisplayController = [[[NetflixSearchDisplayController alloc] initWithSearchBar:searchBar
                                                                         contentsController:self] autorelease];
}


- (void) loadView {
  [super loadView];

  [self initializeSearchDisplay];
}


- (void) showInfo {
  UIViewController* controller = [[[PocketFlicksSettingsViewController alloc] init] autorelease];

  UINavigationController* navigationController = [[[AbstractNavigationController alloc] initWithRootViewController:controller] autorelease];
  if (![DeviceUtilities isIPhone3G]) {
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  }
  [self presentModalViewController:navigationController animated:YES];
}


- (BOOL) hasAccount {
  return account.userId.length > 0;
}


- (void) setupTitle {
  self.title = [Application name];

  if ([[NetflixSiteStatus status] overQuota]) {
    UILabel* label = [ViewControllerUtilities createTitleLabel];
    label.text = LocalizedString(@"Over Quota - Try Again Later", nil);
    self.navigationItem.titleView = label;
  } else if ([[NetflixSiteStatus status] internalError]) {
    UILabel* label = [ViewControllerUtilities createTitleLabel];
    label.text = LocalizedString(@"Netflix Error - Try Again Later", nil);
    self.navigationItem.titleView = label;  
  }
}


- (void) determinePopularMovieCount {
  NSInteger result = 0;
  for (NSString* title in [NetflixRssCache mostPopularTitles]) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    {
      NSInteger count = [[NetflixRssCache cache] movieCountForRSSTitle:title];
      result += count;
    }
    [pool release];
  }

  mostPopularTitleCount = result;
}


- (void) initializeInfoButton {
  self.navigationItem.leftBarButtonItem = [self createInfoButton:@selector(showInfo)];
}


- (void) onBeforeReloadTableViewData {
  [super onBeforeReloadTableViewData];
  self.account = [[NetflixAccountCache cache] currentAccount];
  if (self.hasAccount) {
    self.tableView.tableHeaderView = searchBar;
  } else {
    self.tableView.tableHeaderView = nil;
  }

  [self initializeInfoButton];
  [self setupTableStyle];
  [self setupSearchStyle];
  [self setupTitle];
  [self determinePopularMovieCount];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
  return 1;
}


- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
  if (self.hasAccount) {
    return 8;
  } else {
    return 9;
  }
}


- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
  static NSString* reuseIdentifier = @"reuseIdentifier";
  AutoResizingCell* cell = [[[AutoResizingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];

  BOOL theming = self.theming;
  UIImage* image = nil;


  NSInteger row = indexPath.row;
  if (self.hasAccount) {
    switch (row) {
      case MostPopularSection: {
        NSString* title = LocalizedString(@"New / Popular Releases", nil);
        //NSString* title = [NSString stringWithFormat:@"%@ / %@",
        //                   LocalizedString(@"New Releases", nil),
        //                   LocalizedString(@"Popular", @"The most popular movies currently")];
        //if (mostPopularTitleCount == 0) {
          cell.textLabel.text = title;
        //} else {
        //  cell.textLabel.text = [NSString stringWithFormat:LocalizedString(@"%@ (%@)", nil), title, [NSNumber numberWithInteger:mostPopularTitleCount]];
        //}
        image = BoxOfficeStockImage(@"NetflixMostPopular.png");
        break;
      }
      case DVDSection:
        cell.textLabel.text = [[NetflixCache cache] titleForKey:[NetflixConstants discQueueKey] account:account];
        image = BoxOfficeStockImage(@"NetflixDVDQueue.png");
        break;
      case InstantSection:
        cell.textLabel.text = [[NetflixCache cache] titleForKey:[NetflixConstants instantQueueKey] account:account];
        image = BoxOfficeStockImage(@"NetflixInstantQueue.png");
        break;
      case RecommendationsSection:
        cell.textLabel.text = [[NetflixCache cache] titleForKey:[NetflixConstants recommendationKey] account:account];
        image = BoxOfficeStockImage(@"NetflixRecommendations.png");
        break;
      case AtHomeSection:
        cell.textLabel.text = [[NetflixCache cache] titleForKey:[NetflixConstants atHomeKey] account:account];
        image = BoxOfficeStockImage(@"NetflixHome.png");
        break;
      case RentalHistorySection:
        cell.textLabel.text = LocalizedString(@"Rental History", nil);
        image = BoxOfficeStockImage(@"NetflixHistory.png");
        break;
      case AboutSendFeedbackSection:
        cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@", LocalizedString(@"Send Feedback", nil), LocalizedString(@"Write Review", nil)];
        image = BoxOfficeStockImage(@"NetflixCredits.png");
        break;
      case AccountsSection:
        cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@", LocalizedString(@"Accounts", nil), LocalizedString(@"Profiles", nil)];
        image = BoxOfficeStockImage(@"NetflixLogOff.png");
        break;
    }
  } else {
    if (indexPath.row == 2) {
      cell.textLabel.text = LocalizedString(@"Sign Up for New Account", nil);
      image = BoxOfficeStockImage(@"NetflixSettings.png");
    } else if (indexPath.row == 0) {
      cell.textLabel.text = LocalizedString(@"Log In to Existing Account", nil);
      image = BoxOfficeStockImage(@"NetflixLogOff.png");
    } else if (indexPath.row == 1) {
      cell.textLabel.text = LocalizedString(@"Send Feedback", nil);
      image = BoxOfficeStockImage(@"NetflixCredits.png");
    }
  }

  if (theming) {
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = [[[UIImageView alloc] initWithImage:BoxOfficeStockImage(@"NetflixChevron.png")] autorelease];

    NSString* backgroundName = [NSString stringWithFormat:@"NetflixCellBackground-%d.png", row];
    NSString* selectedBackgroundName = [NSString stringWithFormat:@"NetflixCellSelectedBackground-%d.png", row];
    UIImageView* backgroundView = [[[UIImageView alloc] initWithImage:BoxOfficeStockImage(backgroundName)] autorelease];
    UIImageView* selectedBackgroundView = [[[UIImageView alloc] initWithImage:BoxOfficeStockImage(selectedBackgroundName)] autorelease];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.backgroundView = backgroundView;
    cell.selectedBackgroundView = selectedBackgroundView;
    cell.imageView.image = image;
  } else {
    cell.imageView.image = [ImageUtilities makeGrayscale:image];
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  if (cell.textLabel.text.length == 0) {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
  }

  return cell;
}


- (void) didSelectAccountsRow {
  UIViewController* controller = [[[NetflixAccountsViewController alloc] init] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectQueueRow:(NSString*) key {
  UIViewController* controller = [[[NetflixQueueViewController alloc] initWithFeedKey:key] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectRentalHistoryRow {
  NSArray* keys =
  [NSArray arrayWithObjects:
   [NetflixConstants rentalHistoryKey],
   [NetflixConstants rentalHistoryWatchedKey],
   [NetflixConstants rentalHistoryReturnedKey],
   [NetflixConstants rentalHistoryShippedKey],
   nil];

  UIViewController* controller =
  [[[NetflixFeedsViewController alloc] initWithFeedKeys:keys
                                                  title:LocalizedString(@"Rental History", nil)] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectRecomendationsRow {
  UIViewController* controller = [[[NetflixRecommendationsViewController alloc] init] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectAboutSendFeedbackRow {
  UIViewController* controller = [[[PocketFlicksCreditsViewController alloc] init] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectSettingsRow {
  UIViewController* controller = [[[NetflixSettingsViewController alloc] init] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectMostPopularSection {
  UIViewController* controller = [[[NetflixMostPopularViewController alloc] init] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectLoggedInRow:(NSInteger) row {
  switch (row) {
    case MostPopularSection:        return [self didSelectMostPopularSection];
    case DVDSection:                return [self didSelectQueueRow:[NetflixConstants discQueueKey]];
    case InstantSection:            return [self didSelectQueueRow:[NetflixConstants instantQueueKey]];
    case RecommendationsSection:    return [self didSelectRecomendationsRow];
    case AtHomeSection:             return [self didSelectQueueRow:[NetflixConstants atHomeKey]];
    case RentalHistorySection:      return [self didSelectRentalHistoryRow];
    case AboutSendFeedbackSection:  return [self didSelectAboutSendFeedbackRow];
    case AccountsSection:           return [self didSelectAccountsRow];
  }
}


- (CommonNavigationController*) commonNavigationController {
  return (id)self.navigationController;
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
  if (self.hasAccount) {
    [self didSelectLoggedInRow:indexPath.row];
  } else {
    if (indexPath.row == 2) {
      NSString* address = @"http://clickserve.cc-dt.com/link/tplclick?lid=41000000029889162&pubid=21000000000265233";
      [self.commonNavigationController pushBrowser:address animated:YES];
    } else if (indexPath.row == 0) {
      NetflixLoginViewController* controller = [[[NetflixLoginViewController alloc] init] autorelease];
      [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 1) {
      [self didSelectAboutSendFeedbackRow];
    }
  }
}


- (void) onTabBarItemSelected {
  [searchDisplayController setActive:NO animated:YES];
}


- (NSString*) headerTitle {
  NetflixUser* user = [[NetflixUserCache cache] userForAccount:account];

  if (searchDisplayController.isActive ||
      [[[NetflixAccountCache cache] accounts] count] <= 1 ||
      user == nil) {
    return nil;
  }

  return [NSString stringWithFormat:LocalizedString(@"Account: %@ %@", "Account: <first name> <last name>"), user.firstName, user.lastName];
}



- (NSString*)     tableView:(UITableView*) tableView
    titleForHeaderInSection:(NSInteger)section {
  if ([[Model model] netflixTheming]) {
    return nil;
  } else {
    return self.headerTitle;
  }
}


- (UIView*)      tableView:(UITableView*) tableView
    viewForHeaderInSection:(NSInteger)section {
  if (![[Model model] netflixTheming]) {
    return nil;
  }

  NSString* headerTitle = self.headerTitle;
  if (headerTitle.length == 0) {
    return nil;
  }

  CGRect frame = CGRectMake(12, -1, 480, 23);

  UILabel* label = [[[UILabel alloc] initWithFrame:frame] autorelease];
  label.text = headerTitle;
  label.font = [UIFont boldSystemFontOfSize:18];
  label.textColor = [UIColor whiteColor];
  label.shadowOffset = CGSizeMake(0, 1);
  label.shadowColor = [UIColor darkGrayColor];
  label.opaque = NO;
  label.backgroundColor = [UIColor clearColor];
  label.autoresizingMask = UIViewAutoresizingFlexibleWidth;

  frame.origin.x = 0;
  frame.origin.y = 0;
  UIImage* image = BoxOfficeStockImage(@"PocketflicksHeader.png");
  UIImageView* imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
  imageView.alpha = 0.9f;
  imageView.frame = frame;
  imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

  UIView* view = [[[UIView alloc] initWithFrame:frame] autorelease];
  view.autoresizesSubviews = YES;
  view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

  [view addSubview:imageView];
  [view addSubview:label];

  return view;
}

@end
