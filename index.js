import { NativeModules } from 'react-native';

const { ZiggeoPlayer } = NativeModules;
const { ZiggeoRecorder } = NativeModules;

export default {
	// ZiggeoRecorder
	setAppToken: function (appToken: string) {
		ZiggeoPlayer.setAppToken(appToken);
		ZiggeoRecorder.setAppToken(appToken);
  	},
	setAutostartRecordingAfter: function (seconds) {
		ZiggeoRecorder.setAutostartRecordingAfter(seconds);
  	},
	setExtraArgsForCreateVideo: function (map) {
		ZiggeoRecorder.setExtraArgsForCreateVideo(map);
  	},
	setCoverSelectorEnabled: function (enabled) {
		ZiggeoRecorder.setCoverSelectorEnabled(enabled);
  	},
	setMaxRecordingDuration: function (seconds) {
		ZiggeoRecorder.setMaxRecordingDuration(seconds);
  	},
	setCameraSwitchEnabled: function (enabled) {
		ZiggeoRecorder.setCameraSwitchEnabled(enabled);
  	},
	setSendImmediately: function (sendImmediately) {
		ZiggeoRecorder.setSendImmediately(sendImmediately);
  	},
	setCamera: function (camera) {
		ZiggeoRecorder.setCamera(camera);
  	},
	record: function () {
		ZiggeoRecorder.record();
  	},
	cancelRequest: function () {
		ZiggeoRecorder.cancelRequest();
  	},

  	// ZiggeoPlayer
  	play: function (videoId: string) {
		ZiggeoPlayer.play(videoId);
  	},

  	// Constants
  	REAR_CAMERA: ZiggeoRecorder.rearCamera,
  	FRONT_CAMERA: ZiggeoRecorder.frontCamera
 };