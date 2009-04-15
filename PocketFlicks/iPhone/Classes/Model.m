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

#import "Model.h"

#import "AlertUtilities.h"
#import "AllMoviesViewController.h"
#import "AllTheatersViewController.h"
#import "AmazonCache.h"
#import "Application.h"
#import "BlurayCache.h"
#import "DVDCache.h"
#import "DVDViewController.h"
#import "DateUtilities.h"
#import "FavoriteTheater.h"
#import "GoogleDataProvider.h"
#import "HelpCache.h"
#import "IMDbCache.h"
#import "InternationalDataCache.h"
#import "LargePosterCache.h"
#import "LocaleUtilities.h"
#import "Location.h"
#import "Movie.h"
#import "MovieDetailsViewController.h"
#import "MutableNetflixCache.h"
#import "NetflixViewController.h"
#import "NetworkUtilities.h"
#import "OperationQueue.h"
#import "PosterCache.h"
#import "ReviewsViewController.h"
#import "Score.h"
#import "ScoreCache.h"
#import "SettingsViewController.h"
#import "Theater.h"
#import "TheaterDetailsViewController.h"
#import "TicketsViewController.h"
#import "TrailerCache.h"
#import "UpcomingCache.h"
#import "UpcomingMoviesViewController.h"
#import "UserLocationCache.h"
#import "WikipediaCache.h"

@interface Model()
@property (retain) UserLocationCache* userLocationCache;
@property (retain) BlurayCache* blurayCache;
@property (retain) DVDCache* dvdCache;
@property (retain) IMDbCache* imdbCache;
@property (retain) AmazonCache* amazonCache;
@property (retain) WikipediaCache* wikipediaCache;
@property (retain) PersonPosterCache* personPosterCache;
@property (retain) PosterCache* posterCache;
@property (retain) LargePosterCache* largePosterCache;
@property (retain) ScoreCache* scoreCache;
@property (retain) TrailerCache* trailerCache;
@property (retain) UpcomingCache* upcomingCache;
@property (retain) MutableNetflixCache* netflixCache;
@property (retain) InternationalDataCache* internationalDataCache;
@property (retain) HelpCache* helpCache;
@property (retain) NSSet* bookmarkedTitlesData;
@property (retain) NSDictionary* favoriteTheatersData;
@property (retain) id<DataProvider> dataProvider;
@property (retain) NSNumber* isSearchDateTodayData;
@property NSInteger cachedScoreProviderIndex;
@property NSInteger searchRadiusData;
@end

@implementation Model

static Model* model = nil;

static NSString* persistenceVersion = @"105";

static NSString* ALL_MOVIES_SELECTED_SEGMENT_INDEX          = @"allMoviesSelectedSegmentIndex";
static NSString* ALL_THEATERS_SELECTED_SEGMENT_INDEX        = @"allTheatersSelectedSegmentIndex";
static NSString* AUTO_UPDATE_LOCATION                       = @"autoUpdateLocation";
static NSString* BOOKMARKED_BLURAY                          = @"bookmarkedBluray";
static NSString* BOOKMARKED_DVD                             = @"bookmarkedDVD";
static NSString* BOOKMARKED_MOVIES                          = @"bookmarkedMovies";
static NSString* BOOKMARKED_TITLES                          = @"bookmarkedTitles";
static NSString* BOOKMARKED_UPCOMING                        = @"bookmarkedUpcoming";
static NSString* DVD_BLURAY_DISABLED                        = @"dvdBlurayDisabled";
static NSString* DVD_MOVIES_HIDE_BLURAY                     = @"dvdMoviesHideBluray";
static NSString* DVD_MOVIES_HIDE_DVDS                       = @"dvdMoviesHideDVDs";
static NSString* DVD_MOVIES_SELECTED_SEGMENT_INDEX          = @"dvdMoviesSelectedSegmentIndex";
static NSString* FAVORITE_THEATERS                          = @"favoriteTheaters";
static NSString* FIRST_LAUNCH_DATE                          = @"firstLaunchDate";
static NSString* HAS_SHOWN_WRITE_REVIEW_REQUEST             = @"hasShownWriteReviewRequest";
static NSString* LOADING_INDIACTORS_DISABLED                = @"loadingIndicatorsDisabled";
static NSString* LOCAL_SEARCH_SELECTED_SCOPE_BUTTON_INDEX   = @"localSearchSelectedScopeButtonIndex";
static NSString* NAVIGATION_STACK_TYPES                     = @"navigationStackTypes";
static NSString* NAVIGATION_STACK_VALUES                    = @"navigationStackValues";
static NSString* NETFLIX_CAN_INSTANT_WATCH                  = @"netflixCanInstantWatch";
static NSString* NETFLIX_DISABLED                           = @"netflixDisabled";
static NSString* NETFLIX_FIRST_NAME                         = @"netflixFirstName";
static NSString* NETFLIX_KEY                                = @"netflixKey";
static NSString* NETFLIX_LAST_NAME                          = @"netflixLastName";
static NSString* NETFLIX_PREFERRED_FORMATS                  = @"netflixPreferredFormats";
static NSString* NETFLIX_SEARCH_SELECTED_SCOPE_BUTTON_INDEX = @"netflixSearchSelectedScopeButtonIndex";
static NSString* NETFLIX_SECRET                             = @"netflixSecret";
static NSString* NETFLIX_USER_ID                            = @"netflixUserId";
static NSString* NETFLIX_UPDATED_APPLICATION_KEYS           = @"netflixUpdatedApplicationKeys";
static NSString* NOTIFICATIONS_DISABLED                     = @"notificationsDisabled";
static NSString* PRIORITIZE_BOOKMARKS                       = @"prioritizeBookmarks";
static NSString* RUN_COUNT                                  = @"runCount";
static NSString* SCORE_PROVIDER_INDEX                       = @"scoreProviderIndex";
static NSString* SCREEN_ROTATION_DISABLED                   = @"screenRotationDisabled";
static NSString* SEARCH_DATE                                = @"searchDate";
static NSString* SEARCH_RADIUS                              = @"searchRadius";
static NSString* SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX     = @"selectedTabBarViewControllerIndex";
static NSString* UNSUPPORTED_COUNTRY                        = @"unsupportedCountry";
static NSString* UPCOMING_AND_DVD_HIDE_UPCOMING             = @"upcomingAndDvdMoviesHideUpcoming";
static NSString* UPCOMING_DISABLED                          = @"upcomingDisabled";
static NSString* UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX     = @"upcomingMoviesSelectedSegmentIndex";
static NSString* USE_NORMAL_FONTS                           = @"useNormalFonts";
static NSString* USER_ADDRESS                               = @"userLocation";
static NSString* VERSION                                    = @"version";
static NSString* VOTED_FOR_ICON                             = @"votedForIcon";

