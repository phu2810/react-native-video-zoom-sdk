package com.reactnativevideozoomsdk.view;

import android.content.Context;
import android.util.AttributeSet;

import us.zoom.sdk.ZoomInstantSDKVideoView;

public class ZoomShareView extends ZoomInstantSDKVideoView {

  public ZoomShareView(Context context) {
    this(context, null);
  }

  public ZoomShareView(Context context, AttributeSet attributeSet) {
    this(context, attributeSet, 0);
  }

  public ZoomShareView(Context context, AttributeSet attributeSet, int i) {
    super(context, attributeSet, i);
  }
}
