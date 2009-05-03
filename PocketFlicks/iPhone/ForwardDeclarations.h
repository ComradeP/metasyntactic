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

@protocol DataProvider;
@protocol DataProviderUpdateDelegate;
@protocol InfoViewControllerDelegate;
@protocol NetflixChangeRatingDelegate;
@protocol NetflixAddMovieDelegate;
@protocol NetflixMoveMovieDelegate;
@protocol NetflixModifyQueueDelegate;
@protocol ScoreProvider;
@protocol SearchEngineDelegate;
@protocol TappableImageViewDelegate;
@protocol TappableLabelDelegate;
@protocol TappableScrollViewDelegate;
@protocol TappableActivityIndicatorViewDelegate;

@class OAToken;

@class AbstractDataProvider;
@class AbstractNavigationController;
@class AbstractSearchEngine;
@class ActionsView;
@class ActivityIndicatorViewWithBackground;
@class AllMoviesViewController;
@class AllTheatersViewController;
@class AmazonCache;
@class ApplePosterDownloader;
@class Application;
@class ApplicationTabBarController;
@class AutoResizingCell;
@class BackgroundInvocation;
@class BlurayCache;
@class CacheUpdater;
@class CollapsedMovieDetailsCell;
@class ColorCache;
@class CreditsViewController;
@class DateUtilities;
@class DifferenceEngine;
@class DVD;
@class DVDCache;
@class DVDNavigationController;
@class DVDViewController;
@class EditorViewController;
@class ExpandedMovieDetailsCell;
@class FandangoPosterDownloader;
@class FavoriteTheater;
@class Feed;
@class FontCache;
@class HelpCache;
@class IdentitySet;
@class ImageCache;
@class IMDbCache;
@class ImdbPosterDownloader;
@class InternationalDataCache;
@class Invocation;
@class LargePosterCache;
@class Location;
@class LocationManager;
@class LocationUtilities;
@class LookupResult;
@class MetacriticScoreProvider;
@class Movie;
@class MovieDetailsViewController;
@class MovieOverviewCell;
@class MutableNetflixCache;
@class Score;
@class MovieShowtimesCell;
@class MoviesNavigationController;
@class MovieTitleCell;
@class MultiDictionary;
@class MutableMultiDictionary;
@class NetflixCache;
@class NetflixNavigationController;
@class NetflixRatingsCell;
@class NetflixSearchDisplayController;
@class NetflixSearchEngine;
@class NetflixViewController;
@class NetworkUtilities;
@class NoneScoreProvider;
@class NotificationCenter;
@class AppDelegate;
@class Controller;
@class Model;
@class Operation;
@class Operation1;
@class Operation2;
@class OperationQueue;
@class Person;
@class PersonPosterCache;
@class Performance;
@class PointerSet;
@class PosterCache;
@class PostersViewController;
@class PreviewNetworksPosterDownloader;
@class PriorityMutex;
@class Pulser;
@class Queue;
@class Review;
@class ReviewBodyCell;
@class ReviewsViewController;
@class ReviewTitleCell;
@class RottenTomatoesScoreProvider;
@class ScoreCache;
@class ScoreProviderViewController;
@class SearchDatePickerViewController;
@class LocalizableStringsCache;
@class LocalSearchDisplayController;
@class LocalSearchEngine;
@class MutablePointerSet;
@class SearchEngineDelegate;
@class SearchRequest;
@class SearchResult;
@class SettingCell;
@class SettingsViewController;
@class Status;
@class TappableActivityIndicatorView;
@class TappableImageView;
@class TappableLabel;
@class TappableScrollView;
@class TextFieldEditorViewController;
@class Theater;
@class TheaterDetailsViewController;
@class TheaterNameCell;
@class TheatersNavigationController;
@class TicketsViewController;
@class TrailerCache;
@class UpcomingCache;
@class UpcomingMovieCell;
@class UpcomingMoviesNavigationController;
@class UpcomingMoviesViewController;
@class UserLocationCache;
@class ViewControllerUtilities;
@class WikipediaCache;
@class XmlDocument;
@class XmlElement;
@class XmlParser;
@class XmlSerializer;

#ifndef IPHONE_OS_VERSION_3
@class NetflixSearchViewController;
@class SearchViewController;
#endif