static NSString** ALL_KEYS[] = {
&ALL_MOVIES_SELECTED_SEGMENT_INDEX,
&ALL_THEATERS_SELECTED_SEGMENT_INDEX,
&AUTO_UPDATE_LOCATION,
&BOOKMARKED_BLURAY,
&BOOKMARKED_DVD,
&BOOKMARKED_MOVIES,
&BOOKMARKED_TITLES,
&BOOKMARKED_UPCOMING,
&DVD_BLURAY_DISABLED,
&DVD_MOVIES_HIDE_BLURAY,
&DVD_MOVIES_HIDE_DVDS,
&DVD_MOVIES_SELECTED_SEGMENT_INDEX,
&FAVORITE_THEATERS,
&FIRST_LAUNCH_DATE,
&HAS_SHOWN_WRITE_REVIEW_REQUEST,
&LOADING_INDIACTORS_DISABLED,
&LOCAL_SEARCH_SELECTED_SCOPE_BUTTON_INDEX,
&NAVIGATION_STACK_TYPES,
&NAVIGATION_STACK_VALUES,
&NETFLIX_CAN_INSTANT_WATCH,
&NETFLIX_DISABLED,
&NETFLIX_FIRST_NAME,
&NETFLIX_KEY,
&NETFLIX_LAST_NAME,
&NETFLIX_PREFERRED_FORMATS,
&NETFLIX_SEARCH_SELECTED_SCOPE_BUTTON_INDEX,
&NETFLIX_SECRET,
&NETFLIX_USER_ID,
&NOTIFICATIONS_DISABLED,
&PRIORITIZE_BOOKMARKS,
&RUN_COUNT,
&SCORE_PROVIDER_INDEX,
&SCREEN_ROTATION_DISABLED,
&SEARCH_DATE,
&SEARCH_RADIUS,
&SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX,
&UNSUPPORTED_COUNTRY,
&UPCOMING_AND_DVD_HIDE_UPCOMING,
&UPCOMING_DISABLED,
&UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX,
&USE_NORMAL_FONTS,
&USER_ADDRESS,
&VERSION,
&VOTED_FOR_ICON,
};


static NSString** STRING_KEYS_TO_MIGRATE[] = {
&USER_ADDRESS,
&NETFLIX_KEY,
&NETFLIX_SECRET,
&NETFLIX_USER_ID,
&NETFLIX_FIRST_NAME,
&NETFLIX_LAST_NAME,
};

static NSString** INTEGER_KEYS_TO_MIGRATE[] = {
&ALL_MOVIES_SELECTED_SEGMENT_INDEX,
&ALL_THEATERS_SELECTED_SEGMENT_INDEX,
&DVD_MOVIES_SELECTED_SEGMENT_INDEX,
&LOCAL_SEARCH_SELECTED_SCOPE_BUTTON_INDEX,
&NETFLIX_SEARCH_SELECTED_SCOPE_BUTTON_INDEX,
&SCORE_PROVIDER_INDEX,
&SEARCH_RADIUS,
&SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX,
&UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX
};

static NSString** BOOLEAN_KEYS_TO_MIGRATE[] = {
&AUTO_UPDATE_LOCATION,
&DVD_MOVIES_HIDE_DVDS,
&DVD_MOVIES_HIDE_BLURAY,
&UPCOMING_AND_DVD_HIDE_UPCOMING,
&PRIORITIZE_BOOKMARKS,
&USE_NORMAL_FONTS,
&LOADING_INDIACTORS_DISABLED,
&NETFLIX_DISABLED,
&NETFLIX_CAN_INSTANT_WATCH,
&NOTIFICATIONS_DISABLED,
&SCREEN_ROTATION_DISABLED,
&HAS_SHOWN_WRITE_REVIEW_REQUEST,
&DVD_BLURAY_DISABLED,
&UPCOMING_DISABLED,
&VOTED_FOR_ICON,
&NETFLIX_UPDATED_APPLICATION_KEYS,
};

static NSString** DATE_KEYS_TO_MIGRATE[] = {
&FIRST_LAUNCH_DATE,
};

static NSString** STRING_ARRAY_KEYS_TO_MIGRATE[] = {
&BOOKMARKED_TITLES,
&NETFLIX_PREFERRED_FORMATS,
};

static NSString** MOVIE_ARRAY_KEYS_TO_MIGRATE[] = {
&BOOKMARKED_MOVIES,
&BOOKMARKED_UPCOMING,
&BOOKMARKED_DVD,
&BOOKMARKED_BLURAY
};


@synthesize dataProvider;

@synthesize bookmarkedTitlesData;
@synthesize favoriteTheatersData;
@synthesize isSearchDateTodayData;

@synthesize userLocationCache;
@synthesize blurayCache;
@synthesize dvdCache;
@synthesize imdbCache;
@synthesize amazonCache;
@synthesize wikipediaCache;
@synthesize personPosterCache;
@synthesize posterCache;
@synthesize largePosterCache;
@synthesize scoreCache;
@synthesize trailerCache;
@synthesize upcomingCache;
@synthesize netflixCache;
@synthesize internationalDataCache;
@synthesize helpCache;
@synthesize cachedScoreProviderIndex;
@synthesize searchRadiusData;

- (void) dealloc {
    self.dataProvider = nil;
    self.bookmarkedTitlesData = nil;
    self.favoriteTheatersData = nil;
    self.isSearchDateTodayData = nil;

    self.userLocationCache = nil;
    self.blurayCache = nil;
    self.dvdCache = nil;
    self.imdbCache = nil;
    self.amazonCache = nil;
    self.wikipediaCache = nil;
    self.personPosterCache = nil;
    self.posterCache = nil;
    self.largePosterCache = nil;
    self.scoreCache = nil;
    self.trailerCache = nil;
    self.upcomingCache = nil;
    self.netflixCache = nil;
    self.internationalDataCache = nil;
    self.helpCache = nil;

    [super dealloc];
}


+ (Model*) model {
    if (model == nil) {
        model = [[Model alloc] init];
    }

    return model;
}


+ (void) saveFavoriteTheaters:(NSArray*) favoriteTheaters {
    NSMutableArray* result = [NSMutableArray array];
    for (FavoriteTheater* theater in favoriteTheaters) {
        [result addObject:theater.dictionary];
    }

    [[NSUserDefaults standardUserDefaults] setObject:result forKey:FAVORITE_THEATERS];
}


- (void) setBookmarkedTitles:(NSSet*) bookmarkedTitles {
    [dataGate lock];
    {
        self.bookmarkedTitlesData = bookmarkedTitles;
    }
    [dataGate unlock];
    [[NSUserDefaults standardUserDefaults] setObject:bookmarkedTitles.allObjects forKey:BOOKMARKED_TITLES];
}


+ (void) saveMovies:(NSArray*) movies key:(NSString*) key {
    NSMutableArray* encoded = [NSMutableArray array];
    for (Movie* movie in movies) {
        [encoded addObject:movie.dictionary];
    }

    [[NSUserDefaults standardUserDefaults] setObject:encoded forKey:key];
}


