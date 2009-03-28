// Copyright (C) 2008 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "ReviewTitleCell.h"

#import "ColorCache.h"
#import "FontCache.h"
#import "ImageCache.h"
#import "NowPlayingModel.h"
#import "Review.h"

@implementation ReviewTitleCell

@synthesize model;
@synthesize authorLabel;
@synthesize scoreLabel;
@synthesize sourceLabel;

- (void) dealloc {
    self.model = nil;
    self.authorLabel = nil;
    self.scoreLabel = nil;
    self.sourceLabel = nil;

    [super dealloc];
}


- (id) initWithModel:(NowPlayingModel*) model_
               frame:(CGRect) frame
     reuseIdentifier:(NSString*) reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        self.model = model_;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.authorLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
        self.sourceLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
        self.scoreLabel  = [[[UILabel alloc] initWithFrame:frame] autorelease];

        authorLabel.font = [UIFont boldSystemFontOfSize:14];
        sourceLabel.font = [UIFont systemFontOfSize:12];

        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.textAlignment = UITextAlignmentCenter;

        [self.contentView addSubview:authorLabel];
        [self.contentView addSubview:sourceLabel];
        [self addSubview:scoreLabel];
    }
    return self;
}


- (void) setImage:(UIImage*) image {
    if (self.image != image) {
        [super setImage:image];
    }
}


- (void) setRottenTomatoesImage:(NSInteger) score {
    scoreLabel.text = nil;
    scoreLabel.frame = CGRectZero;

    if (score >= 60) {
        self.image = [ImageCache freshImage];
    } else {
        self.image = [ImageCache rottenFullImage];
    }
}


- (void) setBasicSquareImage:(NSInteger) score {
    if (score >= 0 && score <= 40) {
        self.image = [ImageCache redRatingImage];
    } else if (score > 40 && score <= 60) {
        self.image = [ImageCache yellowRatingImage];
    } else if (score > 60 && score <= 100) {
        self.image = [ImageCache greenRatingImage];
    } else {
        scoreLabel.text = nil;
        scoreLabel.frame = CGRectZero;
        self.image = [ImageCache unknownRatingImage];
    }

    if (score >= 0 && score <= 100) {
        CGRect frame = CGRectMake(20, 7, 30, 30);
        if (score == 100) {
            scoreLabel.font = [UIFont boldSystemFontOfSize:15];
        } else {
            scoreLabel.font = [FontCache boldSystem19];
        }

        scoreLabel.textColor = [ColorCache darkDarkGray];
        scoreLabel.frame = frame;
        scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    }
}


- (void) setReviewImage:(Review*) review {
    int score = review.score;

    if (model.rottenTomatoesRatings) {
        [self setRottenTomatoesImage:score];
    } else if (model.metacriticRatings) {
        [self setBasicSquareImage:score];
    } else if (model.googleRatings) {
        [self setBasicSquareImage:score];
    }
}


- (void) setReview:(Review*) review {
    [self setReviewImage:review];

    authorLabel.text = review.author;
    sourceLabel.text = review.source;

    [authorLabel sizeToFit];
    [sourceLabel sizeToFit];

    CGRect frame;

    frame = authorLabel.frame;
    frame.origin.y = 5;
    frame.origin.x = 50;
    authorLabel.frame = frame;

    frame = sourceLabel.frame;
    frame.origin.y = 23;
    frame.origin.x = 50;
    sourceLabel.frame = frame;
}


@end