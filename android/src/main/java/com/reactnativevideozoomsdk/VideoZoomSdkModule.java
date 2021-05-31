package com.reactnativevideozoomsdk;

import android.Manifest;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.os.Build;
import android.util.Log;
import android.view.Display;
import android.view.WindowManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import com.facebook.react.BuildConfig;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.reactnativevideozoomsdk.util.NetworkUtil;

import java.util.List;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicBoolean;

import us.zoom.sdk.ZoomInstantSDK;
import us.zoom.sdk.ZoomInstantSDKAudioHelper;
import us.zoom.sdk.ZoomInstantSDKAudioOption;
import us.zoom.sdk.ZoomInstantSDKErrors;
import us.zoom.sdk.ZoomInstantSDKInitParams;
import us.zoom.sdk.ZoomInstantSDKRawDataMemoryMode;
import us.zoom.sdk.ZoomInstantSDKSession;
import us.zoom.sdk.ZoomInstantSDKSessionContext;
import us.zoom.sdk.ZoomInstantSDKUser;
import us.zoom.sdk.ZoomInstantSDKUserHelper;
import us.zoom.sdk.ZoomInstantSDKVideoHelper;
import us.zoom.sdk.ZoomInstantSDKVideoOption;

import static com.reactnativevideozoomsdk.ZoomConstants.KEY_AUDIO_STATUS;
import static com.reactnativevideozoomsdk.ZoomConstants.KEY_IS_HOST;
import static com.reactnativevideozoomsdk.ZoomConstants.KEY_USER_ID;
import static com.reactnativevideozoomsdk.ZoomConstants.KEY_USER_NAME;
import static com.reactnativevideozoomsdk.ZoomConstants.KEY_VIDEO_RATIO;
import static com.reactnativevideozoomsdk.ZoomConstants.KEY_VIDEO_STATUS;
import static com.reactnativevideozoomsdk.ZoomConstants.MEETING_AUDIO_STATUS_CHANGE;
import static com.reactnativevideozoomsdk.ZoomConstants.MEETING_STATE_CHANGE;
import static com.reactnativevideozoomsdk.ZoomConstants.MEETING_USER_JOIN;
import static com.reactnativevideozoomsdk.ZoomConstants.MEETING_USER_LEFT;
import static com.reactnativevideozoomsdk.ZoomConstants.MEETING_VIDEO_STATUS_CHANGE;
import static com.reactnativevideozoomsdk.util.ErrorMsgUtil.getMsgByErrorCode;
import static us.zoom.sdk.ZoomInstantSDKAudioStatus.ZoomInstantSDKAudioType.ZoomInstantSDKAudioType_None;

@ReactModule(name = VideoZoomSdkModule.NAME)
public class VideoZoomSdkModule extends ReactContextBaseJavaModule implements LifecycleEventListener, SimpleZoomSDKDelegate {

  public static final String NAME = "VideoZoomSdk";

  private final static int REQUEST_VIDEO_AUDIO_CODE = 1010;

  private static final String TAG = "VideoZoomSdkModule";

  private static final String MEETING_EVENT = "onMeetingEvent";
  private static final String KEY_EVENT = "event";
  private static final String KEY_DES = "des";

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  public VideoZoomSdkModule(ReactApplicationContext context) {
    super(context);
    this.context = context;
    this.context.addLifecycleEventListener(this);
    this.display = ((WindowManager) context.getSystemService(Service.WINDOW_SERVICE)).getDefaultDisplay();
  }

  private final Display display;
  private final ReactContext context;
  private final AtomicBoolean observerRegistered = new AtomicBoolean(false);

  private final IntentFilter filter = new IntentFilter() {{
    addAction("onConfigurationChanged");
    addAction("onRequestPermissionsResult");
  }};