- (NSDictionary*) valuesToMigrate {
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    for (NSInteger i = 0; i < ArrayLength(STRING_KEYS_TO_MIGRATE); i++) {
        NSString* key = *STRING_KEYS_TO_MIGRATE[i];
        id previousValue = [defaults objectForKey:key];
        if ([previousValue isKindOfClass:[NSString class]]) {
            [result setObject:previousValue forKey:key];
        }
    }

    for (NSInteger i = 0; i < ArrayLength(DATE_KEYS_TO_MIGRATE); i++) {
        NSString* key = *DATE_KEYS_TO_MIGRATE[i];
        id previousValue = [defaults objectForKey:key];
        if ([previousValue isKindOfClass:[NSDate class]]) {
            [result setObject:previousValue forKey:key];
        }
    }

    for (NSInteger i = 0; i < ArrayLength(BOOLEAN_KEYS_TO_MIGRATE); i++) {
        NSString* key = *BOOLEAN_KEYS_TO_MIGRATE[i];
        id previousValue = [defaults objectForKey:key];
        if ([previousValue isKindOfClass:[NSNumber class]]) {
            [result setObject:previousValue forKey:key];
        }
    }

    for (NSInteger i = 0; i < ArrayLength(INTEGER_KEYS_TO_MIGRATE); i++) {
        NSString* key = *INTEGER_KEYS_TO_MIGRATE[i];
        id previousValue = [defaults objectForKey:key];
        if ([previousValue isKindOfClass:[NSNumber class]]) {
            [result setObject:previousValue forKey:key];
        }
    }

    for (NSInteger i = 0; i < ArrayLength(STRING_ARRAY_KEYS_TO_MIGRATE); i++) {
        NSString* key = *STRING_ARRAY_KEYS_TO_MIGRATE[i];
        id previousValue = [defaults objectForKey:key];
        if ([previousValue isKindOfClass:[NSArray class]]) {
            NSMutableArray* elements = [NSMutableArray array];
            for (id element in previousValue) {
                if ([element isKindOfClass:[NSString class]]) {
                    [elements addObject:element];
                }
            }

            [result setObject:elements forKey:key];
        }
    }

    for (NSInteger i = 0; i < ArrayLength(MOVIE_ARRAY_KEYS_TO_MIGRATE); i++) {
        NSString* key = *MOVIE_ARRAY_KEYS_TO_MIGRATE[i];
        id previousValue = [defaults objectForKey:key];
        if ([previousValue isKindOfClass:[NSArray class]]) {
            NSMutableArray* elements = [NSMutableArray array];
            for (id element in previousValue) {
                if ([element isKindOfClass:[NSDictionary class]] &&
                  [Movie canReadDictionary:element]) {
                    [elements addObject:element];
                }
            }

            [result setObject:elements forKey:key];
        }
    }

    {
        id previousValue = [defaults objectForKey:FAVORITE_THEATERS];
        if ([previousValue isKindOfClass:[NSArray class]]) {
            NSMutableArray* elements = [NSMutableArray array];

            for (id element in previousValue) {
                if ([element isKindOfClass:[NSDictionary class]] &&
        [FavoriteTheater canReadDictionary:element]) {
                    [elements addObject:element];
                }
            }

            [result setObject:elements forKey:FAVORITE_THEATERS];
        }
    }

    return result;
}


- (void) synchronize {
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) loadData {
    self.dataProvider = [GoogleDataProvider provider];

    NSString* version = [[NSUserDefaults standardUserDefaults] objectForKey:VERSION];
    if (version == nil || ![persistenceVersion isEqual:version]) {
        // First, capture any preferences that we can safely migrate
        NSDictionary* currentValues = [self valuesToMigrate];

        // Now, wipe out all keys
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        for (int i = 0; i < ArrayLength(ALL_KEYS); i++) {
            NSString* key = *ALL_KEYS[i];
            [defaults removeObjectForKey:key];
        }

        // And delete any stored state
        [Application resetDirectories];

        // Now restore the saved preferences.
        for (NSString* key in currentValues) {
            [defaults setObject:[currentValues objectForKey:key] forKey:key];
        }

        // Mark that we updated successfully, and flush to disc.
        [[NSUserDefaults standardUserDefaults] setObject:persistenceVersion forKey:VERSION];
        [self synchronize];
    }
}


- (void) clearCaches {
    NSInteger runCount = [[NSUserDefaults standardUserDefaults] integerForKey:RUN_COUNT];
    [[NSUserDefaults standardUserDefaults] setInteger:(runCount + 1) forKey:RUN_COUNT];
    [self synchronize];

    if ((runCount % 5) == 0) {
        [Application clearStaleData];
    }
}


- (void) checkCountry {
    if ([LocaleUtilities isSupportedCountry]) {
        return;
    }

    // Only warn once per upgrade.
    NSString* key = [NSString stringWithFormat:@"%@-%@-%@", UNSUPPORTED_COUNTRY, [Application version], [LocaleUtilities isoCountry]];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:key]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    [self synchronize];

    NSString* warning =
    [NSString stringWithFormat:
NSLocalizedString(@"Your %@'s country is set to: %@\n\nFull support for %@ is coming soon to your country, and several features are already available for you to use today! When more features become ready, you will automatically be notified of updates.", nil),
     [UIDevice currentDevice].localizedModel,
     [LocaleUtilities displayCountry],
     [Application name]];

    [AlertUtilities showOkAlert:warning];
}


- (void) updateNetflixKeys {
    BOOL updatedNetflixApplicationKeys = [[NSUserDefaults standardUserDefaults] boolForKey:NETFLIX_UPDATED_APPLICATION_KEYS];
    if (updatedNetflixApplicationKeys) {
        return;
    }

    [self setNetflixKey:nil secret:nil userId:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NETFLIX_UPDATED_APPLICATION_KEYS];
    [self synchronize];
}

const NSInteger CHECK_DATE_ALERT_VIEW_TAG = 1;

- (void) checkDate {
    NSDate* firstLaunchDate = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_LAUNCH_DATE];
    if (firstLaunchDate == nil) {
        firstLaunchDate = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:firstLaunchDate forKey:FIRST_LAUNCH_DATE];
        [self synchronize];
    }

    NSTimeInterval interval = ABS(firstLaunchDate.timeIntervalSinceNow);
    if (interval < ONE_MONTH) {
        return;
    }

    BOOL hasShown = [[NSUserDefaults standardUserDefaults] boolForKey:HAS_SHOWN_WRITE_REVIEW_REQUEST];
    if (hasShown) {
        return;
    }

    // only 5% chance of showing it to them.
    if ((rand() % 1000) > 50) {
        return;
    }

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HAS_SHOWN_WRITE_REVIEW_REQUEST];
    [self synchronize];

    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"A message from Cyrus", nil)
                                                     message:NSLocalizedString(@"Help keep Now Playing free!\n\nAs a longtime Now Playing user, please consider writing a small review for the iTunes store. It will help new users discover this app, allow me to bring you great new features, keep things ad free, and will make me feel fuzzy inside.\n\nThanks so much!\n(this will only be shown once)", nil)
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"No Thanks", nil)
                                           otherButtonTitles:NSLocalizedString(@"Write Review", nil), nil] autorelease];
    alert.tag = CHECK_DATE_ALERT_VIEW_TAG;
    [alert show];
}


