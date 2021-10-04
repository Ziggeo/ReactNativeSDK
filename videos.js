import { NativeModules, NativeEventEmitter, requireNativeComponent } from 'react-native';

const { Videos } = NativeModules;

export default {

	index: async function (map) {
		return Videos.index(map);
	},
	create: async function (file: string, map) {
		return Videos.create(file, map);
	},
	get: async function (tokenOrKey: string) {
		return Videos.get(tokenOrKey);
	},
	getVideoUrl: async function (tokenOrKey: string) {
		return Videos.getVideoUrl(tokenOrKey);
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
