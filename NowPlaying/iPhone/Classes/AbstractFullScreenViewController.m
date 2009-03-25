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

#import "AbstractFullScreenViewController.h"

#import "AbstractNavigationController.h"
#import "AppDelegate.h"
#import "Controller.h"
#import "Model.h"
#import "NotificationCenter.h"

@interface AbstractFullScreenViewController()
@property (assign) AbstractNavigationController* abstractNavigationController;
@end


@implementation AbstractFullScreenViewController

@synthesize abstractNavigationController;

- (void) dealloc {
    self.abstractNavigationController = nil;
    [super dealloc];
}


- (id) initWithNavigationController:(AbstractNavigationController*) navigationController_ {
    if (self = [super init]) {
        self.abstractNavigationController = navigationController_;
    }

    return self;
}


- (Controller*) controller {
    return [Controller controller];
}


- (Model*) model {
    return [Model model];
}


- (BOOL) hidesBottomBarWhenPushed {
    return YES;
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [[AppDelegate notificationCenter] disableNotifications];
}


- (void) viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
    [[AppDelegate notificationCenter] enableNotifications];
}

@end