- (void)              alertView:(UIAlertView*) alertView
      didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [Application openBrowser:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=284939567&mt=8"];
    }
}


- (BOOL) votedForIcon {
    return [[NSUserDefaults standardUserDefaults] boolForKey:VOTED_FOR_ICON];
}


- (void) setVotedForIcon {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:VOTED_FOR_ICON];
    [self synchronize];
}


- (id) init {
    if (self = [super init]) {
        [self checkCountry];
        [self loadData];
        //[self checkDate];
        [self updateNetflixKeys];

        self.userLocationCache = [UserLocationCache cache];
        self.largePosterCache = [LargePosterCache cache];
        self.imdbCache = [IMDbCache cache];
        self.amazonCache = [AmazonCache cache];
        self.wikipediaCache = [WikipediaCache cache];
        self.trailerCache = [TrailerCache cache];
        self.blurayCache = [BlurayCache cache];
        self.dvdCache = [DVDCache cache];
        self.posterCache = [PosterCache cache];
        self.scoreCache = [ScoreCache cache];
        self.upcomingCache = [UpcomingCache cache];
        self.netflixCache = [MutableNetflixCache cache];
        self.internationalDataCache = [InternationalDataCache cache];
        self.helpCache = [HelpCache cache];

        [self clearCaches];

        self.searchRadius = -1;
        self.cachedScoreProviderIndex = -1;
        cachedAllMoviesSelectedSegmentIndex = -1;
    }

    return self;
}


- (BOOL) loadingIndicatorsEnabled {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:LOADING_INDIACTORS_DISABLED];
}


- (void) setLoadingIndicatorsEnabled:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:LOADING_INDIACTORS_DISABLED];
}


- (BOOL) notificationsEnabled {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:NOTIFICATIONS_DISABLED];
}


- (void) setNotificationsEnabled:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:NOTIFICATIONS_DISABLED];
}


- (BOOL) screenRotationEnabled {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:SCREEN_ROTATION_DISABLED];
}


- (void) setScreenRotationEnabled:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:SCREEN_ROTATION_DISABLED];
}


- (BOOL) largePosterCacheEnabled {
    return YES;
}


- (BOOL) dataProviderEnabled {
    return NO;
}


- (BOOL) scoresEnabled {
    return NO;
}


- (BOOL) dvdBlurayEnabled {
    return NO;
    return ![[NSUserDefaults standardUserDefaults] boolForKey:DVD_BLURAY_DISABLED];
}


- (void) setDvdBlurayEnabled:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:DVD_BLURAY_DISABLED];
}


- (BOOL) upcomingEnabled {
    return NO;
    return ![[NSUserDefaults standardUserDefaults] boolForKey:UPCOMING_DISABLED];
}


- (void) setUpcomingEnabled:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:UPCOMING_DISABLED];
}


- (BOOL) netflixEnabled {
    return YES;
    NSNumber* value = [[NSUserDefaults standardUserDefaults] objectForKey:NETFLIX_DISABLED];
    if (value == nil) {
        return [LocaleUtilities isUnitedStates];
    }

    return !value.boolValue;
}


- (void) setNetflixEnabled:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:NETFLIX_DISABLED];

    if (!value) {
        [self setNetflixKey:nil secret:nil userId:nil];
    }
}


- (NSString*) netflixKey {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NETFLIX_KEY];
}


- (NSString*) netflixSecret {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NETFLIX_SECRET];
}


-(NSString*) netflixUserId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NETFLIX_USER_ID];
}


-(NSString*) netflixFirstName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NETFLIX_FIRST_NAME];
}


-(NSString*) netflixLastName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NETFLIX_LAST_NAME];
}


- (void) setNetflixKey:(NSString*) key secret:(NSString*) secret userId:(NSString*) userId {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:NETFLIX_USER_ID];
    [[NSUserDefaults standardUserDefaults] setObject:secret forKey:NETFLIX_SECRET];
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:NETFLIX_KEY];
    [self synchronize];
}


- (void) setNetflixFirstName:(NSString*) firstName
                    lastName:(NSString*) lastName
             canInstantWatch:(BOOL) canInstantWatch
            preferredFormats:(NSArray*) preferredFormats {
    [[NSUserDefaults standardUserDefaults] setObject:firstName forKey:NETFLIX_FIRST_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:lastName forKey:NETFLIX_LAST_NAME];
    [[NSUserDefaults standardUserDefaults] setBool:canInstantWatch forKey:NETFLIX_CAN_INSTANT_WATCH];
    [[NSUserDefaults standardUserDefaults] setObject:preferredFormats forKey:NETFLIX_PREFERRED_FORMATS];
}


- (BOOL) netflixCanInstantWatch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:NETFLIX_CAN_INSTANT_WATCH];
}


- (NSArray*) netflixPreferredFormats {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NETFLIX_PREFERRED_FORMATS];
}


- (NSInteger) scoreProviderIndexWorker {
    NSNumber* result = [[NSUserDefaults standardUserDefaults] objectForKey:SCORE_PROVIDER_INDEX];
    if (result != nil) {
        return [result intValue];
    }

    // by default, chose 'rottentomatoes' if they're an english speaking
    // country.  otherwise, choose 'google'.
    if ([LocaleUtilities isEnglish]) {
        [self setScoreProviderIndex:0];
    } else {
        [self setScoreProviderIndex:2];
    }

    return [self scoreProviderIndex];
}


- (NSInteger) scoreProviderIndex {
    return 3;
    if (self.cachedScoreProviderIndex == -1) {
        self.cachedScoreProviderIndex = [self scoreProviderIndexWorker];
    }

    return self.cachedScoreProviderIndex;
}


- (void) setScoreProviderIndex:(NSInteger) index {
    self.cachedScoreProviderIndex = index;
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:SCORE_PROVIDER_INDEX];

    if (self.noScores && self.allMoviesSortingByScore) {
        [self setAllMoviesSelectedSegmentIndex:0];
    }
}


- (BOOL) rottenTomatoesScores {
    return self.scoreProviderIndex == 0;
}


- (BOOL) metacriticScores {
    return self.scoreProviderIndex == 1;
}


- (BOOL) googleScores {
    return self.scoreProviderIndex == 2;
}


- (BOOL) noScores {
    return self.scoreProviderIndex == 3;
}


- (NSArray*) scoreProviders {
    return [NSArray arrayWithObjects:
            @"RottenTomatoes",
            @"Metacritic",
            @"Google",
            NSLocalizedString(@"None", @"This is what a user picks when they don't want any reviews."),
            nil];
}


