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

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.widget.MediaController;
import android.widget.VideoView;

public class VideoViewActivity extends Activity {
  /** TODO: Set the path variable to a streaming video URL or a local media file path. */
  private String path;
  private VideoView videoView;

  @Override
  public void onCreate(final Bundle icicle) {
    super.onCreate(icicle);
    NowPlayingControllerWrapper.addActivity(this);
    setContentView(R.layout.videoview);
    this.path = getIntent().getExtras().getString("trailer_url");
    this.videoView = (VideoView) findViewById(R.id.surface_view);
    this.videoView.setVideoURI(Uri.parse(this.path));
    //  mVideoView.setVideoPath(path);
    this.videoView.setMediaController(new MediaController(this));
    this.videoView.requestFocus();
    this.videoView.start();
  }

  protected void onDestroy() {
    NowPlayingControllerWrapper.removeActivity(this);
    super.onDestroy();
  }
}
