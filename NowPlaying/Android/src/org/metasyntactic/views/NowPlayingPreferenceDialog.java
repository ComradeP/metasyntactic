package org.metasyntactic.views;

import java.util.Arrays;
import java.util.List;

import org.metasyntactic.NowPlayingApplication;
import org.metasyntactic.RefreshableContext;
import org.metasyntactic.activities.R;
import org.metasyntactic.caches.scores.ScoreType;
import org.metasyntactic.services.NowPlayingService;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.view.View;
import android.widget.TextView;
import android.widget.AdapterView.OnItemSelectedListener;

public class NowPlayingPreferenceDialog extends AlertDialog {
  private final Builder builder;
  private PreferenceKeys prefKey;
  private int intValue;
  private TextView textView;
  private final RefreshableContext refreshableContext;
  private OnClickListener positiveButtonListener;

  public NowPlayingPreferenceDialog(final RefreshableContext refreshableContext) {
    super(refreshableContext.getContext());
    builder = new Builder(refreshableContext.getContext());
    this.refreshableContext = refreshableContext;
  }

  public Dialog create() {
    return builder.create();
  }

  public NowPlayingPreferenceDialog setNegativeButton(final int textId, final OnClickListener listener) {
    builder.setNegativeButton(textId, listener);
    return this;
  }

  public NowPlayingPreferenceDialog setOnItemSelectedListener(final OnItemSelectedListener listener) {
    builder.setOnItemSelectedListener(listener);
    return this;
  }

  public NowPlayingPreferenceDialog setEntries(final int items) {
    intValue = getIntPreferenceValue();
    final OnClickListener radioButtonListener = new OnClickListener() {
      public void onClick(final DialogInterface dialog, final int which) {
        intValue = which;
      }
    };
    setSingleChoiceItems(items, getIntPreferenceValue(), radioButtonListener);
    positiveButtonListener = new OnClickListener() {
      public void onClick(final DialogInterface dialog, final int which) {
        setIntPreferenceValue(intValue);
        refreshableContext.refresh();
      }
    };
    return this;
  }

  private Object setSingleChoiceItems(final int items, final int checkedItem, final OnClickListener listener) {
    builder.setSingleChoiceItems(items, checkedItem, listener);
    return this;
  }

  public NowPlayingPreferenceDialog setItems(final String[] distanceValues) {
    final OnClickListener listItemListener = new OnClickListener() {
      public void onClick(final DialogInterface dialog, final int which) {
        setIntPreferenceValue(Integer.parseInt(distanceValues[which]));
        refreshableContext.refresh();
      }
    };
    builder.setItems(distanceValues, listItemListener);
    return this;
  }

  public NowPlayingPreferenceDialog setPositiveButton(final int textId) {
    builder.setPositiveButton(textId, positiveButtonListener);
    return this;
  }

  public NowPlayingPreferenceDialog setNegativeButton(final int textId) {
    builder.setNegativeButton(textId, null);
    return this;
  }

  public NowPlayingPreferenceDialog setKey(final PreferenceKeys key) {
    prefKey = key;
    return this;
  }

  @Override
  public void show() {
    builder.show();
  }
  
  private NowPlayingService getService() {
    return NowPlayingApplication.getService();
  }

  private int getIntPreferenceValue() {
    switch (prefKey) {
    case MOVIES_SORT:
      return getService().getAllMoviesSelectedSortIndex();
    case UPCOMING_MOVIES_SORT:
      return getService().getUpcomingMoviesSelectedSortIndex();
    case THEATERS_SORT:
      return getService().getAllTheatersSelectedSortIndex();
    case SEARCH_DISTANCE:
      return getService().getSearchDistance();
    case REVIEWS_PROVIDER:
      return scoreTypes.indexOf(getService().getScoreType());
    case AUTO_UPDATE_LOCATION:
      return autoUpdate.indexOf(getService().isAutoUpdateEnabled());
    }
    return 0;
  }

  private CharSequence getStringPreferenceValue() {
    switch (prefKey) {
    case LOCATION:
      return getService().getUserAddress();
    }
    return null;
  }

  private void setIntPreferenceValue(final int prefValue) {
    switch (prefKey) {
    case MOVIES_SORT:
      getService().setAllMoviesSelectedSortIndex(prefValue);
      break;
    case UPCOMING_MOVIES_SORT:
      getService().setUpcomingMoviesSelectedSortIndex(prefValue);
      break;
    case THEATERS_SORT:
      getService().setAllTheatersSelectedSortIndex(prefValue);
      break;
    case SEARCH_DISTANCE:
      getService().setSearchDistance(prefValue);
      break;
    case REVIEWS_PROVIDER:
      getService().setScoreType(scoreTypes.get(prefValue));
      break;
    case AUTO_UPDATE_LOCATION:
      getService().setAutoUpdateEnabled(autoUpdate.get(prefValue));
      break;
    }
  }

  private void setStringPreferenceValue(final String prefValue) {
    switch (prefKey) {
    case LOCATION:
      getService().setUserAddress(prefValue);
      break;
    }
  }

  public enum PreferenceKeys {
    MOVIES_SORT, UPCOMING_MOVIES_SORT, THEATERS_SORT, LOCATION, SEARCH_DISTANCE, SEARCH_DATE, REVIEWS_PROVIDER, AUTO_UPDATE_LOCATION
  }

  public NowPlayingPreferenceDialog setTextView(final View textEntryView) {
    textView = (TextView)textEntryView.findViewById(R.id.dialogEdit);
    textView.setText(getStringPreferenceValue());
    builder.setView(textEntryView);
    positiveButtonListener = new OnClickListener() {
      public void onClick(final DialogInterface dialog, final int which) {
        setStringPreferenceValue(textView.getText().toString());
        refreshableContext.refresh();
      }
    };
    return this;
  }

  // Work around to make handling of scoretype,auto_update same as sort
  // preference, as both are choicetypes.
  private final List<ScoreType> scoreTypes = Arrays.asList(ScoreType.Google, ScoreType.Metacritic, ScoreType.RottenTomatoes);
  private final List<Boolean> autoUpdate = Arrays.asList(Boolean.TRUE, Boolean.FALSE);

  @Override public void setTitle(final CharSequence title) {
    super.setTitle(title);
    builder.setTitle(title);
  }

  @Override public void setTitle(final int titleId) {
    super.setTitle(titleId);
    builder.setTitle(titleId);
  }
}
