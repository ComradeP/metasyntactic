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

#import "WarningView.h"

#import "BoxOfficeStockImages.h"

@interface WarningView()
@property (retain) UIImageView* imageView;
@property (retain) UILabel* label;
@end


@implementation WarningView

const NSInteger LABEL_X = 52;
const NSInteger TOP_BUFFER = 5;

@synthesize imageView;
@synthesize label;

- (void) dealloc {
  self.imageView = nil;
  self.label = nil;

  [super dealloc];
}


- (id) initWithText:(NSString*) text {
  if ((self = [super initWithFrame:CGRectZero])) {
    self.autoresizesSubviews = YES;
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];

    self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.text = text;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.font = [FontCache footerFont];
    label.textColor = [ColorCache footerColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = UITextAlignmentCenter;

    self.imageView = [[[UIImageView alloc] initWithImage:[BoxOfficeStockImages warning32x32]] autorelease];

    [self addSubview:imageView];
    [self addSubview:label];
  }

  return self;
}


+ (WarningView*) viewWithText:(NSString*) text {
  return [[[WarningView alloc] initWithText:text] autorelease];
}


- (void) layoutSubviews {
  {
    NSString* text = label.text;
    CGRect frame = label.frame;
    frame.origin.x = LABEL_X;
    frame.origin.y = TOP_BUFFER;
    frame.size.width = self.frame.size.width - 10 - frame.origin.x;
    frame.size.height = [text sizeWithFont:[FontCache footerFont]
                         constrainedToSize:CGSizeMake(frame.size.width, 2000)
                             lineBreakMode:UILineBreakModeWordWrap].height;
    label.frame = frame;
  }

  {
    CGRect frame = imageView.frame;

    frame.origin.x = 10 + [AbstractTableViewCell groupedTableViewMargin];
    frame.origin.y = MAX(label.frame.origin.y, label.frame.origin.y + (NSInteger)((label.frame.size.height - [BoxOfficeStockImages warning32x32].size.height) / 2.0));
    imageView.frame = frame;
  }
}

- (CGFloat) height:(UITableViewController*) tableViewController {
  CGFloat imageHeight = [BoxOfficeStockImages warning32x32].size.height;

  CGFloat width;
  if (UIInterfaceOrientationIsLandscape(tableViewController.interfaceOrientation)) {
    width = [UIScreen mainScreen].bounds.size.height;
  } else {
    width = [UIScreen mainScreen].bounds.size.width;
  }

  NSInteger labelX = LABEL_X;
  NSInteger labelWidth = width - 10 - labelX;
  NSString* text = label.text;
  CGFloat labelHeight = [text sizeWithFont:[FontCache footerFont]
                        constrainedToSize:CGSizeMake(labelWidth, 2000)
                            lineBreakMode:UILineBreakModeWordWrap].height;

  return TOP_BUFFER + MAX(imageHeight, labelHeight);
}

@end
