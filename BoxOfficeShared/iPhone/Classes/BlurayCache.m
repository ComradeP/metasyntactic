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

#import "BlurayCache.h"

#import "Application.h"
#import "Model.h"

@implementation BlurayCache

static BlurayCache* cache;

+ (void) initialize {
  if (self == [BlurayCache class]) {
    cache = [[BlurayCache alloc] init];
  }
}


+ (BlurayCache*) cache {
  return cache;
}


- (Model*) model {
  return [Model model];
}


- (void) update {
  if (!self.model.dvdMoviesShowBluray) {
    return;
  }

  [super update];
}


- (NSArray*) loadBookmarksArray {
  return [self.model bookmarkedBluray];
}


- (NSString*) serverAddress {
  return [NSString stringWithFormat:@"http://%@.appspot.com/LookupDVDListings%@?q=bluray",
          [Application apiHost], [Application apiVersion]];
}


- (NSString*) directory {
  return [Application blurayDirectory];
}


- (NSString*) notificationString {
  return @"bluray";
}

@end
