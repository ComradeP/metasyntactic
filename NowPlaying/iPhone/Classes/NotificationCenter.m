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

#import "NotificationCenter.h"

#import "GlobalActivityIndicator.h"
#import "Pulser.h"

@interface NotificationCenter()
@property (retain) UIView* view;
@property (retain) UILabel* notificationLabel;
@property (retain) UILabel* blackLabel;
@property (retain) NSMutableArray* notifications;
@property (retain) Pulser* pulser;
@property NSInteger disabledCount;
@end

@implementation NotificationCenter

@synthesize view;
@synthesize notificationLabel;
@synthesize blackLabel;
@synthesize notifications;
@synthesize pulser;
@synthesize disabledCount;

- (void) dealloc {
    self.view = nil;
    self.notificationLabel = nil;
    self.blackLabel = nil;
    self.notifications = nil;
    self.pulser = nil;
    self.disabledCount = 0;

    [super dealloc];
}


- (void) addToView {
    [view addSubview:notificationLabel];
    [view addSubview:blackLabel];
}


- (id) initWithView:(UIView*) view__ {
    if (self = [super init]) {
        self.view = view__;

        self.notifications = [NSMutableArray array];

        self.notificationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 417, 320, 16)] autorelease];
        notificationLabel.font = [UIFont boldSystemFontOfSize:12];
        notificationLabel.textAlignment = UITextAlignmentCenter;
        notificationLabel.textColor = [UIColor whiteColor];
        notificationLabel.shadowColor = [UIColor darkGrayColor];
        notificationLabel.shadowOffset = CGSizeMake(0, 1);
        notificationLabel.alpha = 0;
        notificationLabel.backgroundColor = [UIColor colorWithRed:46.0/256.0 green:46.0/256.0 blue:46.0/256.0 alpha:1];
        notificationLabel.text = NSLocalizedString(@"Updating", nil);

        self.blackLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 417, 320, 1)] autorelease];
        blackLabel.backgroundColor = [UIColor blackColor];
        blackLabel.alpha = 0;

        self.pulser = [Pulser pulserWithTarget:self
                                        action:@selector(update)
                                 pulseInterval:1];
/*
        [GlobalActivityIndicator setTarget:self
                    startIndicatorSelector:@selector(showNotification)
                     stopIndicatorSelector:@selector(hideNotification)];
 */

        [self addToView];
    }

    return self;
}


+ (NotificationCenter*) centerWithView:(UIView*) view {
    return [[[NotificationCenter alloc] initWithView:view] autorelease];
}


- (void) showNotification {
    if (disabledCount == 0 && [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        [self.view bringSubviewToFront:notificationLabel];
        [self.view bringSubviewToFront:blackLabel];

        [UIView beginAnimations:nil context:NULL];
        {
            notificationLabel.alpha = blackLabel.alpha = 1;
        }
        [UIView commitAnimations];
    }
}


- (void) hideNotification {
    [UIView beginAnimations:nil context:NULL];
    {
        notificationLabel.alpha = blackLabel.alpha = 0;
    }
    [UIView commitAnimations];
}


- (NSString*) computeText {
    NSMutableArray* array = [NSMutableArray array];
    for (NSString* notification in notifications) {
        if (![array containsObject:notification]) {
            [array addObject:notification];
        }
    }

    if (array.count == 0) {
        return nil;
    }

    return [NSString stringWithFormat:NSLocalizedString(@"Updating: %@", nil), [array componentsJoinedByString:@", "]];
}


- (void) update {
    notificationLabel.text = [self computeText];
    if (notifications.count > 0) {
        [self showNotification];
    } else {
        [self hideNotification];
    }
}


- (void) willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation {
    notificationLabel.alpha = blackLabel.alpha = 0;
}


- (void) didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [pulser tryPulse];
}

- (void) addNotification:(NSString*) notification {
    [self addNotifications:[NSArray arrayWithObject:notification]];
}


- (void) removeNotification:(NSString*) notification {
    [self removeNotifications:[NSArray arrayWithObject:notification]];
}


- (void) addNotifications:(NSArray*) array {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(addNotifications:) withObject:array waitUntilDone:NO];
        return;
    }

    [notifications addObjectsFromArray:array];
    [pulser tryPulse];
}


- (void) removeNotifications:(NSArray*) array {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(removeNotifications:) withObject:array waitUntilDone:NO];
        return;
    }

    [notifications removeObjectsInArray:array];
    [pulser tryPulse];
}


- (void) disableNotifications {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(disableNotifications) withObject:nil waitUntilDone:NO];
        return;
    }

    disabledCount++;
    [self hideNotification];
    [pulser tryPulse];
}


- (void) enableNotifications {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(enableNotifications) withObject:nil waitUntilDone:NO];
        return;
    }

    disabledCount--;
    [pulser tryPulse];
}

@end