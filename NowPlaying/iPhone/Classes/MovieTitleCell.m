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

#import "MovieTitleCell.h"

#import "Application.h"
#import "ColorCache.h"
#import "FontCache.h"
#import "ImageCache.h"
#import "Model.h"
#import "Movie.h"

@interface MovieTitleCell()
@property (retain) UILabel* scoreLabel;
@end


@implementation MovieTitleCell

@synthesize scoreLabel;

- (void) dealloc {
    self.scoreLabel = nil;

    [super dealloc];
}


- (id) initWithReuseIdentifier:(NSString*) reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle
                    reuseIdentifier:reuseIdentifier]) {
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumFontSize = 12;

        self.scoreLabel = [[[UILabel alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.textAlignment = UITextAlignmentCenter;

        [self.contentView addSubview:scoreLabel];
        [self.contentView bringSubviewToFront:scoreLabel];
    }

    return self;
}


- (Model*) model {
    return [Model model];
}


- (void) setImage:(UIImage*) image {
    if (self.image != image) {
        [super setImage:image];
    }
}


- (void) setRottenTomatoesScore:(Movie*) movie {
    int score = [self.model scoreValueForMovie:movie];

    if (score >= 0 && score <= 100) {
        if (score >= 60) {
            if (self.image != [ImageCache freshImage]) {
                self.image = [ImageCache freshImage];

                scoreLabel.font = [UIFont boldSystemFontOfSize:15];
                scoreLabel.textColor = [UIColor whiteColor];

                CGRect frame = CGRectMake(5, 7, 32, 32);

                scoreLabel.frame = frame;
            }
        } else {
            if (self.image != [ImageCache rottenFadedImage]) {
                self.image = [ImageCache rottenFadedImage];

                scoreLabel.font = [UIFont boldSystemFontOfSize:17];
                scoreLabel.textColor = [UIColor blackColor];

                CGRect frame = CGRectMake(5, 5, 30, 32);

                scoreLabel.frame = frame;
            }
        }

        scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    } else {
        if (self.image != [ImageCache unknownRatingImage]) {
            scoreLabel.text = nil;
            self.image = [ImageCache unknownRatingImage];
        }
    }
}


- (void) setBasicSquareScore:(Movie*) movie {
    int score = [self.model scoreValueForMovie:movie];

    if (score >= 0 && score <= 100) {
        CGRect frame = CGRectMake(6, 6, 30, 30);
        if (score == 100) {
            scoreLabel.font = [UIFont boldSystemFontOfSize:15];
        } else {
            scoreLabel.font = [FontCache boldSystem19];
        }

        scoreLabel.textColor = [ColorCache darkDarkGray];
        scoreLabel.frame = frame;
        scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    }

    if (score >= 0 && score <= 40) {
        self.image = [ImageCache redRatingImage];
    } else if (score > 40 && score <= 60) {
        self.image = [ImageCache yellowRatingImage];
    } else if (score > 60 && score <= 100) {
        self.image = [ImageCache greenRatingImage];
    } else {
        scoreLabel.text = nil;
        self.image = [ImageCache unknownRatingImage];
    }
}


- (BOOL) noScores {
    return self.model.noScores;
}


- (void) layoutSubviews {
    [super layoutSubviews];
    [self.contentView bringSubviewToFront:scoreLabel];
}


- (void) setScore:(Movie*) movie {
    if (self.model.rottenTomatoesScores) {
        [self setRottenTomatoesScore:movie];
    } else if (self.model.metacriticScores) {
        [self setBasicSquareScore:movie];
    } else if (self.model.googleScores) {
        [self setBasicSquareScore:movie];
    } else if (self.model.noScores) {
        self.image = nil;
        scoreLabel.text = nil;
    }
}


- (void) setMovie:(Movie*) movie owner:(id) owner {
    [self setScore:movie];
    self.detailTextLabel.text = movie.ratingAndRuntimeString;

    if ([self.model isBookmarked:movie]) {
        self.textLabel.text = [NSString stringWithFormat:@"%@ %@", [Application starString], movie.displayTitle];
    } else {
        self.textLabel.text = movie.displayTitle;
    }
}

@end