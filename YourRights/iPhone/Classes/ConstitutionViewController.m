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

#import "ConstitutionViewController.h"

#import "Amendment.h"
#import "Article.h"
#import "AutoResizingCell.h"
#import "Constitution.h"
#import "ConstitutionAmendmentViewController.h"
#import "ConstitutionArticleViewController.h"
#import "ConstitutionSignersViewController.h"
#import "WrappableCell.h"

@interface ConstitutionViewController()
@property (retain) Constitution* constitution;
@end

@implementation ConstitutionViewController

@synthesize constitution;

- (void)dealloc {
    self.constitution = nil;
    [super dealloc];
}


- (id) initWithConstitution:(Constitution*) constitution_
                      title:(NSString*) title_ {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.constitution = constitution_;
        self.title = title_;
        self.navigationItem.titleView = [ViewControllerUtilities viewControllerTitleLabel:self.title];
    }

    return self;
}


- (void) minorRefreshWorker {
}


- (void) majorRefreshWorker {
    [self reloadTableViewData];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    [self majorRefresh];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return constitution.articles.count;
    } else if (section == 2) {
        return constitution.amendments.count;
    } else if (section == 3) {
        if (constitution.conclusion.length > 0) {
            return 1;
        } else {
            return 0;
        }
    } else if (section == 4) {
        return 1;
    }

    return 0;
}


- (UITableViewCell*) cellForPreambleRow:(NSInteger) row {
    WrappableCell *cell = [[[WrappableCell alloc] initWithTitle:constitution.preamble] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}


- (UITableViewCell*) cellForArticlesRow:(NSInteger) row {
    static NSString *reuseIdentifier = @"reuseIdentifier";

    AutoResizingCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[AutoResizingCell alloc] initWithReuseIdentifier:reuseIdentifier] autorelease];
    }

    Article* article = [constitution.articles objectAtIndex:row];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d. %@", nil), row + 1, article.title];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


- (UITableViewCell*) cellForAmendmentsRow:(NSInteger) row {
    static NSString *reuseIdentifier = @"reuseIdentifier";

    AutoResizingCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[AutoResizingCell alloc] initWithReuseIdentifier:reuseIdentifier] autorelease];
    }

    Amendment* amendment = [constitution.amendments objectAtIndex:row];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d. %@", nil), row + 1, amendment.synopsis];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


- (UITableViewCell*) cellForConclusionRow:(NSInteger) row {
    WrappableCell *cell = [[[WrappableCell alloc] initWithTitle:constitution.conclusion] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}


- (UITableViewCell*) cellForInformationRow:(NSInteger) row {
    static NSString *reuseIdentifier = @"reuseIdentifier";

    AutoResizingCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[AutoResizingCell alloc] initWithReuseIdentifier:reuseIdentifier] autorelease];
    }

    cell.textLabel.text = NSLocalizedString(@"Signers", nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self cellForPreambleRow:indexPath.row];
    } else if (indexPath.section == 1) {
        return [self cellForArticlesRow:indexPath.row];
    } else if (indexPath.section == 2) {
        return [self cellForAmendmentsRow:indexPath.row];
    } else if (indexPath.section == 3) {
        return [self cellForConclusionRow:indexPath.row];
    } else {
        return [self cellForInformationRow:indexPath.row];
    }
}


- (void) didSelectPreambleRow:(NSInteger) row {

}


- (void) didSelectArticlesRow:(NSInteger) row {
    Article* article = [constitution.articles objectAtIndex:row];
    ConstitutionArticleViewController* controller = [[[ConstitutionArticleViewController alloc] initWithArticle:article] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectAmendmentsRow:(NSInteger) row {
    Amendment* amendment = [constitution.amendments objectAtIndex:row];
    ConstitutionAmendmentViewController* controller = [[[ConstitutionAmendmentViewController alloc] initWithAmendment:amendment] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectConclusionRow:(NSInteger) row {

}


- (void) didSelectInformationRow:(NSInteger) row {
    ConstitutionSignersViewController* controller = [[[ConstitutionSignersViewController alloc] initWithSigners:constitution.signers] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self didSelectPreambleRow:indexPath.row];
    } else if (indexPath.section == 1) {
        [self didSelectArticlesRow:indexPath.row];
    } else if (indexPath.section == 2) {
        [self didSelectAmendmentsRow:indexPath.row];
    } else if (indexPath.section == 3) {
        [self didSelectConclusionRow:indexPath.row];
    } else {
        [self didSelectInformationRow:indexPath.row];
    }
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
    if (section == 0) {
        return NSLocalizedString(@"Preamble", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Articles", nil);
    } else if (section == 2) {
        if (constitution.amendments.count > 0) {
            return NSLocalizedString(@"Amendments", nil);
        }
    } else if (section == 3) {
        if (constitution.conclusion.length > 0) {
            return NSLocalizedString(@"Conclusions", nil);
        }
    } else {
        return NSLocalizedString(@"Information", nil);
    }

    return nil;
}


- (CGFloat)         tableView:(UITableView*) tableView
      heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        return [WrappableCell height:constitution.preamble accessoryType:UITableViewCellAccessoryNone];
    } else if (indexPath.section == 3) {
        return [WrappableCell height:constitution.conclusion accessoryType:UITableViewCellAccessoryNone];
    } else {
        return tableView.rowHeight;
    }
}

@end