- (NSString*) currentScoreProvider {
    return [self.scoreProviders objectAtIndex:self.scoreProviderIndex];
}


- (NSInteger) selectedTabBarViewControllerIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX];
}


- (void) setSelectedTabBarViewControllerIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX];
}


- (NSInteger) allMoviesSelectedSegmentIndex {
    if (cachedAllMoviesSelectedSegmentIndex == -1) {
        cachedAllMoviesSelectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:ALL_MOVIES_SELECTED_SEGMENT_INDEX];
    }

    return cachedAllMoviesSelectedSegmentIndex;
}


- (void) setAllMoviesSelectedSegmentIndex:(NSInteger) index {
    cachedAllMoviesSelectedSegmentIndex = index;
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:ALL_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (NSInteger) allTheatersSelectedSegmentIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:ALL_THEATERS_SELECTED_SEGMENT_INDEX];
}


- (void) setAllTheatersSelectedSegmentIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:ALL_THEATERS_SELECTED_SEGMENT_INDEX];
}

- (NSInteger) upcomingMoviesSelectedSegmentIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (void) setUpcomingMoviesSelectedSegmentIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (NSInteger) dvdMoviesSelectedSegmentIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:DVD_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (void) setDvdMoviesSelectedSegmentIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:DVD_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (NSInteger) localSearchSelectedScopeButtonIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:LOCAL_SEARCH_SELECTED_SCOPE_BUTTON_INDEX];
}


- (void) setLocalSearchSelectedScopeButtonIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:LOCAL_SEARCH_SELECTED_SCOPE_BUTTON_INDEX];
}


- (NSInteger) netflixSearchSelectedScopeButtonIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:NETFLIX_SEARCH_SELECTED_SCOPE_BUTTON_INDEX];
}


- (void) setNetflixSearchSelectedScopeButtonIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:NETFLIX_SEARCH_SELECTED_SCOPE_BUTTON_INDEX];
}


- (BOOL) dvdMoviesShowBoth {
    return self.dvdMoviesShowDVDs && self.dvdMoviesShowBluray;
}


- (BOOL) dvdMoviesShowOnlyDVDs {
    return self.dvdMoviesShowDVDs && !self.dvdMoviesShowBluray;
}


- (BOOL) dvdMoviesShowOnlyBluray {
    return !self.dvdMoviesShowDVDs && self.dvdMoviesShowBluray;
}


- (BOOL) dvdMoviesShowDVDs {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:DVD_MOVIES_HIDE_DVDS];
}


- (BOOL) dvdMoviesShowBluray {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:DVD_MOVIES_HIDE_BLURAY];
}


- (void) setDvdMoviesShowDVDs:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:DVD_MOVIES_HIDE_DVDS];
}


- (void) setDvdMoviesShowBluray:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:DVD_MOVIES_HIDE_BLURAY];
}


- (BOOL) upcomingAndDVDShowUpcoming {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:UPCOMING_AND_DVD_HIDE_UPCOMING];
}


- (void) setUpcomingAndDVDShowUpcoming:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:UPCOMING_AND_DVD_HIDE_UPCOMING];
}


- (BOOL) allMoviesSortingByReleaseDate {
    return self.allMoviesSelectedSegmentIndex == 0;
}


- (BOOL) allMoviesSortingByTitle {
    return self.allMoviesSelectedSegmentIndex == 1;
}


- (BOOL) allMoviesSortingByScore {
    return self.allMoviesSelectedSegmentIndex == 2;
}


- (BOOL) upcomingMoviesSortingByReleaseDate {
    return self.upcomingMoviesSelectedSegmentIndex == 0;
}


- (BOOL) upcomingMoviesSortingByTitle {
    return self.upcomingMoviesSelectedSegmentIndex == 1;
}


- (BOOL) dvdMoviesSortingByReleaseDate {
    return self.dvdMoviesSelectedSegmentIndex == 0;
}


- (BOOL) dvdMoviesSortingByTitle {
    return self.dvdMoviesSelectedSegmentIndex == 1;
}


- (BOOL) prioritizeBookmarks {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PRIORITIZE_BOOKMARKS];
}


- (void) setPrioritizeBookmarks:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:PRIORITIZE_BOOKMARKS];
}


- (BOOL) autoUpdateLocation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:AUTO_UPDATE_LOCATION];
}


- (void) setAutoUpdateLocation:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:AUTO_UPDATE_LOCATION];
}


- (NSString*) userAddress {
    NSString* result = [[NSUserDefaults standardUserDefaults] stringForKey:USER_ADDRESS];
    if (result == nil) {
        result = @"";
    }

    return result;
}


- (int) searchRadius {
    if (self.searchRadiusData == -1) {
        self.searchRadiusData = [[NSUserDefaults standardUserDefaults] integerForKey:SEARCH_RADIUS];
        if (self.searchRadiusData == 0) {
            self.searchRadiusData = 5;
        }

        self.searchRadiusData = MAX(MIN(self.searchRadiusData, 50), 1);
    }

    return self.searchRadiusData;
}


- (void) setSearchRadius:(NSInteger) radius {
    self.searchRadiusData = radius;
    [[NSUserDefaults standardUserDefaults] setInteger:self.searchRadius forKey:SEARCH_RADIUS];
}


- (NSDate*) searchDate {
    NSDate* date = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_DATE];
    if (date == nil || [date compare:[NSDate date]] == NSOrderedAscending) {
        date = [DateUtilities today];
        [self setSearchDate:date];
    }
    return date;
}


- (void) setSearchDate:(NSDate*) date {
    self.isSearchDateTodayData = nil;
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:SEARCH_DATE];
}


- (BOOL) isSearchDateToday {
    if (isSearchDateTodayData == nil) {
        self.isSearchDateTodayData = [NSNumber numberWithBool:[DateUtilities isToday:self.searchDate]];
    }

    return isSearchDateTodayData.boolValue;
}


- (NSArray*) movies {
    return [dataProvider movies];
}


- (NSArray*) theaters {
    return [dataProvider theaters];
}


- (NSSet*) loadBookmarkedTitles {
    NSArray* array = [[NSUserDefaults standardUserDefaults] arrayForKey:BOOKMARKED_TITLES];
    if (array.count == 0) {
        return [NSMutableSet set];
    }

    return [NSSet setWithArray:array];
}


- (NSSet*) bookmarkedTitlesNoLock {
    if (bookmarkedTitlesData == nil) {
        self.bookmarkedTitlesData = [self loadBookmarkedTitles];
    }

    // Access through property to ensure valid value.
    return self.bookmarkedTitlesData;
}


- (NSSet*) bookmarkedTitles {
    NSSet* result;
    [dataGate lock];
    {
        result = [self bookmarkedTitlesNoLock];
    }
    [dataGate unlock];
    return result;
}


- (BOOL) isBookmarked:(Movie*) movie {
    return [self.bookmarkedTitles containsObject:movie.canonicalTitle];
}


