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

#import "ReviewBodyCell.h"

#import "FontCache.h"
#import "Review.h"
#import "Utilities.h"

@interface ReviewBodyCell()
@property (retain) Review* review_;
@property (retain) UILabel* label_;
@end


@implementation ReviewBodyCell

@synthesize review_;
@synthesize label_;

property_wrapper(Review*, review, Review);
property_wrapper(UILabel*, label, Label);

- (void) dealloc {
    self.review = nil;
    self.label = nil;

    [super dealloc];
}


- (id) initWithReuseIdentifier:(NSString*) reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label.font = [FontCache helvetica14];
        self.label.lineBreakMode = UILineBreakModeWordWrap;
        self.label.numberOfLines = 0;

        [self.contentView addSubview:self.label];
    }

    return self;
}


- (void) layoutSubviews {
    [super layoutSubviews];

    self.label.text = self.review.text;

    double width = self.frame.size.width;
    width -= 40;
    if (self.review.link.length != 0) {
        width -= 25;
    }

    CGRect rect = CGRectMake(10, 5, width, [ReviewBodyCell height:self.review] - 10);
    self.label.frame = rect;
}


+ (CGFloat) height:(Review*) review {
    double width;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        width = [UIScreen mainScreen].bounds.size.height;
    } else {
        width = [UIScreen mainScreen].bounds.size.width;
    }
    width -= 40;
    if (review.link.length != 0) {
        width -= 25;
    }

    CGSize size = CGSizeMake(width, 2000);
    size = [review.text sizeWithFont:[FontCache helvetica14]
            constrainedToSize:size
            lineBreakMode:UILineBreakModeWordWrap];

    return size.height + 10;
}

@end