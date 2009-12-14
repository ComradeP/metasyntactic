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

#import "PersonPosterCache.h"

#import "Application.h"
#import "Model.h"
#import "Person.h"

@interface PersonPosterCache()
//@property (retain) LinkedSet* normalPeople;
//@property (retain) LinkedSet* prioritizedPeople;
@end


@implementation PersonPosterCache

//@synthesize normalPeople;
//@synthesize prioritizedPeople;

- (void) dealloc {
  //self.normalPeople = nil;
  //self.prioritizedPeople = nil;

  [super dealloc];
}


+ (PersonPosterCache*) cache {
  return [[[PersonPosterCache alloc] init] autorelease];
}


- (void) update:(Person*) person {
}


- (void) prioritizePerson:(Person*) person {
}


- (NSString*) posterFilePath:(Person*) person {
  NSString* sanitizedTitle = [FileUtilities sanitizeFileName:person.name];
  return [[[Application peoplePostersDirectory] stringByAppendingPathComponent:sanitizedTitle] stringByAppendingPathExtension:@"jpg"];
}


- (NSString*) smallPosterFilePath:(Person*) person {
  NSString* sanitizedTitle = [FileUtilities sanitizeFileName:person.name];
  return [[[Application peoplePostersDirectory] stringByAppendingPathComponent:sanitizedTitle] stringByAppendingString:@"-small.png"];
}


- (BOOL) hasProperSuffix:(NSString*) name {
  NSString* lowercaseName = [name lowercaseString];

  return [lowercaseName hasSuffix:@"png"] ||
  [lowercaseName hasSuffix:@"jpg"] ||
  [lowercaseName hasSuffix:@"jpeg"];
}


- (BOOL) isStockImage:(NSString*) name {
  NSString* lowercaseName = [name lowercaseString];

  return
  [@"file:us-actor.png" isEqual:lowercaseName] ||
  [@"file:spainfilm.png" isEqual:lowercaseName];
}


- (NSData*) downloadPosterWorker:(Person*) person {
  return nil;
  NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupWikipediaListings%@?q=%@",
                   [Application apiHost], [Application apiVersion],
                   [StringUtilities stringByAddingPercentEscapes:person.name]];
  NSString* wikipediaAddress = [NetworkUtilities stringWithContentsOfAddress:url];

  if (wikipediaAddress.length == 0) {
    return nil;
  }

  NSRange slashRange = [wikipediaAddress rangeOfString:@"/" options:NSBackwardsSearch];
  if (slashRange.length == 0) {
    return nil;
  }

  NSString* wikiTitle = [wikipediaAddress substringFromIndex:slashRange.location + 1];
  if (wikiTitle.length == 0) {
    return nil;
  }

  NSString* wikiSearchAddress = [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&titles=%@&prop=images&format=xml", wikiTitle];
  XmlElement* apiElement = [NetworkUtilities xmlWithContentsOfAddress:wikiSearchAddress];
  NSArray* imElements = [apiElement elements:@"im" recurse:YES];

  NSString* imageName = nil;
  for (XmlElement* imElement in imElements) {
    NSString* name = [imElement attributeValue:@"title"];
    if ([self hasProperSuffix:name] &&
        ![self isStockImage:name]) {
      imageName = name;
      break;
    }
  }

  if (imageName.length == 0) {
    return nil;
  }

  NSString* wikiDetailsAddress = [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&titles=%@&prop=imageinfo&iiprop=url&format=xml", [StringUtilities stringByAddingPercentEscapes:imageName]];
  XmlElement* apiElement2 = [NetworkUtilities xmlWithContentsOfAddress:wikiDetailsAddress];
  XmlElement* iiElement = [apiElement2 element:@"ii" recurse:YES];

  NSString* imageUrl = [iiElement attributeValue:@"url"];

  return [NetworkUtilities dataWithContentsOfAddress:imageUrl];
}


- (void) downloadPoster:(Person*) person {
  NSString* path = [self posterFilePath:person];

  if ([FileUtilities fileExists:path]) {
    if ([FileUtilities size:path] > 0) {
      // already have a real poster.
      return;
    }

    if ([FileUtilities size:path] == 0) {
      // sentinel value.  only update if it's been long enough.
      NSDate* modificationDate = [FileUtilities modificationDate:path];
      if (ABS(modificationDate.timeIntervalSinceNow) < THREE_DAYS) {
        return;
      }
    }
  }

  NSData* data = [self downloadPosterWorker:person];
  if (data == nil && [NetworkUtilities isNetworkAvailable]) {
    data = [NSData data];
  }

  if (data != nil) {
    [FileUtilities writeData:data toFile:path];

    if (data.length > 0) {
      [MetasyntacticSharedApplication minorRefresh];
    }
  }
}


- (UIImage*) posterForPerson:(Person*) person {
  NSString* path = [self posterFilePath:person];
  return [[ImageCache cache] imageForPath:path];
}


- (UIImage*) smallPosterForPerson:(Person*) person {
  NSString* smallPosterPath = [self smallPosterFilePath:person];
  NSData* smallPosterData;

  if ([FileUtilities size:smallPosterPath] == 0) {
    NSData* normalPosterData = [FileUtilities readData:[self posterFilePath:person]];
    smallPosterData = [ImageUtilities scaleImageData:normalPosterData
                                            toHeight:SMALL_POSTER_HEIGHT];

    [FileUtilities writeData:smallPosterData toFile:smallPosterPath];
  } else {
    smallPosterData = [FileUtilities readData:smallPosterPath];
  }

  return [UIImage imageWithData:smallPosterData];
}

@end
