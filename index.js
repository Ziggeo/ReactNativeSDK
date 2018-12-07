import { NativeModules, NativeEventEmitter } from 'react-native';

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
  	/**
 	  * @deprecated Use `setExtraArgsForRecorder` instead.
 	  */
	setExtraArgsForCreateVideo: function (map) {
		console.warn("Calling deprecated function!");
		ZiggeoRecorder.setExtraArgsForCreateVideo(map);
  	},
	setExtraArgsForRecorder: function (map) {
		ZiggeoRecorder.setExtraArgsForRecorder(map);
  	},
  	setThemeArgsForRecorder: function (map) {
  		ZiggeoRecorder.setThemeArgsForRecorder(map);
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
	setQuality: function (quality) {
		ZiggeoRecorder.setQuality(quality);
  	},
	setCamera: function (camera) {
		ZiggeoRecorder.setCamera(camera);
  	},
	record: async function () {
		return ZiggeoRecorder.record();
  	},
	uploadFromFileSelector: async function (map) {
		return ZiggeoRecorder.uploadFromFileSelector(map);
	},
	uploadFromPath: async function (fileName, createObject: CreateObject) {
		return ZiggeoRecorder.uploadFromPath(fileName, createObject);
	},
	/**
 	  * @deprecated Use `uploadFromFileSelector(map)` instead.
 	  */
	uploadFromFileSelectorWithDurationLimit: async function (maxAllowedDurationInSeconds, enforceDuration) {
		console.warn("Calling deprecated function!");
		var argsMap = {"max_duration":maxAllowedDurationInSeconds,"enforce_duration":enforceDuration}
		return ZiggeoRecorder.uploadFromFileSelector(argsMap);
	},
	cancelRequest: function () {
		ZiggeoRecorder.cancelRequest();
  	},
	recorderEmitter: function() {
		return recorderEmitter = new NativeEventEmitter(ZiggeoRecorder);
	},

  	// ZiggeoPlayer
  	play: function (videoId: string) {
		ZiggeoPlayer.play(videoId);
  	},
	setExtraArgsForPlayer: function (map) {
		ZiggeoPlayer.setExtraArgsForPlayer(map);
  	},
  	setThemeArgsForPlayer: function (map) {
  		ZiggeoPlayer.setThemeArgsForPlayer(map);
  	},

  	// Constants
  	REAR_CAMERA: ZiggeoRecorder.rearCamera,
  	FRONT_CAMERA: ZiggeoRecorder.frontCamera,
  	HIGH_QUALITY: ZiggeoRecorder.highQuality,
  	MEDIUM_QUALITY: ZiggeoRecorder.mediumQuality,
  	LOW_QUALITY: ZiggeoRecorder.lowQuality

 };
