import { NativeModules, NativeEventEmitter, requireNativeComponent } from 'react-native';

const { Videos } = NativeModules;

export default {

	index: async function (map) {
		return Videos.index(map);
	},

 };
