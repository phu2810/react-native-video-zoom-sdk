package com.reactnativevideozoomsdk;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import us.zoom.sdk.ZoomInstantSDK;
import us.zoom.sdk.ZoomInstantSDKUser;
import us.zoom.sdk.ZoomInstantSDKVideoAspect;
import us.zoom.sdk.ZoomInstantSDKVideoView;

public class ZoomShareViewManager extends SimpleViewManager<ZoomInstantSDKVideoView> {

  @NonNull
  @Override
  public String getName() {
    return "RNShareViewVideoSdk";
  }

  @NonNull
  @Override
  protected ZoomInstantSDKVideoView createViewInstance(@NonNull ThemedReactContext reactContext) {
    return new ZoomInstantSDKVideoView(reactContext);
  }

  @ReactProp(name = "userID")
  public void setShareVideoUnit(ZoomInstantSDKVideoView view, String userID) {
    if (null == ZoomInstantSDK.getInstance() || !ZoomInstantSDK.getInstance().isInSession()) {
      return;
    }
    ZoomInstantSDKUser user = ZoomInstantSDK.getInstance().getSession().getUser(userID);
    if (user == null) {
      return;
    }
    if (ZoomInstantSDK.getInstance().getShareHelper().isOtherSharing()) {
      user.getShareCanvas().subscribe(view, ZoomInstantSDKVideoAspect.ZoomInstantSDKVideoAspect_Original);
    } else {
      user.getVideoCanvas().unSubscribe(view);
    }
  }
}
