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

#import "FandangoPosterDownloader.h"

#import "Application.h"
#import "LargePosterCache.h"

@implementation FandangoPosterDownloader

- (NSDictionary*) processFandangoElement:(XmlElement*) element {
  NSMutableDictionary* map = [NSMutableDictionary dictionary];

  XmlElement* dataElement = [element element:@"data"];
  XmlElement* moviesElement = [dataElement element:@"movies"];

  for (XmlElement* movieElement in moviesElement.children) {
    NSString* poster = [movieElement attributeValue:@"posterhref"];
    NSString* title = [movieElement element:@"title"].text;

    if (poster.length == 0 || title.length == 0) {
      continue;
    }

    title = [[Movie makeCanonical:title] lowercaseString];

    [map setObject:poster forKey:title];
  }

  return map;
}


- (NSDictionary*) createMapWorker {
  NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupPosterListings%@?provider=fandango",
                   [Application apiHost], [Application apiVersion]];
  
  XmlElement* element = [NetworkUtilities xmlWithContentsOfAddress:url pause:NO];
  return [LargePosterCache processPosterListings:element];
}

@end
