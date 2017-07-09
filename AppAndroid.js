import React from 'react';
import { StyleSheet, Text, View, Button } from 'react-native';
import { DeviceEventEmitter, NativeModules } from 'react-native';

export default class App extends React.Component {

    componentDidMount() {
        DeviceEventEmitter.addListener('UploadProgress', function(e: Event) {
            console.log("UploadProgress: "+e.progress)
        });

        DeviceEventEmitter.addListener('Error', function(e: Event) {
            console.log("Error: "+e)
        });
    }

    componentWillUnmount() {
        DeviceEventEmitter.removeListener('UploadProgress', (message) => console.log(message));
        DeviceEventEmitter.removeListener('Error', (message) => console.log(message));
    }

    async record() {
        var appToken = "APP_TOKEN";
        var recorder = NativeModules.ZiggeoRecorder;
        recorder.setAppToken(appToken);
        recorder.setCameraSwitchEnabled(true);
        recorder.setCoverSelectorEnabled(true);
        recorder.setMaxRecordingDuration(50) // 50 seconds

        try{
             //record and upload the video and return its token
            var token = await recorder.record();
            var player = NativeModules.ZiggeoPlayer;
            player.setAppToken(appToken);
            player.play(token);
        }
        catch(e){
            //recorder error or recording was cancelled by user
           console.error(e);
        }
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
