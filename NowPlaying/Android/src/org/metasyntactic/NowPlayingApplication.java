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
package org.metasyntactic;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Random;

import org.metasyntactic.activities.R;
import org.metasyntactic.services.NowPlayingService;
import org.metasyntactic.threading.ThreadingUtilities;
import org.metasyntactic.utilities.ExceptionUtilities;
import org.metasyntactic.utilities.FileUtilities;
import org.metasyntactic.utilities.LogUtilities;

import android.app.Activity;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;

public class NowPlayingApplication extends Application {
  public static final String NOW_PLAYING_CHANGED_INTENT = "NOW_PLAYING_CHANGED_INTENT";
  public static final String NOW_PLAYING_LOCAL_DATA_DOWNLOAD_PROGRESS = "NOW_PLAYING_LOCAL_DATA_DOWNLOAD_PROGRESS";
  public static final String NOW_PLAYING_LOCAL_DATA_DOWNLOADED = "NOW_PLAYING_LOCAL_DATA_DOWNLOADED";
  public static final String NOW_PLAYING_UPDATING_LOCATION_START = "NOW_PLAYING_UPDATING_LOCATION_START";
  public static final String NOW_PLAYING_UPDATING_LOCATION_STOP = "NOW_PLAYING_UPDATING_LOCATION_STOP";
  public static final String NOW_PLAYING_SCROLLING_INTENT = "NOW_PLAYING_SCROLLING_INTENT";
  public static final String NOW_PLAYING_NOT_SCROLLING_INTENT = "NOW_PLAYING_NOT_SCROLLING_INTENT";
  public static final String NOW_PLAYING_COULD_COULD_NOT_FIND_LOCATION_INTENT = "NOW_PLAYING_COULD_NOT_FIND_LOCATION_INTENT";

  public static final String host =
  /*
   * / "metaboxoffice6"; /
   */
  "metaboxoffice2";
  // */
  public static final File root = new File("/sdcard");
  public static final File applicationDirectory = new File(root, "NowPlaying");
  public static final File trashDirectory = new File(applicationDirectory, "Trash");
  public static final File dataDirectory = new File(applicationDirectory, "Data");
  public static final File tempDirectory = new File(applicationDirectory, "Temp");
  public static final File performancesDirectory = new File(dataDirectory, "Performances");
  public static final File trailersDirectory = new File(applicationDirectory, "Trailers");
  public static final File userLocationsDirectory = new File(applicationDirectory, "UserLocations");
  public static final File scoresDirectory = new File(applicationDirectory, "Scores");
  public static final File reviewsDirectory = new File(applicationDirectory, "Reviews");
  public static final File imdbDirectory = new File(applicationDirectory, "IMDb");
  public static final File amazonDirectory = new File(applicationDirectory, "Amazon");
  public static final File wikipediaDirectory = new File(applicationDirectory, "Wikipedia");
  public static final File postersDirectory = new File(applicationDirectory, "Posters");
  public static final File postersLargeDirectory = new File(postersDirectory, "Large");
  public static final File dvdDirectory = new File(applicationDirectory, "DVD");
  public static final File blurayDirectory = new File(applicationDirectory, "Bluray");
  public static final File upcomingDirectory = new File(applicationDirectory, "Upcoming");
  public static final File upcomingCastDirectory = new File(upcomingDirectory, "Cast");
  public static final File upcomingSynopsesDirectory = new File(upcomingDirectory, "Synopses");
  public static final File upcomingTrailersDirectory = new File(upcomingDirectory, "Trailers");
  private static Pulser pulser;

  private static NowPlayingApplication application;

  static {
    if (FileUtilities.isSDCardAccessible()) {
      createDirectories();

      {
        final Runnable runnable = new Runnable() {
          public void run() {
            if (application != null) {
              application.sendBroadcast(new Intent(NOW_PLAYING_CHANGED_INTENT));
            }
          }
        };
        pulser = new Pulser(runnable, 5);
      }
    }
  }

  public NowPlayingApplication() {
    application = this;
  }

  public static Application getApplication() {
    return application;
  }

  public static String getName(final Resources resources) {
    return resources.getString(R.string.application_name);
  }

  public static String getNameAndVersion(final Resources resources) {
    return resources.getString(R.string.application_name_and_version);
  }