- (void) addBookmark:(Movie*) movie {
    NSMutableSet* set = [NSMutableSet setWithSet:self.bookmarkedTitles];
    [set addObject:movie.canonicalTitle];
    [self setBookmarkedTitles:set];

    [dataProvider addBookmark:movie.canonicalTitle];
    [upcomingCache addBookmark:movie.canonicalTitle];
    [dvdCache addBookmark:movie.canonicalTitle];
    [blurayCache addBookmark:movie.canonicalTitle];
}


- (void) removeBookmark:(Movie*) movie {
    NSMutableSet* set = [NSMutableSet setWithSet:self.bookmarkedTitles];
    [set removeObject:movie.canonicalTitle];

    [self setBookmarkedTitles:set];

    [dataProvider removeBookmark:movie.canonicalTitle];
    [upcomingCache removeBookmark:movie.canonicalTitle];
    [dvdCache removeBookmark:movie.canonicalTitle];
    [blurayCache removeBookmark:movie.canonicalTitle];
}


- (NSArray*) bookmarkedItems:(NSString*) key {
    NSArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (array.count == 0) {
        return [NSArray array];
    }

    NSMutableArray* result = [NSMutableArray array];
    for (NSDictionary* dictionary in array) {
        [result addObject:[Movie movieWithDictionary:dictionary]];
    }
    return result;
}


- (NSArray*) bookmarkedMovies {
    return [self bookmarkedItems:BOOKMARKED_MOVIES];
}


- (NSArray*) bookmarkedUpcoming {
    return [self bookmarkedItems:BOOKMARKED_UPCOMING];
}


- (NSArray*) bookmarkedDVD {
    return [self bookmarkedItems:BOOKMARKED_DVD];
}


- (NSArray*) bookmarkedBluray {
    return [self bookmarkedItems:BOOKMARKED_BLURAY];
}


- (void) setBookmarkedMovies:(NSArray*) array {
    [Model saveMovies:array key:BOOKMARKED_MOVIES];
}


- (void) setBookmarkedUpcoming:(NSArray*) array {
    [Model saveMovies:array key:BOOKMARKED_UPCOMING];
}


- (void) setBookmarkedDVD:(NSArray*) array {
    [Model saveMovies:array key:BOOKMARKED_DVD];
}


- (void) setBookmarkedBluray:(NSArray*) array {
    [Model saveMovies:array key:BOOKMARKED_BLURAY];
}


- (NSMutableDictionary*) loadFavoriteTheaters {
    NSArray* array = [[NSUserDefaults standardUserDefaults] arrayForKey:FAVORITE_THEATERS];
    if (array.count == 0) {
        return [NSMutableDictionary dictionary];
    }

    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (NSDictionary* dictionary in array) {
        FavoriteTheater* theater = [FavoriteTheater theaterWithDictionary:dictionary];
        [result setObject:theater forKey:theater.name];
    }

    return result;
}


- (NSDictionary*) favoriteTheatersNoLock {
    if (favoriteTheatersData == nil) {
        self.favoriteTheatersData = [self loadFavoriteTheaters];
    }

    // Access through property so we always get a valid value back
    return self.favoriteTheatersData;
}


- (NSDictionary*) favoriteTheaters {
    NSDictionary* result = nil;
    [dataGate lock];
    {
        result = [self favoriteTheatersNoLock];
    }
    [dataGate unlock];
    return result;
}


- (NSArray*) favoriteTheatersArray {
    return self.favoriteTheaters.allValues;
}

- (void) setFavoriteTheaters:(NSDictionary*) favoriteTheaters {
    [dataGate lock];
    {
        self.favoriteTheatersData = favoriteTheaters;
    }
    [dataGate unlock];
    [Model saveFavoriteTheaters:favoriteTheaters.allValues];
}


- (void) addFavoriteTheater:(Theater*) theater {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:self.favoriteTheaters];

    FavoriteTheater* favoriteTheater = [FavoriteTheater theaterWithName:theater.name
                                                    originatingLocation:theater.originatingLocation];

    [dictionary setObject:favoriteTheater forKey:theater.name];

    [self setFavoriteTheaters:dictionary];
}


- (BOOL) isFavoriteTheater:(Theater*) theater {
    return [self.favoriteTheaters objectForKey:theater.name] != nil;
}


- (void) removeFavoriteTheater:(Theater*) theater {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:self.favoriteTheaters];
    [dictionary removeObjectForKey:theater.name];

    [self setFavoriteTheaters:dictionary];
}


- (NSDate*) releaseDateForMovie:(Movie*) movie {
    NSDate* date = movie.releaseDate;
    if (date != nil) {
        return date;
    }

    date = [internationalDataCache releaseDateForMovie:movie];
    if (date != nil) {
        return date;
    }

    date = [upcomingCache releaseDateForMovie:movie];
    if (date != nil) {
        return date;
    }

    return nil;
}


- (NSInteger) lengthForMovie:(Movie*) movie {
    NSInteger length = movie.length;
    if (length > 0) {
        return length;
    }

    return [internationalDataCache lengthForMovie:movie];
}


- (NSString*) ratingForMovie:(Movie*) movie {
    NSString* rating = movie.rating;
    if (rating.length > 0) {
        return rating;
    }

    return [internationalDataCache ratingForMovie:movie];
}


- (NSString*) ratingAndRuntimeForMovie:(Movie*) movie {
    return [internationalDataCache ratingAndRuntimeForMovie:movie];
}


- (NSArray*) directorsForMovie:(Movie*) movie {
    NSArray* directors = movie.directors;
    if (directors.count > 0) {
        return directors;
    }

    directors = [internationalDataCache directorsForMovie:movie];
    if (directors.count > 0) {
        return directors;
    }

    directors = [upcomingCache directorsForMovie:movie];
    if (directors.count > 0) {
        return directors;
    }

    directors = [netflixCache directorsForMovie:movie];
    if (directors.count > 0) {
        return directors;
    }

    return [NSArray array];
}


- (NSArray*) castForMovie:(Movie*) movie {
    NSArray* cast = movie.cast;
    if (cast.count > 0) {
        return cast;
    }

    cast = [internationalDataCache castForMovie:movie];
    if (cast.count > 0) {
        return cast;
    }

    cast = [upcomingCache castForMovie:movie];
    if (cast.count > 0) {
        return cast;
    }

    cast = [netflixCache castForMovie:movie];
    if (cast.count > 0) {
        return cast;
    }

    return [NSArray array];
}


- (NSArray*) genresForMovie:(Movie*) movie {
    if (movie.genres.count > 0) {
        return movie.genres;
    }

    return [upcomingCache genresForMovie:movie];
}


- (NSString*) imdbAddressForMovie:(Movie*) movie {
    NSString* result = movie.imdbAddress;
    if (result.length > 0) {
        return result;
    }

    result = [internationalDataCache imdbAddressForMovie:movie];
    if (result.length > 0) {
        return result;
    }

    result = [imdbCache imdbAddressForMovie:movie];
    if (result.length > 0) {
        return result;
    }

    return nil;
}


