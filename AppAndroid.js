import React from 'react';
import { StyleSheet, Text, View, Button } from 'react-native';
import { NativeEventEmitter, NativeModules } from 'react-native';

export default class App extends React.Component {
    async record() {
        var appToken = "ZIGGEO_APP_TOKEN";
        var ziggeo = NativeModules.ZiggeoAndroid;
        ziggeo.setAppToken(appToken);
        ziggeo.setMaxRecordingDuration(50) // 50 seconds
        ziggeo.setCameraSwitchEnabled(true);
        ziggeo.setCoverSelectorEnabled(true);

        ziggeo.setVideoRecordingProcessCallback(
        () => {
            console.log("started");
        },
        (s) => {
            console.log("stopped:"+s);
        },
        () => {
            console.log("error");
        })

        ziggeo.setNetworkRequestsCallback(
            (progress) => {
                console.log("progress:"+progress)
            },
            (response) => {
                console.log("success:"+response)
            },
            (url, error) => {
                console.log("error:"+error+" url:"+url)
            })

        ziggeo.startRecorder();
    }
    
    
    render() {
        return (
          <View style={styles.container}>
            <Button
            onPress={this.record}
            title="Record"
            accessibilityLabel="Record"
            />
            </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
