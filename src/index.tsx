import React from 'react';
import {
  NativeModules,
  requireNativeComponent,
  NativeEventEmitter,
} from 'react-native';
const { VideoZoomSdk } = NativeModules;

const NativeVideoZoomView = requireNativeComponent('RNVideoZoomView');
const NativeShareViewVideoSdk = requireNativeComponent('RNShareViewVideoSdk');
const eventEmitter = new NativeEventEmitter(VideoZoomSdk);

export const initSdk = () => {
  return new Promise((res) => {
    VideoZoomSdk.initSDK((rs: boolean) => {
      return res(rs);
    });
  });
};

export const joinMeeting = (meetingInfo: object) => {
  VideoZoomSdk.joinMeeting(meetingInfo);
};

export const leaveCurrentMeeting = () => {
  VideoZoomSdk.leaveCurrentMeeting();
};

export const onMyAudio = () => {
  VideoZoomSdk.onMyAudio();
};

export const offMyAudio = () => {
  VideoZoomSdk.offMyAudio();
};

export const onAudioZoom = () => {
  VideoZoomSdk.onMyAudio();
};

export const offAudioZoom = () => {
  VideoZoomSdk.offMyAudio();
};

export const onOffMyVideoZoom = () => {
  VideoZoomSdk.onOffMyVideo();
};
export const switchCameraZoom = () => {};

export const getParticipants = () => {
  return new Promise((res) => {
    VideoZoomSdk.getParticipants((members: any) => {
      return res({ error: false, members });
    });
  });
};

export const getUserInfo = (userID: string) => {
  return new Promise((res) => {
    VideoZoomSdk.getUserInfo(userID, (info: any) => {
      return res({ error: false, info });
    });
  });
};

export const onEventListenerZoom = (onEvent = () => {}) => {
  eventEmitter.addListener(
    'onVideoZoomMeetingEvent',
    onEvent
  );
};

export const removeListenerZoom = () => {
  eventEmitter.removeAllListeners('onVideoZoomMeetingEvent');
};
export const checkSetHostToUser = (userName: string) => {
  VideoZoomSdk.checkSetHostToUser(userName);
};

export const RNShareViewVideoSdk = (props: any) => {
  return (
    <NativeShareViewVideoSdk
      // @ts-ignore
      style={props.style}
      userID={props.userID}
    />
  );
};
const RNVideoZoomView = (props: any) => {
  return (
    <NativeVideoZoomView
      // @ts-ignore
      style={props.style}
      userID={props.userID}
    />
  );
};

export default RNVideoZoomView;
