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

#import "ExpandedMovieDetailsCell.h"

#import "BoxOfficeStockImages.h"
#import "Model.h"

@interface ExpandedMovieDetailsCell()
@property (retain) NSMutableArray* titles;
@property (retain) NSMutableDictionary* titleToLabel;
@property (retain) MultiDictionary* titleToValueLabels;
@end


@implementation ExpandedMovieDetailsCell

@synthesize titles;
@synthesize titleToLabel;
@synthesize titleToValueLabels;

- (void) dealloc {
  self.titles = nil;
  self.titleToLabel = nil;
  self.titleToValueLabels = nil;

  [super dealloc];
}


- (Model*) model {
  return [Model model];
}


- (UILabel*) createTitleLabel:(NSString*) title {
  UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];

  label.font = [UIFont systemFontOfSize:14];
  label.textColor = [UIColor darkGrayColor];
  label.backgroundColor = [UIColor clearColor];
  label.text = title;
  label.textAlignment = UITextAlignmentRight;
  [label sizeToFit];

  return label;
}


- (UILabel*) createValueLabel {
  UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  label.font = [UIFont systemFontOfSize:14];
  label.backgroundColor = [UIColor clearColor];
  return label;
}


- (void) addDisclosureTriangle {
  UIImageView* imageView = [[[UIImageView alloc] initWithImage:[MetasyntacticStockImages collapseArrow]] autorelease];
  CGRect frame = imageView.frame;
  frame.origin.x = 10;
  frame.origin.y = 10;
  imageView.frame = frame;

  [self.contentView addSubview:imageView];
}


- (void) addTitle:(NSString*) title
        andValues:(NSArray*) values
               to:(MutableMultiDictionary*) dictionary {
  UILabel* titleLabel = [self createTitleLabel:title];
  [titleLabel sizeToFit];
  [self.contentView addSubview:titleLabel];

  for (NSString* value in values) {
    UILabel* valueLabel = [self createValueLabel];
    valueLabel.text = value;

    [dictionary addObject:valueLabel forKey:title];

    [valueLabel sizeToFit];
    [self.contentView addSubview:valueLabel];
  }

  [titles addObject:title];
  [titleToLabel setObject:titleLabel forKey:title];
}


- (void) addTitle:(NSString*) title
         andValue:(NSString*) value
               to:(MutableMultiDictionary*) dictionary {
  [self addTitle:title
       andValues:[NSArray arrayWithObject:value]
              to:dictionary];
}


- (void) addRating:(MutableMultiDictionary*) dictionary {
  NSString* title = LocalizedString(@"Rated:", nil);
  NSString* value = [self.model ratingForMovie:movie];
  if (value.length == 0) {
    value = LocalizedString(@"Unrated", nil);
  }

  [self addTitle:title andValue:value to:dictionary];
}


- (void) addRunningTime:(MutableMultiDictionary*) dictionary {
  NSInteger length = [self.model lengthForMovie:movie];
  if (length <= 0) {
    return;
  }

  NSString* title = LocalizedString(@"Running time:", nil);
  NSString* value = [Movie runtimeString:length];

  [self addTitle:title andValue:value to:dictionary];
}


- (void) addReleaseDate:(MutableMultiDictionary*) dictionary {
  if (movie.releaseDate == nil) {
    return;
  }

  NSString* title = LocalizedString(@"Release date:", nil);

  NSString* value;
  if (movie.isNetflix) {
    value = [DateUtilities formatYear:movie.releaseDate];
  } else {
    value = [DateUtilities formatMediumDate:movie.releaseDate];
  }

  [self addTitle:title andValue:value to:dictionary];
}


- (void) addGenres:(MutableMultiDictionary*) dictionary {
  NSArray* genres = [self.model genresForMovie:movie];
  if (genres.count == 0) {
    return;
  }

  NSString* title = LocalizedString(@"Genre:", nil);
  NSString* value = [genres componentsJoinedByString:@", "];
  if (value.length == 0) {
    return;
  }

  [self addTitle:title andValue:value to:dictionary];
}


