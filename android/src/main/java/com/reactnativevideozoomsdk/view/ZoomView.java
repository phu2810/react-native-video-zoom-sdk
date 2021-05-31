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
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.glidebitmappool.GlideBitmapPool;
import com.reactnativevideozoomsdk.R;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import us.zoom.internal.video.SDKVideoSurfaceView;
import us.zoom.internal.video.SDKVideoTextureView;
import us.zoom.internal.video.ZPGLSurfaceView;
import us.zoom.internal.video.ZPGLTextureView;
import us.zoom.sdk.ZoomInstantSDK;
import us.zoom.sdk.ZoomInstantSDKUser;
import us.zoom.sdk.ZoomInstantSDKVideoAspect;
import us.zoom.sdk.ZoomInstantSDKVideoView;

public class ZoomView extends FrameLayout implements SDKVideoTextureView.Listener, ZPGLTextureView.Renderer {

  private static final String TAG = "ZoomView";

  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  private ZoomInstantSDKVideoView videoRenderer;
  private ZPGLSurfaceView surfaceView;

  private ImageView mThumbnail;
  private String mUserId;
  private Bitmap mThumbnailBitmap;

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
    videoRenderer = findViewById(R.id.videoView);
    mThumbnail = findViewById(R.id.thumbnail);
  }

  public void setAttendeeVideoUnit(String userId) {
    if (!TextUtils.isEmpty(userId)) {
      mUserId = userId;
      addVideo();
    } else {
      removeVideo();
    }
  }

  public void addVideo() {
    if (mUserId == null) {
      return;
    }
    ZoomInstantSDKUser user = ZoomInstantSDK.getInstance().getSession().getUser(mUserId);
    if (user != null) {
      user.getVideoCanvas().unSubscribe(videoRenderer);
      user.getVideoCanvas().subscribe(videoRenderer, ZoomInstantSDKVideoAspect.ZoomInstantSDKVideoAspect_PanAndScan);
    }
  }

  public void removeVideo() {
    if (mUserId == null) {
      return;
    }
    ZoomInstantSDKUser user = ZoomInstantSDK.getInstance().getSession().getUser(mUserId);
    if (user != null) {
      user.getVideoCanvas().unSubscribe(videoRenderer);
    }
  }

  public void screenshotThumbnail() {
    if (surfaceView == null) {
      Log.e(TAG, "screenshotThumbnail: failed to get surface view");
      return;
    }
    int videoWidth = surfaceView.getWidth();
    int videoHeight = surfaceView.getHeight();
    if (mThumbnailBitmap != null) {
      GlideBitmapPool.putBitmap(mThumbnailBitmap);
    }
    mThumbnailBitmap = GlideBitmapPool.getBitmap(videoWidth, videoHeight, Bitmap.Config.ARGB_8888);
    int[] locationOfViewInWindow = new int[2];
    surfaceView.getLocationInWindow(locationOfViewInWindow);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      PixelCopy.request(
        surfaceView,
        mThumbnailBitmap,
        copyResult -> {
          if (copyResult == PixelCopy.SUCCESS) {
            mThumbnail.setImageBitmap(mThumbnailBitmap);
          }
        },
        new Handler());
    } else {
      // For Android below 26
      // Zoom view will be hidden to show system user avatar
    }
  }

  @Override
  public void beforeGLContextDestroyed() {

  }

  @Override
  public void onSurfaceDestroyed() {

  }

  @Override
  public void onSurfaceCreated(GL10 gl10, EGLConfig eglConfig) {

  }

  @Override
  public void onSurfaceChanged(GL10 gl10, int i, int i1) {

  }

  @Override
  public void onDrawFrame(GL10 gl10) {

  }
}
