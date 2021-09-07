import {NativeModules, requireNativeComponent, StyleSheet} from 'react-native';
import React from 'react';
import PropTypes from 'prop-types';
const {ZVideoViewModule} = NativeModules;

class ZiggeoVideoView extends React.Component {

    startPlaying() {
        ZVideoViewModule.startPlaying();
    }

    render() {
        return <ZVideoViewManager
            style={this.props.style}
            {...this.props}
        />;
    }
}

ZiggeoVideoView.propTypes = {
    document: PropTypes.string,
};

var ZVideoViewManager = requireNativeComponent(
    'ZVideoViewManager',
    ZiggeoVideoView,
);

module.exports = ZiggeoVideoView;
