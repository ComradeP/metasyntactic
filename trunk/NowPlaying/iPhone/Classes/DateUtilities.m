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

#import "DateUtilities.h"

@implementation DateUtilities

static NSMutableDictionary* timeDifferenceMap;
static NSCalendar* calendar;
static NSDate* today;
static NSRecursiveLock* gate = nil;


static NSDateFormatter* shortDateFormatter;
static NSDateFormatter* mediumDateFormatter;
static NSDateFormatter* longDateFormatter;
static NSDateFormatter* fullDateFormatter;
static NSDateFormatter* shortTimeFormatter;


static NSMutableDictionary* yearsAgoMap;
static NSMutableDictionary* monthsAgoMap;
static NSMutableDictionary* weeksAgoMap;


static BOOL use24HourTime;

+ (void) initialize {
    if (self == [DateUtilities class]) {
        gate = [[NSRecursiveLock alloc] init];

        timeDifferenceMap = [[NSMutableDictionary dictionary] retain];
        calendar = [[NSCalendar currentCalendar] retain];
        NSDateComponents* todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                        fromDate:[NSDate date]];
        todayComponents.hour = 12;
        today = [[calendar dateFromComponents:todayComponents] retain];

        yearsAgoMap = [[NSMutableDictionary dictionary] retain];
        monthsAgoMap = [[NSMutableDictionary dictionary] retain];
        weeksAgoMap = [[NSMutableDictionary dictionary] retain];

        {
            shortDateFormatter = [[NSDateFormatter alloc] init];
            [shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
            [shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        }

        {
            mediumDateFormatter = [[NSDateFormatter alloc] init];
            [mediumDateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [mediumDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        }

        {
            longDateFormatter = [[NSDateFormatter alloc] init];
            [longDateFormatter setDateStyle:NSDateFormatterLongStyle];
            [longDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        }

        {
            fullDateFormatter = [[NSDateFormatter alloc] init];
            [fullDateFormatter setDateStyle:NSDateFormatterFullStyle];
            [fullDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        }

        {
            shortTimeFormatter = [[NSDateFormatter alloc] init];
            [shortTimeFormatter setDateStyle:NSDateFormatterNoStyle];
            [shortTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
        }

        {
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setTimeStyle:NSDateFormatterLongStyle];
            use24HourTime = [[formatter dateFormat] rangeOfString:@"H"].length != 0;
        }
    }
}


+ (NSString*) agoString:(NSInteger) time
                    map:(NSMutableDictionary*) map
               singular:(NSString*) singular
                 plural:(NSString*) plural {
    if (time == 1) {
        return singular;
    } else {
        NSNumber* number = [NSNumber numberWithInt:time];
        NSString* result = [map objectForKey:number];
        if (result == nil) {
            result = [NSString stringWithFormat:plural, time];
            [map setObject:result forKey:number];
        }
        return result;
    }
}


+ (NSString*) yearsAgoString:(NSInteger) year {
    return [self agoString:year
                       map:yearsAgoMap
                  singular:NSLocalizedString(@"1 year ago", nil)
                    plural:NSLocalizedString(@"%d years ago", nil)];
}


+ (NSString*) monthsAgoString:(NSInteger) month {
    return [self agoString:month
                       map:monthsAgoMap
                  singular:NSLocalizedString(@"1 month ago", nil)
                    plural:NSLocalizedString(@"%d months ago", nil)];
}


+ (NSString*) weeksAgoString:(NSInteger) week {
    return [self agoString:week
                       map:weeksAgoMap
                  singular:NSLocalizedString(@"1 week ago", nil)
                    plural:NSLocalizedString(@"%d weeks ago", nil)];
}


+ (NSString*) timeSinceNowWorker:(NSDate*) date {
    NSTimeInterval interval = [today timeIntervalSinceDate:date];
    if (interval > ONE_YEAR) {
        return [self yearsAgoString:(int)(interval / ONE_YEAR)];
    } else if (interval > ONE_MONTH) {
        return [self monthsAgoString:(int)(interval / ONE_MONTH)];
    } else if (interval > ONE_WEEK) {
        return [self weeksAgoString:(int)(interval / ONE_WEEK)];
    }

    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit)
                                               fromDate:date
                                                 toDate:today
                                                options:0];

    if (components.day == 0) {
        return NSLocalizedString(@"Today", nil);
    } else if (components.day == 1) {
        return NSLocalizedString(@"Yesterday", nil);
    } else {
        NSDateComponents* components2 = [calendar components:NSWeekdayCalendarUnit fromDate:date];

        NSInteger weekday = components2.weekday;
        switch (weekday) {
            case 1: return NSLocalizedString(@"Last Sunday", nil);
            case 2: return NSLocalizedString(@"Last Monday", nil);
            case 3: return NSLocalizedString(@"Last Tuesday", nil);
            case 4: return NSLocalizedString(@"Last Wednesday", nil);
            case 5: return NSLocalizedString(@"Last Thursday", nil);
            case 6: return NSLocalizedString(@"Last Friday", nil);
            default: return NSLocalizedString(@"Last Saturday", nil);
        }
    }
}


+ (NSString*) timeSinceNow:(NSDate*) date {
    NSString* result = [timeDifferenceMap objectForKey:date];
    if (result == nil) {
        result = [DateUtilities timeSinceNowWorker:date];
        [timeDifferenceMap setObject:result forKey:date];
    }
    return result;
}


+ (NSDate*) today {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                               fromDate:[NSDate date]];
    [components setHour:12];
    return [calendar dateFromComponents:components];
}


+ (NSDate*) tomorrow {
    NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
    components.day = 1;

    return [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                         toDate:[DateUtilities today]
                                                        options:0];
}


+ (BOOL) isSameDay:(NSDate*) d1
              date:(NSDate*) d2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:d1];
    NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:d2];

    return
    [components1 year] == [components2 year] &&
    [components1 month] == [components2 month] &&
    [components1 day] == [components2 day];
}


+ (BOOL) isToday:(NSDate*) date {
    return [DateUtilities isSameDay:[NSDate date] date:date];
}


+ (NSString*) format:(NSDate*) date formatter:(NSDateFormatter*) formatter {
    NSString* result;
    [gate lock];
    {
        result = [formatter stringFromDate:date];
    }
    [gate unlock];
    return result;
}


+ (NSString*) formatShortTime:(NSDate*) date {
    return [self format:date formatter:shortTimeFormatter];
}


+ (NSString*) formatMediumDate:(NSDate*) date {
    return [self format:date formatter:mediumDateFormatter];
}


+ (NSString*) formatShortDate:(NSDate*) date {
    return [self format:date formatter:shortDateFormatter];
}


+ (NSString*) formatLongDate:(NSDate*) date {
    return [self format:date formatter:longDateFormatter];
}


+ (NSString*) formatFullDate:(NSDate*) date {
    return [self format:date formatter:fullDateFormatter];
}


+ (NSDate*) dateWithNaturalLanguageString:(NSString*) string {
    //return nil;
    return [NSDate dateWithNaturalLanguageString:string];
}


+ (NSDate*) parseIS08601Date:(NSString*) string {
    if (string.length == 10) {
        NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
        components.year = [[string substringWithRange:NSMakeRange(0, 4)] intValue];
        components.month = [[string substringWithRange:NSMakeRange(5, 2)] intValue];
        components.day = [[string substringWithRange:NSMakeRange(8, 2)] intValue];

        return [[NSCalendar currentCalendar] dateFromComponents:components];
    }

    return nil;
}


+ (BOOL) use24HourTime {
    return use24HourTime;
}

@end