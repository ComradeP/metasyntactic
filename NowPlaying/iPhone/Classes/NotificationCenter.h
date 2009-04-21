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

@interface NotificationCenter : NSObject {
@private
    UIViewController* viewController;
    UILabel* notificationLabel;
    UILabel* blackLabel;

    NSMutableArray* notifications;
    Pulser* pulser;

    NSInteger disabledCount;
}

+ (NotificationCenter*) notificationCenter;

+ (void) attachToViewController:(UIViewController*) viewController;

+ (void) disableNotifications;
+ (void) enableNotifications;

+ (void) addNotification:(NSString*) notification;
+ (void) addNotifications:(NSArray*) notifications;
+ (void) removeNotification:(NSString*) notification;
+ (void) removeNotifications:(NSArray*) notifications;

+ (void) willChangeInterfaceOrientation;
+ (void) didChangeInterfaceOrientation;

@end