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
package org.metasyntactic.services;

import static org.metasyntactic.utilities.StringUtilities.isNullOrEmpty;

import java.io.File;
import java.util.Date;
import java.util.List;

import org.metasyntactic.LocationTracker;
import org.metasyntactic.NowPlayingApplication;
import org.metasyntactic.NowPlayingModel;
import org.metasyntactic.caches.UserLocationCache;
import org.metasyntactic.caches.scores.ScoreType;
import org.metasyntactic.data.Location;
import org.metasyntactic.data.Movie;
import org.metasyntactic.data.Performance;
import org.metasyntactic.data.Review;
import org.metasyntactic.data.Score;
import org.metasyntactic.data.Theater;
import org.metasyntactic.io.Persistable;
import org.metasyntactic.providers.DataProvider;
import org.metasyntactic.threading.ThreadingUtilities;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

public class NowPlayingService extends Service {
  private LocationTracker locationTracker;
  private final NowPlayingModel model;
  private final Object lock = new Object();
  private final NowPlayingServiceBinder binder = new NowPlayingServiceBinder(this);
  private volatile boolean shutdown;

  public NowPlayingService() {
    model = new NowPlayingModel(this);
    restartLocationTracker();
    update();

    deleteTrash();
  }

  private void deleteTrash() {
    final Runnable runnable = new Runnable() {
      public void run() {
        try {
          emptyTrash(NowPlayingApplication.trashDirectory, false);
        } catch (final InterruptedException e) {
          throw new RuntimeException(e);
        }
      }
    };
    ThreadingUtilities.performOnBackgroundThread("Service-EmptyTrash", runnable, null, false);
  }

  private void emptyTrash(final File directory, final boolean deleteDirectory) throws InterruptedException {
    for (final File child : directory.listFiles()) {
      if (shutdown) {
        return;
      }

      if (child.isDirectory()) {
        emptyTrash(child, true);
      } else {
        child.delete();
      }
      Thread.sleep(1000);
    }

    if (deleteDirectory) {
      directory.delete();
    }
  }

  private void shutdownLocationTracker() {
    if (locationTracker != null) {
      locationTracker.shutdown();
      locationTracker = null;
    }
  }

  private void restartLocationTracker() {
    shutdownLocationTracker();
    locationTracker = new LocationTracker(this);
  }

  @Override public IBinder onBind(final Intent intent) {
    return binder;
  }

  @Override public void onDestroy() {
    shutdown();
    stopSelf();
  }

  public void shutdown() {
    shutdown = true;
    shutdownLocationTracker();
    model.shutdown();
  }

  private void update() {
    final Runnable runnable = new Runnable() {
      public void run() {
        updateBackgroundEntryPoint();
      }
    };
    ThreadingUtilities.performOnBackgroundThread("Controller-Update", runnable, lock, false/* visible */);
  }

  private void updateBackgroundEntryPoint() {
    if (isNullOrEmpty(model.getUserAddress())) {
      return;
    }
    final Location location = UserLocationCache.downloadUserAddressLocationBackgroundEntryPoint(model.getUserAddress());
    if (location == null) {
      ThreadingUtilities.performOnMainThread(new Runnable() {
        public void run() {
          reportUnknownLocation();
        }
      });
    } else {
      model.update();
    }
  }

  private void reportUnknownLocation() {
    sendBroadcast(new Intent(NowPlayingApplication.NOW_PLAYING_COULD_COULD_NOT_FIND_LOCATION_INTENT));
  }

  public String getUserAddress() {
    return model.getUserAddress();
  }

  public void setUserAddress(final String userAddress) {
    if (getUserAddress().equals(userAddress)) {
      return;
    }
    model.setUserAddress(userAddress);
    update();
    NowPlayingApplication.refresh(true);
  }

  public static Location getLocationForAddress(final String address) {
    return UserLocationCache.locationForUserAddress(address);
  }

  public int getSearchDistance() {
    return model.getSearchDistance();
  }

  public void setSearchDistance(final int searchDistance) {
    model.setSearchDistance(searchDistance);
  }

  public int getSelectedTabIndex() {
    return model.getSelectedTabIndex();
  }