- (NSString*) amazonAddressForMovie:(Movie*) movie {
    return [amazonCache amazonAddressForMovie:movie];
}


- (NSString*) wikipediaAddressForMovie:(Movie*) movie {
    return [wikipediaCache wikipediaAddressForMovie:movie];
}


- (DVD*) dvdDetailsForMovie:(Movie*) movie {
    DVD* dvd = [dvdCache detailsForMovie:movie];
    if (dvd != nil) {
        return dvd;
    }

    dvd = [blurayCache detailsForMovie:movie];
    if (dvd != nil) {
        return dvd;
    }

    return nil;
}


- (NSString*) netflixAddressForMovie:(Movie*) movie {
    return [netflixCache netflixAddressForMovie:movie];
}


- (UIImage*) posterForMovie:(Movie*) movie
                    sources:(NSArray*) sources
                   selector:(SEL) selector {
    for (id source in sources) {
        UIImage* image = [source performSelector:selector withObject:movie];
        if (image != nil) {
            return image;
        }
    }

    return nil;
}


- (UIImage*) posterForMovie:(Movie*) movie {
    return [self posterForMovie:movie
                        sources:[NSArray arrayWithObjects:posterCache, largePosterCache, nil]
                       selector:@selector(posterForMovie:)];
}


- (UIImage*) smallPosterForMovie:(Movie*) movie {
    return [self posterForMovie:movie
                        sources:[NSArray arrayWithObjects:posterCache, largePosterCache, nil]
                       selector:@selector(smallPosterForMovie:)];
}


- (NSMutableArray*) theatersShowingMovie:(Movie*) movie {
    NSMutableArray* array = [NSMutableArray array];

    for (Theater* theater in self.theaters) {
        if ([theater.movieTitles containsObject:movie.canonicalTitle]) {
            [array addObject:theater];
        }
    }

    return array;
}


- (NSArray*) moviesAtTheater:(Theater*) theater {
    NSMutableArray* array = [NSMutableArray array];

    for (Movie* movie in self.movies) {
        if ([theater.movieTitles containsObject:movie.canonicalTitle]) {
            [array addObject:movie];
        }
    }

    return array;
}


- (NSArray*) moviePerformances:(Movie*) movie forTheater:(Theater*) theater {
    return [dataProvider moviePerformances:movie forTheater:theater];
}


- (NSDate*) synchronizationDateForTheater:(Theater*) theater {
    return [dataProvider synchronizationDateForTheater:theater];
}


- (BOOL) isStale:(Theater*) theater {
    return [dataProvider isStale:theater];
}


- (NSString*) showtimesRetrievedOnString:(Theater*) theater {
    if ([self isStale:theater]) {
        // we're showing out of date information
        NSDate* theaterSyncDate = [self synchronizationDateForTheater:theater];
        return [NSString stringWithFormat:
                NSLocalizedString(@"Theater last reported show times on\n%@.", nil),
                [DateUtilities formatLongDate:theaterSyncDate]];
    } else {
        NSDate* globalSyncDate = [dataProvider lastLookupDate];
        if (globalSyncDate == nil) {
            return @"";
        }

        return [NSString stringWithFormat:
                NSLocalizedString(@"Show times retrieved on %@.", nil),
                [DateUtilities formatLongDate:globalSyncDate]];
    }
}


- (NSString*) simpleAddressForTheater:(Theater*) theater {
    return theater.simpleAddress;
}


- (NSDictionary*) theaterDistanceMap:(Location*) location
                            theaters:(NSArray*) theaters {
    NSMutableDictionary* theaterDistanceMap = [NSMutableDictionary dictionary];

    for (Theater* theater in theaters) {
        double d;
        if (location != nil) {
            d = [location distanceTo:theater.location];
        } else {
            d = UNKNOWN_DISTANCE;
        }

        NSNumber* value = [NSNumber numberWithDouble:d];
        NSString* key = theater.name;
        [theaterDistanceMap setObject:value forKey:key];
    }

    return theaterDistanceMap;
}


- (NSDictionary*) theaterDistanceMap {
    Location* location = [userLocationCache locationForUserAddress:self.userAddress];
    return [self theaterDistanceMap:location
                           theaters:self.theaters];
}


- (BOOL) tooFarAway:(double) distance {
    return
        distance != UNKNOWN_DISTANCE &&
        self.searchRadius < 50 &&
        distance > self.searchRadius;
}


- (NSArray*) theatersInRange:(NSArray*) theaters {
    NSDictionary* theaterDistanceMap = [self theaterDistanceMap];
    NSMutableArray* result = [NSMutableArray array];

    for (Theater* theater in theaters) {
        double distance = [[theaterDistanceMap objectForKey:theater.name] doubleValue];

        if ([self isFavoriteTheater:theater] || ![self tooFarAway:distance]) {
            [result addObject:theater];
        }
    }

    return result;
}


NSInteger compareMoviesByScore(id t1, id t2, void* context) {
    if (t1 == t2) {
        return NSOrderedSame;
    }

    Movie* movie1 = t1;
    Movie* movie2 = t2;
    Model* model = context;

    int movieRating1 = [model scoreValueForMovie:movie1];
    int movieRating2 = [model scoreValueForMovie:movie2];

    if (movieRating1 < movieRating2) {
        return NSOrderedDescending;
    } else if (movieRating1 > movieRating2) {
        return NSOrderedAscending;
    }

    return compareMoviesByTitle(t1, t2, context);
}


NSInteger compareMoviesByReleaseDateDescending(id t1, id t2, void* context) {
    if (t1 == t2) {
        return NSOrderedSame;
    }

    Model* model = context;
    Movie* movie1 = t1;
    Movie* movie2 = t2;

    NSDate* releaseDate1 = [model releaseDateForMovie:movie1];
    NSDate* releaseDate2 = [model releaseDateForMovie:movie2];

    if (releaseDate1 == nil) {
        if (releaseDate2 == nil) {
            return compareMoviesByTitle(movie1, movie2, context);
        } else {
            return NSOrderedDescending;
        }
    } else if (releaseDate2 == nil) {
        return NSOrderedAscending;
    }

    return -[releaseDate1 compare:releaseDate2];
}


NSInteger compareMoviesByReleaseDateAscending(id t1, id t2, void* context) {
    return -compareMoviesByReleaseDateDescending(t1, t2, context);
}


NSInteger compareMoviesByTitle(id t1, id t2, void* context) {
    if (t1 == t2) {
        return NSOrderedSame;
    }

    Model* model = context;

    Movie* movie1 = t1;
    Movie* movie2 = t2;

    BOOL movie1Bookmarked = [model isBookmarked:movie1];
    BOOL movie2Bookmarked = [model isBookmarked:movie2];

    if (movie1Bookmarked && !movie2Bookmarked) {
        return NSOrderedAscending;
    } else if (movie2Bookmarked && !movie1Bookmarked) {
        return NSOrderedDescending;
    }

    return [movie1.displayTitle compare:movie2.displayTitle options:NSCaseInsensitiveSearch];
}


