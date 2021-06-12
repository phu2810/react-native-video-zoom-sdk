package com.reactnativevideozoomsdk;

public @interface ZoomConstants {
  String KEY_USER_NAME = "userName";
  String KEY_USER_ID = "userID";
  String KEY_VIDEO_STATUS = "videoStatus";
  String KEY_AUDIO_STATUS = "audioStatus";
  String KEY_VIDEO_RATIO = "videoRatio";
  String KEY_IS_HOST = "isHost";
  String KEY_SHARE_STATUS = "shareStatus";

  String MEETING_STATE_CHANGE = "meetingStateChange";
  String MEETING_USER_JOIN = "sinkMeetingUserJoin";
  String MEETING_USER_LEFT = "sinkMeetingUserLeft";
  String MEETING_ACTIVE_SHARE = "sinkMeetingActiveShare";
  String MEETING_AUDIO_STATUS_CHANGE = "onSinkMeetingAudioStatusChange";
  String MEETING_VIDEO_STATUS_CHANGE = "onSinkMeetingVideoStatusChange";
}
