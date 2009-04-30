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

#import "NetflixRatingsCell.h"

#import "AlertUtilities.h"
#import "ImageCache.h"
#import "Model.h"
#import "MutableNetflixCache.h"
#import "TappableImageView.h"

@interface NetflixRatingsCell()
@property (retain) NSArray* imageViews;
@end

@implementation NetflixRatingsCell

@synthesize imageViews;

- (void) dealloc {
    self.imageViews = nil;

    [super dealloc];
}


- (Model*) model {
    return [Model model];
}


- (NSInteger) halfWayPoint {
    if ([self.model screenRotationEnabled] &&
        UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return 230;
    } else {
        return 150;
    }
}


- (void) setupNetflixRating {
    CGFloat rating = [[self.model.netflixCache netflixRatingForMovie:movie] floatValue];

    NSMutableArray* array = [NSMutableArray array];
    for (NSInteger i = 0; i < 5; i++) {
        UIImage* image;

        CGFloat value = rating - i;
        if (value < 0.2) {
            image = [UIImage imageNamed:@"RedStar-0.0.png"];
        } else if (value < 0.4) {
            image = [UIImage imageNamed:@"RedStar-0.2.png"];
        } else if (value < 0.6) {
            image = [UIImage imageNamed:@"RedStar-0.4.png"];
        } else if (value < 0.8) {
            image = [UIImage imageNamed:@"RedStar-0.6.png"];
        } else if (value < 1) {
            image = [UIImage imageNamed:@"RedStar-0.8.png"];
        } else {
            image = [UIImage imageNamed:@"RedStar-1.0.png"];
        }

        TappableImageView* imageView = [[[TappableImageView alloc] initWithImage:image] autorelease];
        imageView.delegate = self;
        imageView.tag = i + 1;
        imageView.contentMode = UIViewContentModeCenter;

        CGRect rect = imageView.frame;
        rect.origin.y = 5;
        rect.size.width += 10;
        rect.size.height += 10;
        NSInteger halfWayPoint = [self halfWayPoint];

        rect.origin.x = (halfWayPoint - 135) + (40 * (i + 1));
        imageView.frame = rect;

        [self.contentView addSubview:imageView];
        [array addObject:imageView];
    }

    self.imageViews = array;
}


- (void) setupUserRating:(NSString*) userRating {
    CGFloat rating = [userRating floatValue];

    NSMutableArray* array = [NSMutableArray array];
    for (NSInteger i = -1; i < 5; i++) {
        UIImage* image;
        if (i == -1) {
            image = [UIImage imageNamed:@"ClearRating.png"];
        } else {
            CGFloat value = rating - i;
            if (value < 1) {
                image = [ImageCache emptyStarImage];
            } else {
                image = [ImageCache filledStarImage];
            }
        }

        TappableImageView* imageView = [[[TappableImageView alloc] initWithImage:image] autorelease];
        imageView.delegate = self;
        imageView.tag = i + 1;
        imageView.contentMode = UIViewContentModeCenter;

        CGRect rect = imageView.frame;
        rect.origin.y = 5;
        rect.size.width += 10;
        rect.size.height += 10;
        NSInteger halfWayPoint = [self halfWayPoint];

        rect.origin.x = (halfWayPoint - 115) + (40 * (i + 1));
        imageView.frame = rect;

        [self.contentView addSubview:imageView];
        [array addObject:imageView];
    }
    self.imageViews = array;
}


- (void) clearRating {
    for (UIView* view in self.contentView.subviews) {
        [view removeFromSuperview];
    }

    self.imageViews = [NSArray array];
}


- (void) setupRating {
    [self clearRating];

    NSString* userRating = [self.model.netflixCache userRatingForMovie:movie];
    if (userRating.length > 0) {
        [self setupUserRating:userRating];
    } else {
        [self setupNetflixRating];
    }
}


- (id) initWithMovie:(Movie*) movie_ {
    if (self = [super initWithMovie:movie_]) {
        self.imageViews = [NSMutableArray array];
        [self setupRating];
    }

    return self;
}


- (void) imageView:(TappableImageView*) imageView
         wasTapped:(NSInteger) tapCount {
    NSInteger value = imageView.tag;
    NSInteger currentUserRating = (NSInteger)[[self.model.netflixCache userRatingForMovie:movie] floatValue];

    if (value == currentUserRating) {
        return;
    }

    // change the UI:
    [self clearRating];
    if (value == 0) {
        [self setupNetflixRating];
    } else {
        [self setupUserRating:[NSString stringWithFormat:@"%d", value]];
    }

    // now, update in the background.
    NSString* rating = value == 0 ? @"" : [NSString stringWithFormat:@"%d", value];
    [self.model.netflixCache changeRatingTo:rating forMovie:movie delegate:self];
}


- (void) changeSucceeded {

}


- (void) changeFailedWithError:(NSString*) error {
    NSString* message = [NSString stringWithFormat:LocalizedString(@"Could not change rating:\n\n%@", @"%@ is the underlying error.  i.e. 'Could not connect to server'"), error];
    [AlertUtilities showOkAlert:message];

    [self setupRating];
}


- (void) refresh {
    [self setupRating];
}

@end