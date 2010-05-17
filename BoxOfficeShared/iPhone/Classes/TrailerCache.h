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

@interface TrailerCache : AbstractMovieCache {
@private
  // Accessed from different threads.  needs gate.
  PersistentDictionaryThreadsafeValue*/*NSDictionary*/ indexData;
  ThreadsafeValue*/*NSArray*/ indexKeysData;
  
  BOOL updated;
}

+ (TrailerCache*) cache;

- (void) update;
- (NSArray*) trailersForMovie:(Movie*) movie;

+ (NSString*) downloadIndexString;
+ (id) downloadJSONIndex;
+ (NSDictionary/*<NSString*,(NSString*,NSString*)>*/*) processJSONIndex:(id) index;

+ (NSString*) downloadXmlStringForStudioKey:(NSString*) studioKey titleKey:(NSString*) titleKey;
+ (XmlElement*) downloadXmlElementForStudioKey:(NSString*) studioKey titleKey:(NSString*) titleKey;
+ (NSArray*) downloadTrailersForStudioKey:(NSString*) studioKey titleKey:(NSString*) titleKey;

@end