  public void setSelectedTabIndex(final int index) {
    model.setSelectedTabIndex(index);
  }

  public int getAllMoviesSelectedSortIndex() {
    return model.getAllMoviesSelecetedSortIndex();
  }

  public void setAllMoviesSelectedSortIndex(final int index) {
    model.setAllMoviesSelectedSortIndex(index);
  }

  public int getAllTheatersSelectedSortIndex() {
    return model.getAllTheatersSelectedSortIndex();
  }

  public void setAllTheatersSelectedSortIndex(final int index) {
    model.setAllTheatersSelectedSortIndex(index);
  }

  public int getUpcomingMoviesSelectedSortIndex() {
    return model.getUpcomingMoviesSelectedSortIndex();
  }

  public void setUpcomingMoviesSelectedSortIndex(final int index) {
    model.setUpcomingMoviesSelectedSortIndex(index);
  }

  public List<Movie> getMovies() {
    return model.getMovies();
  }

  public List<Theater> getTheaters() {
    return model.getTheaters();
  }

  public static String getTrailer(final Movie movie) {
    return NowPlayingModel.getTrailer(movie);
  }

  public List<Review> getReviews(final Movie movie) {
    return model.getReviews(movie);
  }

  public static String getAmazonAddress(final Movie movie) {
    return NowPlayingModel.getAmazonAddress(movie);
  }

  public static String getIMDbAddress(final Movie movie) {
    return NowPlayingModel.getIMDbAddress(movie);
  }

  public static String getWikipediaAddress(final Movie movie) {
    return NowPlayingModel.getWikipediaAddress(movie);
  }

  public List<Theater> getTheatersShowingMovie(final Movie movie) {
    return model.getTheatersShowingMovie(movie);
  }

  public List<Movie> getMoviesAtTheater(final Theater theater) {
    return model.getMoviesAtTheater(theater);
  }

  public List<Performance> getPerformancesForMovieAtTheater(final Movie movie, final Theater theater) {
    return model.getPerformancesForMovieAtTheater(movie, theater);
  }

  public ScoreType getScoreType() {
    return model.getScoreType();
  }

  public void setScoreType(final Object scoreType) {
    model.setScoreType(scoreType);
    update();
  }

  public Score getScore(final Movie movie) {
    return model.getScore(movie);
  }

  public static byte[] getPoster(final Movie movie) {
    return NowPlayingModel.getPoster(movie);
  }

  public static File getPosterFile_safeToCallFromBackground(final Movie movie) {
    return NowPlayingModel.getPosterFile_safeToCallFromBackground(movie);
  }

  public String getSynopsis(final Movie movie) {
    return model.getSynopsis(movie);
  }

  public void prioritizeMovie(final Movie movie) {
    model.prioritizeMovie(movie);
  }

  public boolean isAutoUpdateEnabled() {
    return model.isAutoUpdateEnabled();
  }

  public void setAutoUpdateEnabled(final boolean enabled) {
    model.setAutoUpdateEnabled(enabled);
    restartLocationTracker();
  }

  public Date getSearchDate() {
    return model.getSearchDate();
  }

  public void setSearchDate(final Date date) {
    model.setSearchDate(date);
    update();
  }

  public static void reportLocationForAddress(final Persistable location, final String displayString) {
    NowPlayingModel.reportLocationForAddress(location, displayString);
  }

  public List<Movie> getUpcomingMovies() {
    return model.getUpcomingMovies();
  }

  @Override public void onLowMemory() {
    super.onLowMemory();
    model.onLowMemory();
  }

  public DataProvider.State getDataProviderState() {
    return model.getDataProviderState();
  }

  public boolean isStale(final Theater theater) {
    return model.isStale(theater);
  }

  public String getShowtimesRetrievedOnString(final Theater theater) {
    return model.getShowtimesRetrievedOnString(theater, getResources());
  }

  public void addFavoriteTheater(final Theater theater) {
    model.addFavoriteTheater(theater);
  }

  public void removeFavoriteTheater(final Theater theater) {
    model.removeFavoriteTheater(theater);
  }

  public boolean isFavoriteTheater(final Theater theater) {
    return model.isFavoriteTheater(theater);
  }
}