  private final BroadcastReceiver unmountedReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(final Context contextfinal, final Intent intent) {
      FileUtilities.setSDCardAccessible(false);
    }
  };

  private final BroadcastReceiver mountedReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(final Context contextfinal, final Intent intent) {
      FileUtilities.setSDCardAccessible(true);
    }
  };

  private final BroadcastReceiver ejectReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(final Context contextfinal, final Intent intent) {
      FileUtilities.setSDCardAccessible(true);
    }
  };

  @Override
  public void onCreate() {
    super.onCreate();
    ExceptionUtilities.registerExceptionHandler(this);
    registerReceiver(unmountedReceiver, new IntentFilter(Intent.ACTION_MEDIA_UNMOUNTED));
    registerReceiver(mountedReceiver, new IntentFilter(Intent.ACTION_MEDIA_MOUNTED));
    registerReceiver(ejectReceiver, new IntentFilter(Intent.ACTION_MEDIA_EJECT));
  }

  @Override
  public void onLowMemory() {
    super.onLowMemory();
    FileUtilities.onLowMemory();

    NowPlayingService localService = service;
    if (localService != null) {
      localService.onLowMemory();
    }
  }

  private static Iterable<File> directories() {
    try {
      final Collection<File> directories = new ArrayList<File>();
      for (final Field field : NowPlayingApplication.class.getFields()) {
        if (!field.getType().equals(File.class) || root.equals(field.get(null))) {
          continue;
        }
        directories.add((File) field.get(null));
      }
      return directories;
    } catch (final IllegalAccessException e) {
      throw new RuntimeException(e);
    }
  }

  public static void reset() {
    deleteDirectories();
    createDirectories();
  }

  private static void createDirectories() {
    final long start = System.currentTimeMillis();
    for (final File file : directories()) {
      file.mkdirs();
      if (file.exists()) {
        final File nomediaFile = new File(file, ".nomedia");
        try {
          nomediaFile.createNewFile();
        } catch (final IOException e) {
          throw new RuntimeException(e);
        }
      }
    }
    LogUtilities.logTime(NowPlayingApplication.class, "Create Directories", start);
  }

  private static void deleteDirectories() {
    final long start = System.currentTimeMillis();
    // deleteDirectory(applicationDirectory);
    trashDirectory.mkdirs();
    for (final File directory : directories()) {
      if (directory != trashDirectory) {
        final File destination = getUniqueTrashDirectory();
        directory.renameTo(destination);
      }
    }
    LogUtilities.logTime(NowPlayingApplication.class, "Delete Directories", start);
  }

  private static File getUniqueTrashDirectory() {
    File result;
    do {
      result = new File(trashDirectory, randomString());
    } while (result.exists());

    return result;
  }

  private static final Random random = new Random();

  private static String randomString() {
    final StringBuilder buffer = new StringBuilder(8);
    for (int i = 0; i < 8; i++) {
      buffer.append((char) ('a' + random.nextInt(26)));
    }
    return buffer.toString();
  }

  public static void deleteDirectory(final File directory) {
    deleteItem(directory);
  }

  public static void deleteItem(final File item) {
    if (!item.exists()) {
      return;
    }
    if (item.isDirectory()) {
      for (final File child : item.listFiles()) {
        deleteItem(child);
      }
    } else {
      item.delete();
    }
  }

  public static boolean useKilometers() {
    return false;
  }

  public static void refresh() {
    refresh(false);
  }

  public static void refresh(final boolean force) {
    if (ThreadingUtilities.isBackgroundThread()) {
      final Runnable runnable = new Runnable() {
        public void run() {
          refresh(force);
        }
      };
      ThreadingUtilities.performOnMainThread(runnable);
      return;
    }
    if (pulser == null) {
      return;
    }

    if (force) {
      pulser.forcePulse();
    } else {
      pulser.tryPulse();
    }
  }

  private Object lock = new Object();
  private int activityCount;
  private NowPlayingService service;

  public static NowPlayingService registerActivity(Activity activity) {
    return application.registerActivityWorker(activity);
  }

  public static void unregisterActivity(Activity activity) {
    application.unregisterActivityWorker(activity);
  }

  private NowPlayingService registerActivityWorker(Activity activity) {
    synchronized (lock) {
      activityCount++;
      if (activityCount == 1) {
        if (service == null) {
          service = new NowPlayingService();
          service.onCreate();
        }
      }
      return service;
    }
  }

  private void unregisterActivityWorker(Activity activity) {
    synchronized (lock) {
      activityCount--;
      if (activityCount == 0) {
        ThreadingUtilities.performOnMainThread(5000, new Runnable() {
          public void run() {
            shutdownService();
          }
        });
      }
    }
  }

  private void shutdownService() {
    synchronized (lock) {
      if (activityCount == 0) {
        if (service != null) {
          service.onTerminate();
          service = null;
        }
      }
    }
  }
}
