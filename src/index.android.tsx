import React from 'react';
import {
  NativeModules,
  requireNativeComponent,
  NativeEventEmitter,
  Platform,
  View
} from 'react-native';

export const initSdk = () => {
  return new Promise((res) => {
    return res(1);
  });
};

export const joinMeeting = () => {
};

export const leaveCurrentMeeting = () => {
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
    return res({error: false, members:[]});
  });
}

export const getUserInfo = () => {
  return new Promise((res) => {
    return res({error: false, info:{}});
  });
}

export const onEventListenerZoom = () =>{
}

export const removeListenerZoom = () => {
}
export const checkSetHostToUser = () => {
}
const RNVideoZoomView = (props:any) => {
  return (
    <View
      // @ts-ignore
      style={props.style}
      userID={props.userID}
    />
  );
};

export default RNVideoZoomView;
