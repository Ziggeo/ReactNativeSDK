import {NativeModules} from 'react-native';

const {Images} = NativeModules;

export default {

    index: async function (map) {
        return Images.index(map);
    },
    destroy: async function (tokenOrKey) {
        return Images.destroy(tokenOrKey);
    },
    get: async function (tokenOrKey: string) {
        return Images.get(tokenOrKey);
    },
    create: async function (file, map) {
        return Images.create(file, map);
    },
    update: async function (model) {
        return Images.update(model);
    },
    source: async function (tokenOrKey: string) {
        return Images.source(tokenOrKey);
    },
    getImagesUrl: async function (tokenOrKey: string) {
        return Images.getImagesUrl(tokenOrKey);
    },
};