  private final BroadcastReceiver moduleConfigReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      if (VideoZoomSdkModule.this.context.getCurrentActivity() == null) {
        return;
      }
      if ("onConfigurationChanged".equals(intent.getAction())) {
        Configuration configuration = intent.getParcelableExtra("newConfig");
        if (configuration != null) {
          refreshRotation();
        }
      } else if ("onRequestPermissionsResult".equals(intent.getAction())) {
        String[] permissions = intent.getStringArrayExtra("permissions");
        int[] grantResults = intent.getIntArrayExtra("grantResults");
        if (permissions == null || grantResults == null) {
          return;
        }
        joinSession();
      }
    }
  };

  private String sessionName, userName, token, password;
  private boolean hasInJoin;

  @ReactMethod
  public void toast(String text) {
    Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
  }

  @ReactMethod
  public void initSDK(Callback callback) {
    Objects.requireNonNull(context.getCurrentActivity()).runOnUiThread(() -> {
      ZoomInstantSDKInitParams params = new ZoomInstantSDKInitParams();
      if (BuildConfig.DEBUG) {
        params.enableLog = true;
      }
      params.videoRawDataMemoryMode = ZoomInstantSDKRawDataMemoryMode.ZoomInstantSDKRawDataMemoryModeHeap;
      params.audioRawDataMemoryMode = ZoomInstantSDKRawDataMemoryMode.ZoomInstantSDKRawDataMemoryModeHeap;
      params.shareRawDataMemoryMode = ZoomInstantSDKRawDataMemoryMode.ZoomInstantSDKRawDataMemoryModeHeap;
      int ret = ZoomInstantSDK.getInstance().initialize(context.getApplicationContext(), params);
      if (ret != ZoomInstantSDKErrors.Errors_Success) {
        Log.i(TAG, "Init zoom sdk error" + getMsgByErrorCode(ret));
      } else {
        Log.i(TAG, "Init zoom sdk success version: " + ZoomInstantSDK.getInstance().getSDKVersion());
        ZoomInstantSDK.getInstance().addListener(this);
      }
      callback.invoke(ret == ZoomInstantSDKErrors.Errors_Success);
    });
  }

  @ReactMethod
  public void joinMeeting(ReadableMap data) {
    userName = data.getString(KEY_USER_NAME);
    sessionName = data.getString(KEY_USER_NAME);
    token = data.getString(KEY_USER_NAME);
    password = data.getString(KEY_USER_NAME);

    joinSession();
  }

  private void joinSession() {
    if (hasInJoin) {
      return;
    }
    if (!requestPermission()) {
      return;
    }
    if (!NetworkUtil.hasDataNetwork(context)) {
      toast("Connection Failed. Please check your network connection and try again.");
      return;
    }
    if (null == ZoomInstantSDK.getInstance()) {
      toast("Please initialize SDK");
      return;
    }
    if (sessionName == null || userName == null || token == null || password == null) {
      toast("Missing params session");
      return;
    }
    ZoomInstantSDKSessionContext sessionContext = new ZoomInstantSDKSessionContext();
    ZoomInstantSDKAudioOption audioOption = new ZoomInstantSDKAudioOption();
    audioOption.connect = true;
    audioOption.mute = false;
    sessionContext.audioOption = audioOption;

    ZoomInstantSDKVideoOption videoOption = new ZoomInstantSDKVideoOption();
    videoOption.localVideoOn = true;
    sessionContext.videoOption = videoOption;

    //Required
    sessionContext.sessionName = sessionName;
    sessionContext.userName = userName;
    sessionContext.token = token;
    sessionContext.sessionPassword = password;

    ZoomInstantSDKSession session = ZoomInstantSDK.getInstance().joinSession(sessionContext);
    if (null == session) {
      return;
    }
    hasInJoin = true;
  }

  protected boolean requestPermission() {
    if (Build.VERSION.SDK_INT >= 23 && (context.checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED ||
      context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED ||
      context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED)) {
      ActivityCompat.requestPermissions(Objects.requireNonNull(context.getCurrentActivity()), new String[]{android.Manifest.permission.CAMERA,
        Manifest.permission.RECORD_AUDIO, Manifest.permission.READ_EXTERNAL_STORAGE}, REQUEST_VIDEO_AUDIO_CODE);
      return false;
    }
    return true;
  }

  @ReactMethod
  public void leaveCurrentMeeting() {
    if (ZoomInstantSDK.getInstance() == null) {
      return;
    }
    int ret = ZoomInstantSDK.getInstance().leaveSession(false);
    Log.d(TAG, "leaveSession ret = " + ret);
  }

  @ReactMethod
  public void getParticipants(final Callback callback) {
    if (!ZoomInstantSDK.getInstance().isInSession()) {
      return;
    }
    ZoomInstantSDKSession session = ZoomInstantSDK.getInstance().getSession();
    List<ZoomInstantSDKUser> userInfoList = session.getAllUsers();
    if (userInfoList == null || userInfoList.isEmpty()) {
      return;
    }
    WritableArray array = new WritableNativeArray();
    for (ZoomInstantSDKUser user : userInfoList) {
      if (user == null) {
        continue;
      }
      array.pushMap(getUserMap(user));
    }
    callback.invoke(null, array);
  }

  @ReactMethod
  public void getUserInfo(final String userId, final Callback callback) {
    if (!ZoomInstantSDK.getInstance().isInSession()) {
      return;
    }
    ZoomInstantSDKSession session = ZoomInstantSDK.getInstance().getSession();
    List<ZoomInstantSDKUser> userInfoList = session.getAllUsers();
    if (userInfoList == null || userInfoList.isEmpty()) {
      return;
    }
    ZoomInstantSDKUser user = session.getUser(userId);
    if (user != null) {
      callback.invoke(null, getUserMap(user));
    } else {
      Log.e(TAG, "Failed to getUserInfo: " + userId);
    }
  }

  @ReactMethod
  public void onMyAudio() {
    if (!ZoomInstantSDK.getInstance().isInSession()) {
      return;
    }
    ZoomInstantSDKSession session = ZoomInstantSDK.getInstance().getSession();
    ZoomInstantSDKUser zoomSDKUserInfo = session.getMySelf();
    if (zoomSDKUserInfo == null) {
      return;
    }
    if (zoomSDKUserInfo.getAudioStatus().getAudioType() == ZoomInstantSDKAudioType_None) {
      ZoomInstantSDK.getInstance().getAudioHelper().startAudio();
    }
    ZoomInstantSDK.getInstance().getAudioHelper().unMuteAudio(zoomSDKUserInfo);
  }

  @ReactMethod
  public void offMyAudio() {
    if (!ZoomInstantSDK.getInstance().isInSession()) {
      return;
    }
    ZoomInstantSDKSession session = ZoomInstantSDK.getInstance().getSession();
    ZoomInstantSDKUser zoomSDKUserInfo = session.getMySelf();
    if (zoomSDKUserInfo == null) {
      return;
    }
    if (zoomSDKUserInfo.getAudioStatus().getAudioType() == ZoomInstantSDKAudioType_None) {
      ZoomInstantSDK.getInstance().getAudioHelper().startAudio();
    }
    ZoomInstantSDK.getInstance().getAudioHelper().muteAudio(zoomSDKUserInfo);
  }

  @ReactMethod
  public void onOffMyVideo() {
    if (!ZoomInstantSDK.getInstance().isInSession()) {
      return;
    }
    ZoomInstantSDKSession session = ZoomInstantSDK.getInstance().getSession();
    ZoomInstantSDKUser zoomSDKUserInfo = session.getMySelf();
    if (zoomSDKUserInfo == null) {
      return;
    }
    if (zoomSDKUserInfo.getVideoStatus().isOn()) {
      ZoomInstantSDK.getInstance().getVideoHelper().stopVideo();
    } else {
      ZoomInstantSDK.getInstance().getVideoHelper().startVideo();
    }
  }

  @ReactMethod
  public void switchMyCamera() {
    if (!ZoomInstantSDK.getInstance().isInSession()) {
      return;
    }
    ZoomInstantSDKSession session = ZoomInstantSDK.getInstance().getSession();
    ZoomInstantSDKUser zoomSDKUserInfo = session.getMySelf();
    if (zoomSDKUserInfo == null) {
      return;
    }
    if (zoomSDKUserInfo.getVideoStatus().isHasVideoDevice() && zoomSDKUserInfo.getVideoStatus().isOn()) {
      ZoomInstantSDK.getInstance().getVideoHelper().switchCamera();
      refreshRotation();
    }
  }

  @ReactMethod
  public void checkSetHostToUser(String userName) {
    Log.i(TAG, "checkSetHostToUser: " + userName);
  }

  @ReactMethod
  public void startObserverEvent() {
    Log.i(TAG, "registerListener");
    observerRegistered.set(true);
  }

  @ReactMethod
  public void stopObserverEvent() {
    Log.i(TAG, "unregisterListener");
    observerRegistered.set(false);
  }

  @Override
  public void onHostResume() {
    refreshRotation();
    this.context.registerReceiver(moduleConfigReceiver, filter);
  }

  @Override
  public void onHostPause() {
  }

  @Override
  public void onHostDestroy() {
    this.context.unregisterReceiver(moduleConfigReceiver);
    stopMeetingService();
  }

  private void stopMeetingService() {
    Intent intent = new Intent(context, NotificationService.class);
    context.stopService(intent);
  }

  protected void refreshRotation() {
    if (!ZoomInstantSDK.getInstance().isInSession()) {
      return;
    }
    ZoomInstantSDKSession session = ZoomInstantSDK.getInstance().getSession();
    ZoomInstantSDKUser zoomSDKUserInfo = session.getMySelf();
    if (zoomSDKUserInfo == null) {
      return;
    }
    if (zoomSDKUserInfo.getVideoStatus().isHasVideoDevice() && zoomSDKUserInfo.getVideoStatus().isOn()) {
      int displayRotation = display.getRotation();
      Log.d(TAG, "rotateVideo:" + displayRotation);
      ZoomInstantSDK.getInstance().getVideoHelper().rotateMyVideo(displayRotation);
    }
  }

  @Override
  public void onSessionJoin() {
    if (!observerRegistered.get()) {
      return;
    }
    sendEvent(getMeetingStateEventMap("meeting_ready"));
    startMeetingService();
  }

  private void startMeetingService() {
    Intent intent = new Intent(context, NotificationService.class);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      context.startForegroundService(intent);
    } else {
      context.startService(intent);
    }
  }

  @Override
  public void onError(int i) {
    Log.e(TAG, "onError: " + getMsgByErrorCode(i));
  }

  @Override
  public void onUserJoin(ZoomInstantSDKUserHelper zoomInstantSDKUserHelper, List<ZoomInstantSDKUser> list) {
    if (!observerRegistered.get() || list == null || list.isEmpty()) {
      return;
    }
    for (ZoomInstantSDKUser user : list) {
      sendEvent(getMeetingUserEventMap(MEETING_USER_JOIN, user));
    }
  }

  @Override
  public void onUserLeave(ZoomInstantSDKUserHelper zoomInstantSDKUserHelper, List<ZoomInstantSDKUser> list) {
    if (!observerRegistered.get() || list == null || list.isEmpty()) {
      return;
    }
    for (ZoomInstantSDKUser user : list) {
      sendEvent(getMeetingUserEventMap(MEETING_USER_LEFT, user));
    }
  }

  @Override
  public void onUserAudioStatusChanged(ZoomInstantSDKAudioHelper zoomInstantSDKAudioHelper, List<ZoomInstantSDKUser> list) {
    if (!observerRegistered.get() || list == null || list.isEmpty()) {
      return;
    }
    for (ZoomInstantSDKUser user : list) {
      sendEvent(getMeetingUserEventMap(MEETING_AUDIO_STATUS_CHANGE, user));
    }
  }

  @Override
  public void onUserVideoStatusChanged(ZoomInstantSDKVideoHelper zoomInstantSDKVideoHelper, List<ZoomInstantSDKUser> list) {
    if (!observerRegistered.get() || list == null || list.isEmpty()) {
      return;
    }
    for (ZoomInstantSDKUser user : list) {
      sendEvent(getMeetingUserEventMap(MEETING_VIDEO_STATUS_CHANGE, user));
    }
  }

  public WritableMap getUserMap(ZoomInstantSDKUser user) {
    WritableMap map = new WritableNativeMap();
    map.putString(KEY_USER_ID, user.getUserId());
    map.putString(KEY_USER_NAME, user.getUserName());
    map.putString(KEY_VIDEO_RATIO, "1.0");
    map.putBoolean(KEY_VIDEO_STATUS, user.getVideoStatus().isOn());
    map.putBoolean(KEY_AUDIO_STATUS, !user.getAudioStatus().isMuted());
    map.putBoolean(KEY_IS_HOST, user.isHost());
    return map;
  }

  public WritableMap getMeetingUserEventMap(String event, ZoomInstantSDKUser user) {
    WritableMap map = getUserMap(user);
    map.putString(KEY_EVENT, event);
    return map;
  }

  public WritableMap getMeetingStateEventMap(String des) {
    WritableMap map = new WritableNativeMap();
    map.putString(KEY_EVENT, MEETING_STATE_CHANGE);
    map.putString(KEY_DES, des);
    return map;
  }

  private void sendEvent(@Nullable WritableMap params) {
    context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(MEETING_EVENT, params);
  }
}
