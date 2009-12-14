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

#import "DVDFilterViewController.h"

#import "Controller.h"
#import "Model.h"

@interface DVDFilterViewController()
@end


@implementation DVDFilterViewController

- (id) init {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = LocalizedString(@"Settings", nil);
  }
  
  return self;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
  return 1;
}


- (NSInteger) tableView:(UITableView*) tableView
  numberOfRowsInSection:(NSInteger) section {
  return 2;
}


- (void) setCheckmarkForCell:(UITableViewCell*) cell
                       atRow:(NSInteger) row {
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  if (row == 0) {
    if ([Model model].dvdMoviesShowDVDs) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
  } else if (row == 1) {
    if ([Model model].dvdMoviesShowBluray) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
  }
}


- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
  static NSString* reuseIdentifier = @"reuseIdentifier";
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  if (indexPath.row == 0) {
    cell.textLabel.text = LocalizedString(@"DVD", nil);
  } else if (indexPath.row == 1) {
    cell.textLabel.text = LocalizedString(@"Blu-ray", nil);
  }
  
  [self setCheckmarkForCell:cell atRow:indexPath.row];
  
  return cell;
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) selectPath {
  [self.tableView deselectRowAtIndexPath:selectPath animated:YES];
  
  if (selectPath.row == 0) {
    [[Controller controller] setDvdMoviesShowDVDs:![Model model].dvdMoviesShowDVDs];
  } else {
    [[Controller controller] setDvdMoviesShowBluray:![Model model].dvdMoviesShowBluray];
  }
  
  for (NSInteger i = 0; i <= 1; i++) {
    NSIndexPath* cellPath = [NSIndexPath indexPathForRow:i inSection:0];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:cellPath];
    
    [self setCheckmarkForCell:cell atRow:i];
  }
}

@end
