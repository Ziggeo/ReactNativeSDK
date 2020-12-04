import { NativeModules, NativeEventEmitter, requireNativeComponent } from 'react-native';

const { Videos } = NativeModules;

export default {

	index: async function (map) {
		return Videos.index(map);
	},
	getImageUrl: async function (tokenOrKey: string) {
		return Videos.getImageUrl(tokenOrKey);
	},
	destroy: async function (tokenOrKey) {
		return Videos.destroy(tokenOrKey);
	},
	update: async function (tokenOrKey, model) {
		return Videos.update(tokenOrKey, model);
	},

 };