- (void) addStudio:(MutableMultiDictionary*) dictionary {
  if (movie.studio.length == 0) {
    return;
  }

  NSString* title = LocalizedString(@"Studio:", nil);
  NSString* value = movie.studio;

  [self addTitle:title andValue:value to:dictionary];
}


- (void) addDirectors:(MutableMultiDictionary*) dictionary {
  NSArray* directors = [self.model directorsForMovie:movie];
  if (directors.count == 0) {
    return;
  }

  NSString* title;
  if (directors.count == 1) {
    title = LocalizedString(@"Director:", nil);
  } else {
    title = LocalizedString(@"Directors:", nil);
  }

  [self addTitle:title andValues:directors to:dictionary];
}


- (void) addCast:(MutableMultiDictionary*) dictionary {
  NSArray* cast = [self.model castForMovie:movie];
  if (cast.count == 0) {
    return;
  }

  NSString* title = LocalizedString(@"Cast:", nil);
  [self addTitle:title andValues:cast to:dictionary];
}


- (void) setLabelWidths {
  CGFloat titleWidth = 0;
  for (UILabel* label in titleToLabel.allValues) {
    titleWidth = MAX(titleWidth, [label.text sizeWithFont:label.font].width);
  }
  UILabel* firstLabel = [titleToLabel objectForKey:[titles objectAtIndex:0]];
  CGFloat firstTitleWidth = [firstLabel.text sizeWithFont:firstLabel.font].width;

  titleWidth = MAX(titleWidth + 20, firstTitleWidth + 40);

  for (UILabel* label in titleToLabel.allValues) {
    CGRect frame = label.frame;
    frame.size.width = titleWidth;
    label.frame = frame;
  }
  for (NSArray* labels in titleToValueLabels.allValues) {
    for (UILabel* label in labels) {
      CGRect frame = label.frame;
      frame.origin.x = titleWidth + 7;
      label.frame = frame;
    }
  }
}


- (void) setLabelPositions {
  NSInteger yPosition = 5;
  for (NSString* title in titles) {
    UILabel* titleLabel = [titleToLabel objectForKey:title];
    CGRect titleFrame = titleLabel.frame;

    titleFrame.origin.y = yPosition;
    titleLabel.frame = titleFrame;

    for (UILabel* valueLabel in [titleToValueLabels objectsForKey:title]) {
      CGRect valueFrame = valueLabel.frame;
      valueFrame.origin.y = yPosition;

      yPosition += valueLabel.font.pointSize + 10;
      valueLabel.frame = valueFrame;
    }
  }
}


- (id) initWithMovie:(Movie*) movie_ {
  if ((self = [super initWithMovie:movie_])) {
    self.titles = [NSMutableArray array];
    self.titleToLabel = [NSMutableDictionary dictionary];

    MutableMultiDictionary* dictionary = [MutableMultiDictionary dictionary];

    [self addRating:dictionary];
    [self addRunningTime:dictionary];
    [self addReleaseDate:dictionary];
    [self addGenres:dictionary];
    [self addStudio:dictionary];
    [self addDirectors:dictionary];
    [self addCast:dictionary];

    self.titleToValueLabels = dictionary;

    [self setLabelPositions];
    [self setLabelWidths];

    [self addDisclosureTriangle];
  }

  return self;
}


- (void) layoutSubviews {
  [super layoutSubviews];

  for (NSArray* labels in titleToValueLabels.allValues) {
    for (UILabel* label in labels) {
      CGRect frame = label.frame;
      frame.size.width = MIN(frame.size.width, self.contentView.frame.size.width - frame.origin.x);
      label.frame = frame;
    }
  }
}


- (CGFloat) height:(UITableView*) tableView {
  NSString* lastTitle = titles.lastObject;
  NSArray* labels = [titleToValueLabels objectsForKey:lastTitle];
  UILabel* lastLabel = labels.lastObject;

  NSInteger y = lastLabel.frame.origin.y;
  NSInteger height = lastLabel.frame.size.height;
  return y + height + 7;
}

@end
