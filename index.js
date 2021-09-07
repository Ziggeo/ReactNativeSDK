import {NativeModules, NativeEventEmitter, requireNativeComponent} from 'react-native';
import VideosApi from './videos';

const {ZiggeoPlayer} = NativeModules;
const {ZiggeoRecorder} = NativeModules;
const {ZiggeoAudio} = NativeModules;
const {ZiggeoImage} = NativeModules;
import ZiggeoVideoView from './video_view.js';
import ZiggeoCameraView from './camera_view.js';
const {Videos} = NativeModules;
const {ContactUs} = NativeModules;

export default {
    VideosApi,
    // Common
    setAppToken: function (appToken: string) {
        ZiggeoPlayer.setAppToken(appToken);
        ZiggeoRecorder.setAppToken(appToken);
        Videos.setAppToken(appToken);
        ZiggeoImage.setAppToken(appToken);
        ZiggeoAudio.setAppToken(appToken);
    },
    setClientAuthToken: function (token: string) {
        ZiggeoPlayer.setClientAuthToken(token);
        ZiggeoRecorder.setClientAuthToken(token);
        Videos.setClientAuthToken(token);
        ZiggeoImage.setClientAuthToken(token);
        ZiggeoAudio.setClientAuthToken(token);
    },
    setServerAuthToken: function (token: string) {
        ZiggeoPlayer.setServerAuthToken(token);
        ZiggeoRecorder.setServerAuthToken(token);
        Videos.setServerAuthToken(token);
        ZiggeoImage.setServerAuthToken(token);
        ZiggeoAudio.setServerAuthToken(token);
    },
    sendReport(logsList) {
        ContactUs.sendReport(logsList);
    },
    sendEmailToSupport() {
        ContactUs.sendEmailToSupport();
    },

    // ZiggeoRecorder
    setRecorderCacheConfig: function (map) {
        ZiggeoRecorder.setRecorderCacheConfig(map);
    },
    setRecorderInterfaceConfig: function (map) {
        ZiggeoRecorder.setRecorderInterfaceConfig(map);
    },
    setUploadingConfig: function (map) {
        ZiggeoRecorder.setUploadingConfig(map);
    },
    setLiveStreamingEnabled: function (enabled) {
        ZiggeoRecorder.setLiveStreamingEnabled(enabled);
    },
    setAutostartRecordingAfter: function (seconds) {
        ZiggeoRecorder.setAutostartRecordingAfter(seconds);
    },
    setStartDelay: function (seconds) {
        ZiggeoRecorder.setStartDelay(seconds);
    },
    /**
     * @deprecated Use `setExtraArgsForRecorder` instead.
     */
    setExtraArgsForCreateVideo: function (map) {
        console.warn('Calling deprecated function!');
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
    setVideoWidth: function (videoWidth) {
        ZiggeoRecorder.setVideoWidth(videoWidth);
    },
    setVideoHeight: function (videoHeight) {
        ZiggeoRecorder.setVideoHeight(videoHeight);
    },
    setVideoBitrate: function (videoBitrate) {
        ZiggeoRecorder.setVideoBitrate(videoBitrate);
    },
    setAudioSampleRate: function (audioSampleRate) {
        ZiggeoRecorder.setAudioSampleRate(audioSampleRate);
    },
    setAudioBitrate: function (audioBitrate) {
        ZiggeoRecorder.setAudioBitrate(audioBitrate);
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
    chooseVideo: async function (map) {
        return ZiggeoRecorder.chooseVideo(map);
    },
    startScreenRecorder: async function () {
        return ZiggeoRecorder.startScreenRecorder();
    },
    uploadFromPath: async function (fileName, createObject: CreateObject) {
        return ZiggeoRecorder.uploadFromPath(fileName, createObject);
    },
    /**
     * @deprecated Use `uploadFromFileSelector(map)` instead.
     */
    uploadFromFileSelectorWithDurationLimit: async function (maxAllowedDurationInSeconds, enforceDuration) {
        console.warn('Calling deprecated function!');
        var argsMap = {'max_duration': maxAllowedDurationInSeconds, 'enforce_duration': enforceDuration};
        return ZiggeoRecorder.uploadFromFileSelector(argsMap);
    },
    cancelRequest: function () {
        ZiggeoRecorder.cancelRequest();
    },
    startQrScanner: function (data) {
        ZiggeoRecorder.startQrScanner(data);
    },
    recorderEmitter: function () {
        return new NativeEventEmitter(ZiggeoRecorder);
    },
    cameraViewEmitter: function () {
        return new NativeEventEmitter(ZiggeoCameraView);
    },
    videoViewEmitter: function () {
        return new NativeEventEmitter(ZiggeoVideoView);
    },

    // Video Player
    playVideo: function (videoId: string) {
        ZiggeoPlayer.playVideo(videoId);
    },
    playFromUri: function (path_or_url: string) {
        ZiggeoPlayer.playFromUri(path_or_url);
    },
    setExtraArgsForPlayer: function (map) {
        ZiggeoPlayer.setExtraArgsForPlayer(map);
    },
    setThemeArgsForPlayer: function (map) {
        ZiggeoPlayer.setThemeArgsForPlayer(map);
    },
    setPlayerCacheConfig: function (map) {
        ZiggeoPlayer.setPlayerCacheConfig(map);
    },
    setAdsURL: function (url) {
        ZiggeoPlayer.setAdsURL(url);
    },
    downloadVideo: async function (videoToken: string) {
        ZiggeoPlayer.downloadVideo(videoToken);
    },

    // Audio
    recordAudio: async function () {
        return ZiggeoAudio.recordAudio();
    },
    playAudio: async function (audioToken: string) {
        return ZiggeoAudio.playAudio(audioToken);
    },
    downloadAudio: async function (audioToken: string) {
        return ZiggeoAudio.downloadAudio(audioToken);
    },

    // Image
    takePhoto: async function (map) {
        return ZiggeoImage.takePhoto(map);
    },
    chooseImage: async function (map) {
        return ZiggeoImage.chooseImage(map);
    },
    downloadImage: async function (imageToken) {
        return ZiggeoImage.downloadImage(imageToken);
    },

    // Constants
    REAR_CAMERA: ZiggeoRecorder.rearCamera,
    FRONT_CAMERA: ZiggeoRecorder.frontCamera,
    HIGH_QUALITY: ZiggeoRecorder.highQuality,
    MEDIUM_QUALITY: ZiggeoRecorder.mediumQuality,
    LOW_QUALITY: ZiggeoRecorder.lowQuality,

};