NSInteger compareTheatersByName(id t1, id t2, void* context) {
    if (t1 == t2) {
        return NSOrderedSame;
    }

    Theater* theater1 = t1;
    Theater* theater2 = t2;

    return [theater1.name compare:theater2.name options:NSCaseInsensitiveSearch];
}


NSInteger compareTheatersByDistance(id t1, id t2, void* context) {
    if (t1 == t2) {
        return NSOrderedSame;
    }

    NSDictionary* theaterDistanceMap = context;

    Theater* theater1 = t1;
    Theater* theater2 = t2;

    double distance1 = [[theaterDistanceMap objectForKey:theater1.name] doubleValue];
    double distance2 = [[theaterDistanceMap objectForKey:theater2.name] doubleValue];

    if (distance1 < distance2) {
        return NSOrderedAscending;
    } else if (distance1 > distance2) {
        return NSOrderedDescending;
    }

    return compareTheatersByName(t1, t2, nil);
}


- (void) setUserAddress:(NSString*) userAddress {
    [[NSUserDefaults standardUserDefaults] setObject:userAddress forKey:USER_ADDRESS];
    [self synchronize];
}


- (Score*) scoreForMovie:(Movie*) movie {
    return [scoreCache scoreForMovie:movie];
}


- (Score*) rottenTomatoesScoreForMovie:(Movie*) movie {
    return [scoreCache rottenTomatoesScoreForMovie:movie];
}


- (Score*) metacriticScoreForMovie:(Movie*) movie {
    return [scoreCache metacriticScoreForMovie:movie];
}


- (NSInteger) scoreValueForMovie:(Movie*) movie {
    Score* score = [self scoreForMovie:movie];
    if (score == nil) {
        return -1;
    }

    return score.scoreValue;
}


- (NSString*) synopsisForMovie:(Movie*) movie {
    NSMutableArray* options = [NSMutableArray array];
    NSString* synopsis = movie.synopsis;
    if (synopsis.length > 0) {
        [options addObject:synopsis];
    }

    synopsis = [internationalDataCache synopsisForMovie:movie];
    if (synopsis.length > 0) {
        [options addObject:synopsis];
    }

    if (options.count == 0 || [LocaleUtilities isEnglish]) {
        synopsis = [self scoreForMovie:movie].synopsis;
        if (synopsis.length > 0) {
            [options addObject:synopsis];
        }

        synopsis = [upcomingCache synopsisForMovie:movie];
        if (synopsis.length > 0) {
            [options addObject:synopsis];
        }

        synopsis = [netflixCache synopsisForMovie:movie];
        if (synopsis.length > 0) {
            [options addObject:synopsis];
        }
    }

    if (options.count == 0) {
        return NSLocalizedString(@"No synopsis available.", nil);
    }


    NSString* bestOption = @"";
    for (NSString* option in options) {
        if (option.length > bestOption.length) {
            bestOption = option;
        }
    }

    return bestOption;
}


- (NSArray*) trailersForMovie:(Movie*) movie {
    NSArray* result = [internationalDataCache trailersForMovie:movie];
    if (result.count > 0) {
        return result;
    }

    result = [trailerCache trailersForMovie:movie];
    if (result.count > 0) {
        return result;
    }

    return [upcomingCache trailersForMovie:movie];
}


- (NSArray*) reviewsForMovie:(Movie*) movie {
    return [scoreCache reviewsForMovie:movie];
}


- (NSString*) noInformationFound {
    if (self.userAddress.length == 0) {
        return NSLocalizedString(@"Please enter your location", nil);
    } else if ([[OperationQueue operationQueue] hasPriorityOperations]) {
        return NSLocalizedString(@"Downloading data", nil);
    } else if (![NetworkUtilities isNetworkAvailable]) {
        return NSLocalizedString(@"Network unavailable", nil);
    } else if (![LocaleUtilities isSupportedCountry]) {
        return [NSString stringWithFormat:
                NSLocalizedString(@"Local results unavailable", nil),
                [LocaleUtilities displayCountry]];
    } else {
        return NSLocalizedString(@"No information found", nil);
    }
}


- (BOOL) useSmallFonts {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:USE_NORMAL_FONTS];
}


- (void) setUseSmallFonts:(BOOL) useSmallFonts {
    [[NSUserDefaults standardUserDefaults] setBool:!useSmallFonts forKey:USE_NORMAL_FONTS];
}


- (void) saveNavigationStack:(UINavigationController*) controller {
    NSMutableArray* types = [NSMutableArray array];
    NSMutableArray* values = [NSMutableArray array];

    for (id viewController in controller.viewControllers) {
        NSInteger type;
        id value;
        if ([viewController isKindOfClass:[MovieDetailsViewController class]]) {
            type = MovieDetails;
            value = [[viewController movie] canonicalTitle];
        } else if ([viewController isKindOfClass:[TheaterDetailsViewController class]]) {
            type = TheaterDetails;
            value = [[viewController theater] name];
        } else if ([viewController isKindOfClass:[ReviewsViewController class]]) {
            type = Reviews;
            value = [[viewController movie] canonicalTitle];
        } else if ([viewController isKindOfClass:[TicketsViewController class]]) {
            type = Tickets;
            value = [NSArray arrayWithObjects:[[viewController movie] canonicalTitle], [[viewController theater] name], [viewController title], nil];
        } else if ([viewController isKindOfClass:[AllMoviesViewController class]] ||
                   [viewController isKindOfClass:[AllTheatersViewController class]] ||
                   [viewController isKindOfClass:[UpcomingMoviesViewController class]] ||
                   [viewController isKindOfClass:[DVDViewController class]]) {
            continue;
        } else if ([viewController isKindOfClass:[NetflixViewController class]] ||
                   [viewController isKindOfClass:[SettingsViewController class]]) {
            break;
        } else {
            break;
        }

        [types addObject:[NSNumber numberWithInt:type]];
        [values addObject:value];
    }

    [[NSUserDefaults standardUserDefaults] setObject:types forKey:NAVIGATION_STACK_TYPES];
    [[NSUserDefaults standardUserDefaults] setObject:values forKey:NAVIGATION_STACK_VALUES];
}


- (NSArray*) navigationStackTypes {
    NSArray* result = [[NSUserDefaults standardUserDefaults] arrayForKey:NAVIGATION_STACK_TYPES];
    if (result == nil) {
        return [NSArray array];
    }

    return result;
}


- (NSArray*) navigationStackValues {
    NSArray* result = [[NSUserDefaults standardUserDefaults] arrayForKey:NAVIGATION_STACK_VALUES];
    if (result == nil) {
        return [NSArray array];
    }

    return result;
}

@end