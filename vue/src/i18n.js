import Vue from 'vue';
import VueI18n from 'vue-i18n';
import { en } from '@/../../config/locales/client.en.yml';

Vue.use(VueI18n);

const i18n = new VueI18n({
  locale: 'en',
  fallbackLocale: 'en',
  messages: {en},
  silentTranslationWarn: true
});

Vue.prototype.$lt = function(value) {
  if (typeof value === 'string') {
    return this.$t(value);
  } else {
    const {
      path
    } = value;
    const {
      locale
    } = value;
    const {
      args
    } = value;
    const {
      choice
    } = value;
    return this.$t(path, args);
  }
};

export default i18n;
