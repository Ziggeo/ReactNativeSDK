import {NativeModules, requireNativeComponent, StyleSheet} from 'react-native';
import React from 'react';
import PropTypes from 'prop-types';
const {ZCameraModule} = NativeModules;

class ZiggeoCameraView extends React.Component {

    startRecording(path, maxDuration) {
        ZCameraModule.startRecording(path, 10000);
    }

    stopRecording() {
        ZCameraModule.stopRecording();
    }

    render() {
        return <ZCameraViewManager
            style={this.props.style}
            {...this.props}
        />;
    }
}

ZiggeoCameraView.propTypes = {
    document: PropTypes.string,
};

var ZCameraViewManager = requireNativeComponent(
    'ZCameraViewManager',
    ZiggeoCameraView,
);

module.exports = ZiggeoCameraView;
