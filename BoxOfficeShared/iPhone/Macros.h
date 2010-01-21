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

#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))

#define ONE_MINUTE (60.0)
#define ONE_HOUR   (60.0 * ONE_MINUTE)
#define ONE_DAY    (24.0 * ONE_HOUR)
#define TWO_DAYS   (2.0 * ONE_DAY)
#define THREE_DAYS (3.0 * ONE_DAY)
#define ONE_WEEK   (7.0 * ONE_DAY)
#define TWO_WEEKS  (2.0 * ONE_WEEK)
#define ONE_YEAR   (365.0 * ONE_DAY)
#define ONE_MONTH  (ONE_YEAR / 12.0)

#define property_definition(x) static NSString* x ## _key = @#x; @synthesize x


#define SMALL_POSTER_HEIGHT 99.0f
#define FULL_SCREEN_POSTER_HEIGHT 460
#define FULL_SCREEN_POSTER_WIDTH 310

#define CACHE_LIMIT (30.0 * ONE_DAY)

#define LocalizedString(key, comment) [MetasyntacticSharedApplication localizedString:key]

#define AbstractMethod { @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil]; }

#define BITS_ARE_SET(value, mask) (((value) & (mask)) == (mask))
#define CLEAR_BITS(value, mask) ((value) & ~(mask))
#define SET_BITS(value, mask) ((value) | (mask))

