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

#import "ConstitutionSignersViewController.h"

#import "Article.h"
#import "MultiDictionary.h"
#import "Section.h"
#import "ViewControllerUtilities.h"
#import "WrappableCell.h"

@interface ConstitutionSignersViewController()
@property (assign) YourRightsNavigationController* navigationController;
@property (retain) MultiDictionary* signers;
@property (retain) NSArray* keys;
@end


@implementation ConstitutionSignersViewController

@synthesize navigationController;
@synthesize signers;
@synthesize keys;

- (void) dealloc {
    self.navigationController = nil;
    self.signers = nil;
    self.keys = nil;
    
    [super dealloc];
}


- (id) initWithNavigationController:(YourRightsNavigationController*) navigationController_
                            signers:(MultiDictionary*) signers_ {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.navigationController = navigationController_;
        self.signers = signers_;
        self.title = NSLocalizedString(@"Signers", nil);
        
        self.keys = [signers.allKeys sortedArrayUsingSelector:@selector(compare:)];
    }
    
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return keys.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[signers objectsForKey:[keys objectAtIndex:section]] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* signer = [[signers objectsForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    WrappableCell *cell = [[[WrappableCell alloc] initWithTitle:signer] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
    return [keys objectAtIndex:section];
}


- (CGFloat)         tableView:(UITableView*) tableView
      heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    NSString* signer = [[signers objectsForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    return [WrappableCell height:signer accessoryType:UITableViewCellAccessoryNone];
}

@end