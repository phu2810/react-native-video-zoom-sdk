import React from 'react';
import { AppState, NativeModules, requireNativeComponent, NativeEventEmitter } from 'react-native';
const { VideoZoomSdk } = NativeModules;

const NativeVideoZoomView = requireNativeComponent('RNVideoZoomView');
const eventEmitter = new NativeEventEmitter(VideoZoomSdk);
let addListenEvent = false;
let subscriptionEvent;

const handleAppStateChange = (nextAppState) => {
  VideoZoomSdk.appStateChange(nextAppState);
};

export const initSdk = () => {
  return new Promise((res) => {
    if (!addListenEvent) {
      addListenEvent = true;
      AppState.addEventListener("change", handleAppStateChange);
    }
    VideoZoomSdk.initSDK((rs) => {
      return res(rs);
    });
  });
};

export const joinMeeting = (meetingInfo) => {
  VideoZoomSdk.joinMeeting(meetingInfo);
};

export const leaveCurrentMeeting = () => {
  VideoZoomSdk.leaveCurrentMeeting();
};

export const onMyAudio = () => {
};

export const offMyAudio = () => {
};

export const onAudioZoom = () => {
};

export const offAudioZoom = () => {
};

export const onOffMyVideoZoom = () => {
};
export const switchCameraZoom = () => {
};

export const getParticipants = () => {
  return new Promise((res) => {
    VideoZoomSdk.getParticipants((rs) => {
      return res(rs);
    });
  });
}

export const getUserInfoZoom = (userId) => {
}

export const onEventListenerZoom = (onEvent = () => {}) =>{
  subscriptionEvent = eventEmitter.addListener(
    'onMeetingEvent',
    onEvent,
  );
}

export const removeListenerZoom = () => {
  subscriptionEvent.remove();
}

const RNVideoZoomView = (props) => {
  return (
    <NativeVideoZoomView
      style={props.style}
      userID={props.userID}
    />
  );
};

export default RNVideoZoomView;
