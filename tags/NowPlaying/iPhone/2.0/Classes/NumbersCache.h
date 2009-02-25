// Copyright (C) 2008 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#define RETRIEVING NAN
#define NOT_ENOUGH_DATA INFINITY
#define IS_RETRIEVING isnan
#define IS_NOT_ENOUGH_DATA isinf

@interface NumbersCache : NSObject {
    NSLock* gate;
    NSDictionary* indexData;
}

@property (retain) NSLock* gate;
@property (retain) NSDictionary* indexData;

+ (NumbersCache*) cache;

- (void) updateIndex;

- (NSArray*) weekendNumbers;
- (NSArray*) dailyNumbers;

- (double) dailyChange:(MovieNumbers*) movie;
- (double) weekendChange:(MovieNumbers*) movie;
- (double) totalChange:(MovieNumbers*) movie;
- (NSInteger) budgetForMovie:(MovieNumbers*) movie;

@end