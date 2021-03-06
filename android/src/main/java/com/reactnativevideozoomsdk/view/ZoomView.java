package com.reactnativevideozoomsdk.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.PixelCopy;
import android.view.SurfaceHolder;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.glidebitmappool.GlideBitmapPool;
import com.reactnativevideozoomsdk.R;
import com.reactnativevideozoomsdk.SimpleZoomSDKDelegate;

import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import us.zoom.internal.video.SDKVideoSurfaceView;
import us.zoom.sdk.ZoomInstantSDK;
import us.zoom.sdk.ZoomInstantSDKUser;
import us.zoom.sdk.ZoomInstantSDKVideoAspect;
import us.zoom.sdk.ZoomInstantSDKVideoHelper;
import us.zoom.sdk.ZoomInstantSDKVideoView;

public class ZoomView extends FrameLayout implements SurfaceHolder.Callback, SimpleZoomSDKDelegate {

  private static final String TAG = "ZoomView";

  private final Executor executor = Executors.newSingleThreadExecutor();
  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  private ZoomInstantSDKVideoView videoRenderer;
  private SDKVideoSurfaceView surfaceView;

  private ImageView thumbnail;
  private String userId;
  private Bitmap thumbnailBitmap;

  private final Runnable screenshotTask = new Runnable() {
    @Override
    public void run() {
      screenshotThumbnail();
      mainHandler.postDelayed(this, 30000);
    }
  };

  public ZoomView(@NonNull Context context) {
    this(context, null);
  }

  public ZoomView(@NonNull Context context, @Nullable AttributeSet attrs) {
    this(context, attrs, 0);
  }

  public ZoomView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
  }

  @Override
  protected void onFinishInflate() {
    super.onFinishInflate();
    thumbnail = findViewById(R.id.thumbnail);

    videoRenderer = findViewById(R.id.videoView);

    View view = videoRenderer.getChildAt(0);
    if (view instanceof SDKVideoSurfaceView) {
      surfaceView = (SDKVideoSurfaceView) view;
      surfaceView.getHolder().addCallback(this);
    }

    ZoomInstantSDK.getInstance().addListener(this);
  }

  public void setAttendeeVideoUnit(String userId) {
    if (!TextUtils.isEmpty(userId)) {
      this.userId = userId;
      addVideo();
    } else {
      removeVideo();
    }
  }

  public void addVideo() {
    if (userId == null) {
      return;
    }
    ZoomInstantSDKUser user = ZoomInstantSDK.getInstance().getSession().getUser(userId);
    if (user != null) {
      user.getVideoCanvas().subscribe(videoRenderer, ZoomInstantSDKVideoAspect.ZoomInstantSDKVideoAspect_PanAndScan);
    }
  }

  public void removeVideo() {
    if (userId == null) {
      return;
    }
    ZoomInstantSDKUser user = ZoomInstantSDK.getInstance().getSession().getUser(userId);
    if (user == null) {
      return;
    }
    user.getVideoCanvas().unSubscribe(videoRenderer);
  }

  @Override
  public void surfaceCreated(SurfaceHolder holder) {
    // Distract view to wait for video view fully rendered
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      // Show thumbnail is last screenshot video view
      if (thumbnail.getDrawable() != null) {
        thumbnail.setImageBitmap(thumbnailBitmap);
        thumbnail.setVisibility(VISIBLE);
      } else {
        // Screenshot is not taken yet, hide zoom view to show system user avatar
        setVisibility(GONE);
      }
    } else {
      // For Android below 26, screenshot thumbnail don't work well, hide zoom view to show system user avatar
      setVisibility(GONE);
    }
    // Set delay time for video view show to user
    mainHandler.postDelayed(() -> {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        // Hide last screenshot thumbnail
        thumbnail.setVisibility(GONE);
      }
      // Show zoom view
      setVisibility(VISIBLE);
    }, 1000);

    mainHandler.postDelayed(screenshotTask, 3000);
  }

  @Override
  public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
  }

  @Override
  public void surfaceDestroyed(SurfaceHolder holder) {
    mainHandler.removeCallbacksAndMessages(null);
  }

  public void screenshotThumbnail() {
    executor.execute(() -> {
      int videoWidth = surfaceView.getWidth();
      int videoHeight = surfaceView.getHeight();
      if (thumbnailBitmap != null) {
        GlideBitmapPool.putBitmap(thumbnailBitmap);
      }
      thumbnailBitmap = GlideBitmapPool.getBitmap(videoWidth, videoHeight, Bitmap.Config.ARGB_8888);
      int[] locationOfViewInWindow = new int[2];
      surfaceView.getLocationInWindow(locationOfViewInWindow);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        Log.d(TAG, "screenshotThumbnail: " + Thread.currentThread().getName());
        PixelCopy.request(
          surfaceView,
          thumbnailBitmap,
          copyResult -> {
            if (copyResult == PixelCopy.SUCCESS) {
              if (thumbnail.getDrawable() == null) {
                mainHandler.post(() -> thumbnail.setImageBitmap(thumbnailBitmap));
              }
            }
          },
          mainHandler);
      }
    });
  }

  @Override
  public void onUserVideoStatusChanged(ZoomInstantSDKVideoHelper zoomInstantSDKVideoHelper, List<ZoomInstantSDKUser> list) {
    if (userId == null) {
      return;
    }
    for (ZoomInstantSDKUser user : list) {
      if (!userId.equals(user.getUserId())) {
        continue;
      }
      if (user.getVideoStatus().isOn()) {
        setVisibility(VISIBLE);
      } else {
        setVisibility(GONE);
      }
      break;
    }
  }
}
