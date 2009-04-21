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

#import "IMDbCache.h"

#import "AppDelegate.h"
#import "Application.h"
#import "FileUtilities.h"
#import "Movie.h"
#import "NetworkUtilities.h"
#import "StringUtilities.h"

@interface IMDbCache()
@end


@implementation IMDbCache

- (void) dealloc {
    [super dealloc];
}


+ (IMDbCache*) cache {
    return [[[IMDbCache alloc] init] autorelease];
}


- (NSString*) imdbFile:(Movie*) movie {
    NSString* name = [[FileUtilities sanitizeFileName:movie.canonicalTitle] stringByAppendingPathExtension:@"plist"];
    return [[Application imdbDirectory] stringByAppendingPathComponent:name];
}


- (void) updateMovieDetails:(Movie*) movie force:force {
    if (movie.imdbAddress.length > 0) {
        // don't even bother if the movie has an imdb address in it
        return;
    }

    NSString* path = [self imdbFile:movie];

    NSDate* lastLookupDate = [FileUtilities modificationDate:path];
    if (lastLookupDate != nil) {
        NSString* value = [FileUtilities readObject:path];
        if (value.length > 0) {
            // we have a real imdb value for this movie
            return;
        }

        if (!force) {
            // we have a sentinel.  only update if it's been long enough
            if (ABS(lastLookupDate.timeIntervalSinceNow) < THREE_DAYS) {
                return;
            }
        }
    }

    NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupIMDbListings?q=%@", [Application host], [StringUtilities stringByAddingPercentEscapes:movie.canonicalTitle]];
    NSString* imdbAddress = [NetworkUtilities stringWithContentsOfAddress:url];
    if (imdbAddress == nil) {
        return;
    }

    // write down the response (even if it is empty).  An empty value will
    // ensure that we don't update this entry too often.
    [FileUtilities writeObject:imdbAddress toFile:path];
    if (imdbAddress.length > 0) {
        [AppDelegate minorRefresh];
    }
}


- (NSString*) imdbAddressForMovie:(Movie*) movie {
    return [FileUtilities readObject:[self imdbFile:movie]];
}

@end