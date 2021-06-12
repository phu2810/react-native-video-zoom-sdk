package com.reactnativevideozoomsdk;

import android.widget.Toast;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = VideoZoomSdkModule.NAME)
public class VideoZoomSdkModule extends ReactContextBaseJavaModule {

  public static final String NAME = "VideoZoomSdk";

  private static final String TAG = "VideoZoomSdkModule";

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  public VideoZoomSdkModule(ReactApplicationContext context) {
    super(context);
    this.context = context;
  }

  private final ReactContext context;

  @ReactMethod
  public void toast(String text) {
    Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
  }

  @ReactMethod
  public void initSDK(Callback callback) {
  }

  @ReactMethod
  public void joinMeeting(ReadableMap data) {
  }

  @ReactMethod
  public void leaveCurrentMeeting() {
  }

  @ReactMethod
  public void getParticipants(final Callback callback) {
  }

  @ReactMethod
  public void getUserInfo(final String userId, final Callback callback) {
  }

  @ReactMethod
  public void onMyAudio() {
  }

  @ReactMethod
  public void offMyAudio() {
  }

  @ReactMethod
  public void onOffMyVideo() {
  }

  @ReactMethod
  public void switchMyCamera() {
  }

  @ReactMethod
  public void checkSetHostToUser(String userName) {
  }

  @ReactMethod
  public void startObserverEvent() {
  }

  @ReactMethod
  public void stopObserverEvent() {
  }
}
