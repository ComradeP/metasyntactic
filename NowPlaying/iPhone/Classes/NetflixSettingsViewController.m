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

#import "NetflixSettingsViewController.h"

#import "AbstractNavigationController.h"
#import "Controller.h"
#import "Model.h"

@interface NetflixSettingsViewController()
@end


@implementation NetflixSettingsViewController

- (void) dealloc {
    [super dealloc];
}


- (id) init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }

    return self;
}


- (Model*) model {
    return [Model model];
}


- (Controller*) controller {
    return [Controller controller];
}


- (void) majorRefreshWorker {
    [self reloadTableViewData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 0;
        return self.model.netflixPreferredFormats.count;
    }

    return 0;
}


- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.section == 0) {
        cell.text = NSLocalizedString(@"Instant Watch", nil);
        UISwitch* switch_ = [[[UISwitch alloc] init] autorelease];
        switch_.enabled = NO;
        switch_.on = self.model.netflixCanInstantWatch;
        cell.accessoryView = switch_;
    } else {
        cell.text = [self.model.netflixPreferredFormats objectAtIndex:indexPath.row];
    }

    return cell;
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
    if (section == 1) {
        return NSLocalizedString(@"Preferred Formats", @"The preferred movie format that the user has.  i.e. DVD or Bluray");
    }

    return nil;
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForFooterInSection:(NSInteger) section {
    if (section == 1) {
        return NSLocalizedString(@"Currently, settings can only be modified from Netflix's website", nil);
    }

    return nil;
}

@end