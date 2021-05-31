package com.reactnativevideozoomsdk;

import java.util.List;

import us.zoom.sdk.ZoomInstantSDKAudioHelper;
import us.zoom.sdk.ZoomInstantSDKAudioRawData;
import us.zoom.sdk.ZoomInstantSDKChatHelper;
import us.zoom.sdk.ZoomInstantSDKChatMessage;
import us.zoom.sdk.ZoomInstantSDKDelegate;
import us.zoom.sdk.ZoomInstantSDKLiveStreamHelper;
import us.zoom.sdk.ZoomInstantSDKLiveStreamStatus;
import us.zoom.sdk.ZoomInstantSDKPasswordHandler;
import us.zoom.sdk.ZoomInstantSDKShareHelper;
import us.zoom.sdk.ZoomInstantSDKShareStatus;
import us.zoom.sdk.ZoomInstantSDKUser;
import us.zoom.sdk.ZoomInstantSDKUserHelper;
import us.zoom.sdk.ZoomInstantSDKVideoHelper;

public interface SimpleZoomSDKDelegate extends ZoomInstantSDKDelegate {

  @Override
  default void onSessionJoin() {

  }

  @Override
  default void onSessionLeave() {

  }

  @Override
  default void onError(int i) {

  }

  @Override
  default void onUserJoin(ZoomInstantSDKUserHelper zoomInstantSDKUserHelper, List<ZoomInstantSDKUser> list) {

  }

  @Override
  default void onUserLeave(ZoomInstantSDKUserHelper zoomInstantSDKUserHelper, List<ZoomInstantSDKUser> list) {

  }

  @Override
  default void onUserVideoStatusChanged(ZoomInstantSDKVideoHelper zoomInstantSDKVideoHelper, List<ZoomInstantSDKUser> list) {

  }

  @Override
  default void onUserAudioStatusChanged(ZoomInstantSDKAudioHelper zoomInstantSDKAudioHelper, List<ZoomInstantSDKUser> list) {

  }

  @Override
  default void onUserShareStatusChanged(ZoomInstantSDKShareHelper zoomInstantSDKShareHelper, ZoomInstantSDKUser zoomInstantSDKUser, ZoomInstantSDKShareStatus zoomInstantSDKShareStatus) {

  }

  @Override
  default void onLiveStreamStatusChanged(ZoomInstantSDKLiveStreamHelper zoomInstantSDKLiveStreamHelper, ZoomInstantSDKLiveStreamStatus zoomInstantSDKLiveStreamStatus) {

  }

  @Override
  default void onChatNewMessageNotify(ZoomInstantSDKChatHelper zoomInstantSDKChatHelper, ZoomInstantSDKChatMessage zoomInstantSDKChatMessage) {

  }

  @Override
  default void onUserHostChanged(ZoomInstantSDKUserHelper zoomInstantSDKUserHelper, ZoomInstantSDKUser zoomInstantSDKUser) {

  }

  @Override
  default void onUserManagerChanged(ZoomInstantSDKUser zoomInstantSDKUser) {

  }

  @Override
  default void onUserNameChanged(ZoomInstantSDKUser zoomInstantSDKUser) {

  }

  @Override
  default void onUserActiveAudioChanged(ZoomInstantSDKAudioHelper zoomInstantSDKAudioHelper, List<ZoomInstantSDKUser> list) {

  }

  @Override
  default void onSessionNeedPassword(ZoomInstantSDKPasswordHandler zoomInstantSDKPasswordHandler) {

  }

  @Override
  default void onSessionPasswordWrong(ZoomInstantSDKPasswordHandler zoomInstantSDKPasswordHandler) {

  }

  @Override
  default void onMixedAudioRawDataReceived(ZoomInstantSDKAudioRawData zoomInstantSDKAudioRawData) {

  }

  @Override
  default void onOneWayAudioRawDataReceived(ZoomInstantSDKAudioRawData zoomInstantSDKAudioRawData, ZoomInstantSDKUser zoomInstantSDKUser) {

  }
}
