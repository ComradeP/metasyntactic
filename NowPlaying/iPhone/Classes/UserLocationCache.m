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

#import "UserLocationCache.h"

#import "AppDelegate.h"
#import "Application.h"
#import "LocaleUtilities.h"
#import "Location.h"
#import "NotificationCenter.h"
#import "Utilities.h"

@interface UserLocationCache()
@end


@implementation UserLocationCache

- (void) dealloc {
    [super dealloc];
}


- (id) init {
    if (self = [super init]) {
    }

    return self;
}


+ (UserLocationCache*) cache {
    return [[[UserLocationCache alloc] init] autorelease];
}


- (BOOL) containsNumber:(NSString*) string {
    for (int i = 0; i < string.length; i++) {
        unichar c = [string characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            return YES;
        }
    }

    return NO;
}


- (NSString*) massageAddress:(NSString*) userAddress {
    userAddress = [userAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (userAddress.length <= 8 &&
        [self containsNumber:userAddress]) {
        // possibly a postal code.  append the country to help make it unique

        NSString* country = [LocaleUtilities englishCountry];
        if (country != nil) {
            return [NSString stringWithFormat:@"%@. %@", userAddress, country];
        }
    }

    return nil;
}


- (NSString*) locationDirectory {
    return [Application userLocationsDirectory];
}


- (Location*) locationForUserAddress:(NSString*) userAddress {
    if (userAddress.length == 0) {
        return nil;
    }

    //NSLog(@"UserLocationCache:locationForUserAddress - Loading massaged address");
    Location* location = [self loadLocation:[self massageAddress:userAddress]];
    if (location != nil) {
        //NSLog(@"UserLocationCache:locationForUserAddress - Massaged address found");
        return location;
    }
    //NSLog(@"UserLocationCache:locationForUserAddress - Massaged address not found.  Loading normal address");

    return [self loadLocation:userAddress];
}


- (void) setLocation:(Location*) location
      forUserAddress:(NSString*) userAddress {
    [self saveLocation:location forAddress:userAddress];
}


- (Location*) downloadUserAddressLocationBackgroundEntryPointWorker:(NSString*) userAddress {
    if (userAddress.length == 0) {
        return nil;
    }

    NSAssert(![NSThread isMainThread], @"Only call this from the background");
    Location* location = [self locationForUserAddress:userAddress];
    
    if (location == nil) {
        NSLog(@"UserLocationCache:downloadWorker - Didn't find address in cache");
        
        NSString* notification = NSLocalizedString(@"location", nil);
        [AppDelegate addNotification:notification];
        {
            NSLog(@"UserLocationCache:downloadWorker - Downloading address address");

            location = [self downloadAddressLocationFromWebService:[self massageAddress:userAddress]];
            if ([location.country isEqual:[LocaleUtilities isoCountry]]) {
                NSLog(@"UserLocationCache:downloadWorker - Massaged address found");
            } else {
                NSLog(@"UserLocationCache:downloadWorker - Downloading non-massaged address");
                location = [self downloadAddressLocationFromWebService:userAddress];
            }
        }
        [AppDelegate removeNotification:notification];

        [self setLocation:location forUserAddress:userAddress];
    }   

    return location;
}


- (Location*) downloadUserAddressLocationBackgroundEntryPoint:(NSString*) userAddress {
    Location* result;
    [runGate lock];
    {
        result = [self downloadUserAddressLocationBackgroundEntryPointWorker:userAddress];
    }
    [runGate unlock];
    return result;
}

@end