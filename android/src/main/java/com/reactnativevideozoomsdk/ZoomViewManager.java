package com.reactnativevideozoomsdk;

import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

public class ZoomViewManager extends SimpleViewManager<View> {

  @NonNull
  @Override
  public String getName() {
    return "RNVideoZoomView";
  }

  @NonNull
  @Override
  protected View createViewInstance(@NonNull ThemedReactContext reactContext) {
    return new View(reactContext);
  }

  @ReactProp(name = "userID")
  public void setAttendeeVideoUnit(View view, String userID) {
  }
}
