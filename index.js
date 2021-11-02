import {NativeEventEmitter, NativeModules} from 'react-native';
import VideosApi from './videos';
import AudiosApi from './audios';
import ImagesApi from './images';

const {ZiggeoPlayer} = NativeModules;
const {ZiggeoRecorder} = NativeModules;
import ZiggeoVideoView from './video_view.js';
import ZiggeoCameraView from './camera_view.js';

const {Videos} = NativeModules;
const {Audios} = NativeModules;
const {ContactUs} = NativeModules;

export default {
    VideosApi,
    AudiosApi,
    ImagesApi,
    // Common
    setAppToken: function (appToken: string) {
        ZiggeoPlayer.setAppToken(appToken);
        ZiggeoRecorder.setAppToken(appToken);
        Videos.setAppToken(appToken);
    },
    setClientAuthToken: function (token: string) {
        ZiggeoPlayer.setClientAuthToken(token);
        ZiggeoRecorder.setClientAuthToken(token);
        Videos.setClientAuthToken(token);
    },
    setServerAuthToken: function (token: string) {
        ZiggeoPlayer.setServerAuthToken(token);
        ZiggeoRecorder.setServerAuthToken(token);
        Videos.setServerAuthToken(token);
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
    /**
     * @deprecated Use `startCameraRecorder()` instead.
     */
    record: async function () {
        return ZiggeoRecorder.record();
    },
    startCameraRecorder: async function () {
        return ZiggeoRecorder.record();
    },
    startImageRecorder: async function () {
        return ZiggeoRecorder.startImageRecorder();
    },
    startAudioRecorder: async function () {
        return ZiggeoRecorder.startAudioRecorder();
    },
    startAudioPlayer:async function (token: string) {
        return ZiggeoRecorder.startAudioPlayer(token);
    },
    showImage:async function (token: string) {
        return ZiggeoRecorder.showImage(token);
    },
    startScreenRecorder: async function () {
        return ZiggeoRecorder.startScreenRecorder();
    },
    uploadFromPath: async function (fileName, createObject: CreateObject) {
        return ZiggeoRecorder.uploadFromPath(fileName, createObject);
    },
    uploadFromFileSelector: async function (argsMap) {
        return ZiggeoRecorder.uploadFromFileSelector(argsMap);
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
    cancelCurrentUpload: function (delete_file: boolean) {
        ZiggeoRecorder.cancelCurrentUpload(delete_file);
    },
    cancelUploadByPath: function (path: string, delete_file: boolean) {
        ZiggeoRecorder.cancelUploadByPath(path, delete_file);
    },

    // Constants
    REAR_CAMERA: ZiggeoRecorder.rearCamera,
    FRONT_CAMERA: ZiggeoRecorder.frontCamera,
    HIGH_QUALITY: ZiggeoRecorder.highQuality,
    MEDIUM_QUALITY: ZiggeoRecorder.mediumQuality,
    LOW_QUALITY: ZiggeoRecorder.lowQuality,

    MEDIA_TYPE_VIDEO: ZiggeoRecorder.video,
    MEDIA_TYPE_AUDIO: ZiggeoRecorder.audio,
    MEDIA_TYPE_IMAGE: ZiggeoRecorder.image,
};
