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

#import "FederalistPapersArticleViewController.h"

#import "Article.h"
#import "FederalistPapersSectionViewController.h"
#import "Section.h"
#import "WrappableCell.h"
#import "YourRightsNavigationController.h"

@interface FederalistPapersArticleViewController()
@property (retain) Article* article;
@end


@implementation FederalistPapersArticleViewController

@synthesize article;

- (void) dealloc {
    self.article = nil;

    [super dealloc];
}


- (id) initWithArticle:(Article*) article_ {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.article = article_;
        self.title = article.title;
    }

    return self;
}


- (void) loadView {
    [super loadView];
    self.navigationItem.titleView = [ViewControllerUtilities viewControllerTitleLabel:self.title];
}


- (void) minorRefreshWorker {
}


- (void) majorRefreshWorker {
    [self reloadTableViewData];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    [self majorRefresh];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return article.sections.count;
}


- (UITableViewCell*) cellForSectionRow:(NSInteger) row {
    Section* section = [article.sections objectAtIndex:row];
    WrappableCell *cell = [[[WrappableCell alloc] initWithTitle:section.title] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellForSectionRow:indexPath.row];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Section* section = [article.sections objectAtIndex:indexPath.row];
    FederalistPapersSectionViewController* controller = [[[FederalistPapersSectionViewController alloc] initWithSection:section] autorelease];
    [self.navigationController pushViewController:controller
                                         animated:YES];
}


- (CGFloat)         tableView:(UITableView*) tableView
      heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    Section* section = [article.sections objectAtIndex:indexPath.row];

    return [WrappableCell height:section.title
                   accessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

@end