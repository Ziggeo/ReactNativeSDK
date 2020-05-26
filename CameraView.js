import React from 'react';
import {
    NativeModules,
    requireNativeComponent,
} from 'react-native';

const CameraView = requireNativeComponent('ZiggeoCameraView');
const {Camera} = NativeModules;
export default class ZiggeoCamera extends React.Component {

    startStreaming(appToken, videoToken, streamToken) {
        Camera.startStreaming(appToken, videoToken, streamToken);
    }

    stopStreaming() {
        Camera.stopStreaming();
    }

    startRecording(path, durationMillis) {
        Camera.startRecording(path, durationMillis);
    }

    stopRecording() {
        Camera.stopRecording();
    }

    render() {
        return <CameraView
            style={{width: '100%', height: '100%'}}
        />;
    }
}
