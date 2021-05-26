import React from 'react';
import {
  NativeModules,
  requireNativeComponent,
  NativeEventEmitter
} from 'react-native';
const { VideoZoomSdk } = NativeModules;

const NativeVideoZoomView = requireNativeComponent('RNVideoZoomView');
const eventEmitter = new NativeEventEmitter(VideoZoomSdk);
let subscriptionEvent:any;

export const initSdk = () => {
  return new Promise((res) => {
    VideoZoomSdk.initSDK((rs:boolean) => {
      return res(rs);
    });
  });
};

export const joinMeeting = (meetingInfo:object) => {
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
    VideoZoomSdk.getParticipants((members: any) => {
      return res({error: false, members});
    });
  });
}

export const getUserInfo = (userID:string) => {
  return new Promise((res) => {
    VideoZoomSdk.getUserInfo(userID, (info:any) => {
      return res({error: false, info});
    });
  });
}

export const onEventListenerZoom = (onEvent = () => {}) =>{
  subscriptionEvent = eventEmitter.addListener(
    'onVideoZoomMeetingEvent',
    onEvent,
  );
}

export const removeListenerZoom = () => {
  subscriptionEvent.removeAllListeners('onVideoZoomMeetingEvent');
}
export const checkSetHostToUser = (userName:string) => {
  VideoZoomSdk.checkSetHostToUser(userName);
}
const RNVideoZoomView = (props:any) => {
  return (
    <NativeVideoZoomView
      // @ts-ignore
      style={props.style}
      userID={props.userID}
    />
  );
};

export default RNVideoZoomView;
