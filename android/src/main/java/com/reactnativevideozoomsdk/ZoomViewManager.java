package com.reactnativevideozoomsdk;

import android.content.Context;
import android.view.LayoutInflater;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.reactnativevideozoomsdk.view.ZoomView;

public class ZoomViewManager extends SimpleViewManager<ZoomView> {

  @NonNull
  @Override
  public String getName() {
    return "RNVideoZoomView";
  }

  @NonNull
  @Override
  protected ZoomView createViewInstance(@NonNull ThemedReactContext reactContext) {
    LayoutInflater inflater = (LayoutInflater) reactContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    return (ZoomView) inflater.inflate(R.layout.layout_meeting_content_normal, null);
  }

  @ReactProp(name = "userID")
  public void setAttendeeVideoUnit(ZoomView view, String userID) {
    view.setAttendeeVideoUnit(userID);
  }
}
