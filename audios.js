import {NativeModules} from 'react-native';

const {Audios} = NativeModules;

export default {

    index: async function (map) {
        return Audios.index(map);
    },
    destroy: async function (tokenOrKey) {
        return Audios.destroy(tokenOrKey);
    },
    get: async function (tokenOrKey: string) {
        return Audios.get(tokenOrKey);
    },
    create: async function (file, map) {
        return Audios.create(file, map);
    },
    update: async function (model) {
        return Audios.update(model);
    },
    source: async function (tokenOrKey: string) {
        return Audios.source(tokenOrKey);
    },
    getAudioUrl: async function (tokenOrKey: string) {
        return Audios.getAudioUrl(tokenOrKey);
    },

};