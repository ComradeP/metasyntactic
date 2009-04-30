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
static NSDateFormatter* yearFormatter;


static NSMutableDictionary* yearsAgoMap;
static NSMutableDictionary* monthsAgoMap;
static NSMutableDictionary* weeksAgoMap;


static BOOL use24HourTime;

+ (void) initialize {
    if (self == [DateUtilities class]) {
        gate = [[NSRecursiveLock alloc] init];

        timeDifferenceMap = [[NSMutableDictionary alloc] init];
        calendar = [[NSCalendar currentCalendar] retain];
        {
            NSDateComponents* todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                            fromDate:[NSDate date]];
            todayComponents.hour = 12;
            today = [[calendar dateFromComponents:todayComponents] retain];
        }

        yearsAgoMap = [[NSMutableDictionary alloc] init];
        monthsAgoMap = [[NSMutableDictionary alloc] init];
        weeksAgoMap = [[NSMutableDictionary alloc] init];

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
            yearFormatter = [[NSDateFormatter alloc] init];
            [yearFormatter setDateFormat:@"YYYY"];
        }

        {
            NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
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
                  singular:LocalizedString(@"1 year ago", nil)
                    plural:LocalizedString(@"%d years ago", nil)];
}


+ (NSString*) monthsAgoString:(NSInteger) month {
    return [self agoString:month
                       map:monthsAgoMap
                  singular:LocalizedString(@"1 month ago", nil)
                    plural:LocalizedString(@"%d months ago", nil)];
}


+ (NSString*) weeksAgoString:(NSInteger) week {
    return [self agoString:week
                       map:weeksAgoMap
                  singular:LocalizedString(@"1 week ago", nil)
                    plural:LocalizedString(@"%d weeks ago", nil)];
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
        return LocalizedString(@"Today", nil);
    } else if (components.day == 1) {
        return LocalizedString(@"Yesterday", nil);
    } else {
        NSDateComponents* components2 = [calendar components:NSWeekdayCalendarUnit fromDate:date];

        NSInteger weekday = components2.weekday;
        switch (weekday) {
            case 1: return LocalizedString(@"Last Sunday", nil);
            case 2: return LocalizedString(@"Last Monday", nil);
            case 3: return LocalizedString(@"Last Tuesday", nil);
            case 4: return LocalizedString(@"Last Wednesday", nil);
            case 5: return LocalizedString(@"Last Thursday", nil);
            case 6: return LocalizedString(@"Last Friday", nil);
            default: return LocalizedString(@"Last Saturday", nil);
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
    return today;
}


+ (NSDate*) tomorrow {
    NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
    components.day = 1;

    return [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                         toDate:today
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
    return [DateUtilities isSameDay:today date:date];
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


+ (NSString*) formatShortTimeWorker:(NSDate*) date {
    NSDateComponents* components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                                               fromDate:date];

    if ([self use24HourTime]) {
        return [NSString stringWithFormat:@"%02d:%02d", components.hour, components.minute];
    } else {
        if (components.hour == 0) {
            return [NSString stringWithFormat:@"12:%02dam", components.minute];
        } else if (components.hour == 12) {
            return [NSString stringWithFormat:@"12:%02dpm", components.minute];
        } else if (components.hour > 12) {
            return [NSString stringWithFormat:@"%d:%02dpm", components.hour - 12, components.minute];
        } else {
            return [NSString stringWithFormat:@"%d:%02dam", components.hour, components.minute];
        }
    }
}


+ (NSString*) formatShortTime:(NSDate*) date {
    NSString* result;
    [gate lock];
    {
        result = [self formatShortTimeWorker:date];
    }
    [gate unlock];
    return result;
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


+ (NSString*) formatYear:(NSDate*) date {
    return [self format:date formatter:yearFormatter];
}


+ (NSDate*) dateWithNaturalLanguageString:(NSString*) string {
    //return nil;
    return [(id)[NSDate class] dateWithNaturalLanguageString:string];
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


+ (NSDate*) currentTimeWorker {
    return [calendar dateFromComponents:[calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit
                               fromDate:[NSDate date]]];
}


+ (NSDate*) currentTime {
    NSDate* result;
    [gate lock];
    {
        result = [self currentTimeWorker];
    }
    [gate unlock];
    return result;
}

@end