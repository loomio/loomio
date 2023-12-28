import { createI18n } from 'vue-i18n'
import enData from '@/../../config/locales/client.en.yml';

const en = enData.en

const i18n = createI18n({
  locale: 'en',
  fallbackLocale: 'en',
  messages: {en},
  silentTranslationWarn: true
})

export default i18n;
