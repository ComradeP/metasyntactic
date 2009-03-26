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

@interface Application : NSObject {
}

+ (NSString*) name;
+ (NSString*) nameAndVersion;

+ (NSString*) netflixKey;
+ (NSString*) netflixSecret;
+ (NSString*) netflixApplicationName;

+ (NSString*) trashDirectory;

+ (NSString*) dataDirectory;
+ (NSString*) imdbDirectory;
+ (NSString*) amazonDirectory;
+ (NSString*) wikipediaDirectory;
+ (NSString*) userLocationsDirectory;
+ (NSString*) moviesPostersDirectory;
+ (NSString*) largeMoviesPostersDirectory;
+ (NSString*) largeMoviesPostersIndexDirectory;
+ (NSString*) peoplePostersDirectory;
+ (NSString*) largePeoplePostersDirectory;
+ (NSString*) scoresDirectory;
+ (NSString*) reviewsDirectory;
+ (NSString*) trailersDirectory;

+ (NSString*) dvdDirectory;
+ (NSString*) dvdDetailsDirectory;

+ (NSString*) blurayDirectory;
+ (NSString*) blurayDetailsDirectory;

+ (NSString*) netflixDirectory;
+ (NSString*) netflixDetailsDirectory;
+ (NSString*) netflixSearchDirectory;
+ (NSString*) netflixQueuesDirectory;
+ (NSString*) netflixSeriesDirectory;
+ (NSString*) netflixUserRatingsDirectory;
+ (NSString*) netflixPredictedRatingsDirectory;
+ (NSString*) netflixRSSDirectory;

+ (NSString*) upcomingDirectory;
+ (NSString*) upcomingCastDirectory;
+ (NSString*) upcomingSynopsesDirectory;
+ (NSString*) upcomingTrailersDirectory;

+ (void) resetDirectories;
+ (void) resetNetflixDirectories;
+ (void) clearStaleData;

+ (NSString*) uniqueTemporaryDirectory;
+ (NSString*) uniqueTrashDirectory;

+ (void) moveItemToTrash:(NSString*) path;

+ (void) openBrowser:(NSString*) address;
+ (void) openMap:(NSString*) address;
+ (void) makeCall:(NSString*) phoneNumber;

+ (DifferenceEngine*) differenceEngine;

+ (NSString*) host;

+ (unichar) starCharacter;
+ (NSString*) emptyStarString;
+ (NSString*) halfStarString;
+ (NSString*) starString;

+ (BOOL) useKilometers;
+ (BOOL) canSendMail;

@end