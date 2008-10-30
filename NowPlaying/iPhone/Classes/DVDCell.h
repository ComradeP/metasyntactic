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

@interface DVDCell : UITableViewCell {
    NowPlayingModel* model;
    UILabel* titleLabel;
    UILabel* directorTitleLabel;
    UILabel* castTitleLabel;
    UILabel* genreTitleLabel;
    UILabel* ratedTitleLabel;
    UILabel* formatTitleLabel;
    
    UILabel* directorLabel;
    UILabel* castLabel;
    UILabel* genreLabel;
    UILabel* ratedLabel;
    UILabel* formatLabel;
    
    UIImageView* imageView;
    
    CGFloat titleWidth;
}

@property (retain) NowPlayingModel* model;
@property (retain) UILabel* titleLabel;
@property (retain) UILabel* directorTitleLabel;
@property (retain) UILabel* castTitleLabel;
@property (retain) UILabel* ratedTitleLabel;
@property (retain) UILabel* genreTitleLabel;
@property (retain) UILabel* formatTitleLabel;

@property (retain) UILabel* directorLabel;
@property (retain) UILabel* castLabel;
@property (retain) UILabel* genreLabel;
@property (retain) UILabel* ratedLabel;
@property (retain) UILabel* formatLabel;

@property (retain) UIImageView* imageView;

- (id)      initWithFrame:(CGRect) frame
          reuseIdentifier:(NSString*) reuseIdentifier
                    model:(NowPlayingModel*) model;

- (void) setMovie:(Movie*) movie owner:(id) owner;

@end