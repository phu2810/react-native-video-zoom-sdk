import { NativeModules } from 'react-native';

type VideoZoomSdkType = {
  multiply(a: number, b: number): Promise<number>;
};

const { VideoZoomSdk } = NativeModules;

export default VideoZoomSdk as VideoZoomSdkType;
