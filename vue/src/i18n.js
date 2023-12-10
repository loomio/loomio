import Vue from 'vue';
import VueI18n from 'vue-i18n';
import enData from '@/../../config/locales/client.en.yml';

const en = enData.en
Vue.use(VueI18n);

const i18n = new VueI18n({
  locale: 'en',
  fallbackLocale: 'en',
  messages: {en},
  silentTranslationWarn: true
});

export default i18n;
