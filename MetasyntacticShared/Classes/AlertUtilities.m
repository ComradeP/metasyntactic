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

#import "AlertUtilities.h"

#import "MetasyntacticSharedApplication.h"

@implementation AlertUtilities

+ (void) showOkAlert:(NSString*) message {
    [self showOkAlert:message withTitle:nil];
}


+ (void) showOkAlert:(NSString*) message
           withTitle:(NSString*) title {
    NSAssert([NSThread isMainThread], nil);
    if (message.length == 0) {
        message = @"";
    }

    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:LocalizedString(@"OK", nil), nil] autorelease];

    [alert show];
}

@end