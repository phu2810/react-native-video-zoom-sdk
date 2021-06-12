package com.reactnativevideozoomsdk;

import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

public class ZoomShareViewManager extends SimpleViewManager<View> {

  @NonNull
  @Override
  public String getName() {
    return "RNShareViewVideoSdk";
  }

  @NonNull
  @Override
  protected View createViewInstance(@NonNull ThemedReactContext reactContext) {
    return new View(reactContext);
  }

  @ReactProp(name = "userID")
  public void setShareVideoUnit(View view, String userID) {
  }
}
