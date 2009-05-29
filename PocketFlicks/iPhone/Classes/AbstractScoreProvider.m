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

#import "AbstractScoreProvider.h"

#import "AppDelegate.h"
#import "Application.h"
#import "Model.h"
#import "Movie.h"
#import "Review.h"
#import "Score.h"
#import "UserLocationCache.h"

@interface AbstractScoreProvider()
@property (retain) NSDictionary* scoresData;
@property (copy) NSString* hashData;
@property (retain) NSArray* moviesData;
@property (retain) NSDictionary* movieMapData;
@property (copy) NSString* providerDirectory;
@property (copy) NSString* reviewsDirectory;
@end


@implementation AbstractScoreProvider

@synthesize scoresData;
@synthesize hashData;
@synthesize moviesData;
@synthesize movieMapData;
@synthesize providerDirectory;
@synthesize reviewsDirectory;

- (void) dealloc {
    self.scoresData = nil;
    self.hashData = nil;
    self.moviesData = nil;
    self.movieMapData = nil;
    self.providerDirectory = nil;
    self.reviewsDirectory = nil;

    [super dealloc];
}


- (NSString*) providerName {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (NSString*) lookupServerHash {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (NSDictionary*) lookupServerScores {
    @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (id) init {
    if (self = [super init]) {
        self.providerDirectory = [[Application scoresDirectory] stringByAppendingPathComponent:self.providerName];
        self.reviewsDirectory = [[Application reviewsDirectory] stringByAppendingPathComponent:self.providerName];

        [FileUtilities createDirectory:providerDirectory];
        [FileUtilities createDirectory:reviewsDirectory];
    }

    return self;
}


- (Model*) model {
    return [Model model];
}


- (NSString*) scoresFile {
    return [providerDirectory stringByAppendingPathComponent:@"Scores.plist"];
}


- (NSString*) hashFile {
    return [providerDirectory stringByAppendingPathComponent:@"Hash.plist"];
}


- (NSString*) movieMapFile {
    return [providerDirectory stringByAppendingPathComponent:@"Map.plist"];
}


- (NSString*) reviewsFile:(NSString*) title {
    return [[reviewsDirectory stringByAppendingPathComponent:[FileUtilities sanitizeFileName:title]]
                              stringByAppendingPathExtension:@"plist"];
}


- (NSString*) reviewsHashFile:(NSString*) title {
    return [reviewsDirectory stringByAppendingPathComponent:[[FileUtilities sanitizeFileName:title] stringByAppendingString:@"-Hash.plist"]];
}


- (NSArray*) moviesNoLock {
    if (moviesData == nil) {
        self.moviesData = [NSArray array];
    }

    // Access through the property so that we get back a safe pointer
    return self.moviesData;
}


- (NSArray*) movies {
    NSArray* result = nil;
    [dataGate lock];
    {
        result = [self moviesNoLock];
    }
    [dataGate unlock];
    return result;
}


- (NSDictionary*) loadScores {
    NSDictionary* encodedScores = [FileUtilities readObject:self.scoresFile];
    if (encodedScores == nil) {
        return [NSDictionary dictionary];
    }

    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (NSString* title in encodedScores) {
        Score* score = [Score scoreWithDictionary:[encodedScores objectForKey:title]];
        [result setObject:score forKey:title];
    }

    return result;
}


- (NSString*) loadHash {
    NSString* result = [FileUtilities readObject:self.hashFile];
    if (result == nil) {
        return @"";
    }
    return result;
}


- (NSDictionary*) scoresNoLock {
    if (scoresData == nil) {
        self.scoresData = [self loadScores];
    }

    // Access through the property so that we get back a safe pointer
    return self.scoresData;
}


- (NSDictionary*) scores {
    NSDictionary* result = nil;
    [dataGate lock];
    {
        result = [self scoresNoLock];
    }
    [dataGate unlock];
    return result;
}


- (NSString*) hashValueNoLock {
    if (hashData == nil) {
        self.hashData = [self loadHash];
    }

    // Access through the property so that we get back a safe pointer
    return self.hashData;
}


- (NSString*) hashValue {
    NSString* result = nil;
    [dataGate lock];
    {
        result = [self hashValueNoLock];
    }
    [dataGate unlock];
    return result;
}


- (void) ensureMovieMapNoLock {
    NSArray* moviesArray = [[Model model] movies];
    if (moviesArray != self.moviesNoLock) {
        NSLog(@"AbstractScoreProvider:ensureMovieMapNoLock - regenerating map");
        self.moviesData = moviesArray;

        [[OperationQueue operationQueue] performSelector:@selector(regenerateMap)
                                                onTarget:self
                                                    gate:runGate
                                                priority:Now];
    }
}


- (NSDictionary*) loadMovieMap {
    NSDictionary* result = [FileUtilities readObject:self.movieMapFile];
    if (result.count == 0) {
        return [NSDictionary dictionary];
    }
    return result;
}


- (NSDictionary*) movieMapNoLock {
    if (movieMapData == nil) {
        self.movieMapData = [self loadMovieMap];
    }

    [self ensureMovieMapNoLock];

    // Access through the property so that we get back a safe pointer
    return self.movieMapData;
}


- (NSDictionary*) movieMap {
    NSDictionary* result = nil;
    [dataGate lock];
    {
        result = [self movieMapNoLock];
    }
    [dataGate unlock];
    return result;
}


- (void) saveScores:(NSDictionary*) scores hash:(NSString*) hash {
    NSMutableDictionary* encodedScores = [NSMutableDictionary dictionary];
    for (NSString* title in scores) {
        NSDictionary* dictionary = [[scores objectForKey:title] dictionary];
        [encodedScores setObject:dictionary forKey:title];
    }

    [FileUtilities writeObject:encodedScores toFile:self.scoresFile];
    [FileUtilities writeObject:hash toFile:self.hashFile];
}


- (NSDictionary*) regenerateMapWorker:(NSDictionary*) scores
                            forMovies:(NSArray*) movies {
    NSLog(@"AbstractScoreProvider:regenerateMapWorker - scores:%d movies:%d", scores.count, movies.count);

    NSMutableDictionary* result = [NSMutableDictionary dictionary];

    NSArray* keys = scores.allKeys;
    NSMutableArray* lowercaseKeys = [NSMutableArray array];
    for (NSString* key in keys) {
        [lowercaseKeys addObject:key.lowercaseString];
    }

    DifferenceEngine* engine = [DifferenceEngine engine];

    for (Movie* movie in movies) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        {
            NSString* lowercaseTitle = movie.canonicalTitle.lowercaseString;
            NSInteger index = [lowercaseKeys indexOfObject:lowercaseTitle];
            if (index == NSNotFound) {
                index = [engine findClosestMatchIndex:movie.canonicalTitle.lowercaseString inArray:lowercaseKeys];
            }

            if (index != NSNotFound) {
                NSString* key = [keys objectAtIndex:index];
                [result setObject:key forKey:movie.canonicalTitle];
            }
        }
        [pool release];
    }

    return result;
}


- (void) regenerateMap {
    NSDictionary* scores = self.scores;
    NSArray* movies = self.movies;

    NSDictionary* map = [self regenerateMapWorker:scores forMovies:movies];
    if (map.count == 0) {
        return;
    }

    [dataGate lock];
    {
        [FileUtilities writeObject:map toFile:[self movieMapFile]];
        self.movieMapData = map;
        self.moviesData = movies;
        [self clearUpdatedMovies];
    }
    [dataGate unlock];

    [AppDelegate majorRefresh];

}

- (void) updateScoresWorker {
    NSString* localHash = self.hashValue;
    NSString* serverHash = [self lookupServerHash];

    if (serverHash.length == 0 ||
        [serverHash isEqual:@"0"]) {
        return;
    }

    if ([serverHash isEqual:localHash]) {
        // rewrite the hash so we don't this for another day.
        [FileUtilities writeObject:serverHash toFile:self.hashFile];
        return;
    }

    NSDictionary* scores = [self lookupServerScores];
    if (scores.count == 0) {
        return;
    }

    [self saveScores:scores hash:serverHash];
    NSArray* movies = [self.model movies];

    NSDictionary* map = [self regenerateMapWorker:scores forMovies:movies];

    [dataGate lock];
    {
        [FileUtilities writeObject:map toFile:[self movieMapFile]];
        self.moviesData = movies;
        self.movieMapData = map;

        self.scoresData = scores;
        self.hashData = serverHash;
    }
    [dataGate unlock];

    [AppDelegate majorRefresh:YES];
}


- (void) updateScoresBackgroundEntryPointWorker:(BOOL) notification {
    NSDate* lastLookupDate = [FileUtilities modificationDate:self.hashFile];

    if (lastLookupDate != nil) {
        if (ABS(lastLookupDate.timeIntervalSinceNow) < ONE_DAY) {
            return;
        }
    }

    NSString* notificationString = [NSString stringWithFormat:LocalizedString(@"%@ scores", @"%@ will be replaced with the score provider.  i.e. Google, Rottentomatoes or Metacritic"), [[Model model] currentScoreProvider]];
    if (notification) {
        [NotificationCenter addNotification:notificationString];
    }

    [self updateScoresWorker];

    if (notification) {
        [NotificationCenter removeNotification:notificationString];
    }
}


- (void) updateScoresBackgroundEntryPoint:(BOOL) notification {
    [self updateScoresBackgroundEntryPointWorker:notification];
    [self clearUpdatedMovies];
}


- (NSMutableArray*) extractReviews:(XmlElement*) element {
    NSMutableArray* result = [NSMutableArray array];
    for (XmlElement* reviewElement in element.children) {
        NSString* text = [reviewElement attributeValue:@"text"];
        NSString* score = [reviewElement attributeValue:@"score"];
        NSString* link = [reviewElement attributeValue:@"link"];
        NSString* author = [reviewElement attributeValue:@"author"];
        NSString* source = [reviewElement attributeValue:@"source"];

        if ([author rangeOfString:@"HREF"].length > 0) {
            continue;
        }

        NSInteger scoreValue = [score intValue];

        [result addObject:[Review reviewWithText:text
                    score:scoreValue
                     link:link
                   author:author
                   source:source]];
    }

    return result;
}


- (NSString*) serverReviewsAddress:(Location*) location
                             score:(Score*) score {
    NSString* country = location.country.length == 0 ? [LocaleUtilities isoCountry] :
    location.country;

    NSString* url =
    [NSString stringWithFormat:@"http://%@.appspot.com/LookupMovieReviews2?country=%@&language=%@&id=%@&provider=%@&latitude=%d&longitude=%d",
     [Application host],
     country,
     [LocaleUtilities preferredLanguage],
     score.identifier,
     score.provider,
     (int)(location.latitude * 1000000),
     (int)(location.longitude * 1000000)];

    return url;
}


- (NSMutableArray*) downloadReviewContents:(Score*) score
                                  location:(Location*) location {
    NSString* address = [self serverReviewsAddress:location
                                             score:score];
    NSData* data = [NetworkUtilities dataWithContentsOfAddress:address];
    if (data == nil) {
        // We couldn't even connect.  Just abort what we're doing.
        return nil;
    }

    XmlElement* element = [XmlParser parse:data];
    if (element == nil) {
        // we got an empty string back.  record this so we don't try
        // downloading for another two days.
        return [NSMutableArray array];
    }

    return [self extractReviews:element];
}


- (void) saveEncodedReviews:(NSArray*) encodedReviews
                       hash:(NSString*) hash
                      title:(NSString*) title {
    [FileUtilities writeObject:encodedReviews toFile:[self reviewsFile:title]];
    // do this last.  it marks us being complete.
    [FileUtilities writeObject:hash toFile:[self reviewsHashFile:title]];
}


- (void) saveReviews:(NSArray*) reviews
                hash:(NSString*) hash
               title:(NSString*) title {
    NSMutableArray* encodedReviews = [NSMutableArray array];
    for (Review* review in reviews) {
        [encodedReviews addObject:review.dictionary];
    }

    [self saveEncodedReviews:encodedReviews hash:hash title:title];
}


- (void) downloadReviews:(Score*) score
                location:(Location*) location
                   force:(BOOL) force {
    if (score == nil || location == nil) {
        return;
    }

    NSString* title = score.canonicalTitle;
    NSString* reviewsFile = [self reviewsFile:title];

    NSDate* modificationDate = [FileUtilities modificationDate:reviewsFile];
    if (modificationDate != nil) {
        if (ABS([modificationDate timeIntervalSinceNow]) < THREE_DAYS) {
            NSArray* reviews = [FileUtilities readObject:reviewsFile];
            if (reviews.count > 0) {
                return;
            }

            if (!force) {
                return;
            }
        }
    }

    NSString* address = [[self serverReviewsAddress:location score:score] stringByAppendingString:@"&hash=true"];
    NSString* localHash = [FileUtilities readObject:[self reviewsHashFile:score.canonicalTitle]];
    NSString* serverHash = [NetworkUtilities stringWithContentsOfAddress:address];

    if (serverHash.length == 0 ||
        [serverHash isEqual:@"0"]) {
        return;
    }

    if ([serverHash isEqual:localHash]) {
        // save the hash again so we don't check for a few more days.
        [FileUtilities writeObject:serverHash toFile:[self reviewsHashFile:title]];
        return;
    }

    NSMutableArray* reviews = [self downloadReviewContents:score location:location];
    if (reviews == nil) {
        // didn't download.  just ignore it.
        return;
    }

    if (reviews.count == 0) {
        // we got no reviews.  only save that fact if we don't currently have
        // any reviews.  This way we don't end up checking every single time
        // for movies that don't have reviews yet
        NSArray* existingReviews = [FileUtilities readObject:[self reviewsFile:title]];
        if (existingReviews.count > 0) {
            // we have reviews already.  don't wipe it out.
            // rewrite the reviews so the mod date is correct.
            [Application moveItemToTrash:[self reviewsFile:title]];
            [self saveEncodedReviews:existingReviews hash:serverHash title:title];
            return;
        }
    }

    [reviews sortUsingSelector:@selector(compare:)];
    [self saveReviews:reviews hash:serverHash title:title];

    [AppDelegate minorRefresh];
}


- (void) updateMovieDetails:(Movie*) movie force:(BOOL) force {
    Score* score = [self.scores objectForKey:[self.movieMap objectForKey:movie.canonicalTitle]];
    if (score == nil) {
        return;
    }

    Location* location = [self.model.userLocationCache downloadUserAddressLocationBackgroundEntryPoint:self.model.userAddress];
    if (location == nil) {
        return;
    }

    [self downloadReviews:score location:location force:force];
}


- (void) updateReviewsBackgroundEntryPoint {
    Location* location = [self.model.userLocationCache downloadUserAddressLocationBackgroundEntryPoint:self.model.userAddress];
    if (location == nil) {
        return;
    }

    for (Score* score in self.scores.allValues) {
        NSString* file = [self reviewsHashFile:score.canonicalTitle];

        NSDate* lastLookupDate = [FileUtilities modificationDate:file];

        if (lastLookupDate == nil ||
            (ABS(lastLookupDate.timeIntervalSinceNow) > THREE_DAYS)) {
            [[OperationQueue operationQueue] performSelector:@selector(downloadReviews:location:)
                                                    onTarget:self
                                                  withObject:score
                                                  withObject:location
                                                        gate:runGate
                                                    priority:Low];
        }
    }
}


- (void) downloadReviews:(Score*) score
                location:(Location*) location {
    [self downloadReviews:score location:location force:NO];
}


- (void) update:(BOOL) notifications {
    [runGate lock];
    {
        [self updateScoresBackgroundEntryPoint:notifications];
        [self updateReviewsBackgroundEntryPoint];
    }
    [runGate unlock];
}


- (void) updateWithNotifications {
    [self update:YES];
}


- (void) updateWithoutNotifications {
    [self update:NO];
}


- (Score*) scoreForMovie:(Movie*) movie {
    NSString* title = [self.movieMap objectForKey:movie.canonicalTitle];
    return [self.scores objectForKey:title];
}


- (NSArray*) reviewsForMovie:(Movie*) movie {
    NSString* title = [self.movieMap objectForKey:movie.canonicalTitle];
    NSArray* encodedResult = [FileUtilities readObject:[self reviewsFile:title]];

    if (encodedResult == nil) {
        return [NSArray array];
    }

    NSMutableArray* result = [NSMutableArray array];
    for (NSDictionary* dictionary in encodedResult) {
        [result addObject:[Review reviewWithDictionary:dictionary]];
    }

    return result;
}

@end