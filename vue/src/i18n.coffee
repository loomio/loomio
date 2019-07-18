import Vue from 'vue'
import VueI18n from 'vue-i18n'
import { en } from '@/../../config/locales/client.en.yml'

Vue.use(VueI18n)

i18n = new VueI18n
  locale: 'en'
  fallbackLocale: 'en'
  messages: {en: en}
  silentTranslationWarn: true

Vue.prototype.$lt = (value) ->
  if (typeof value == 'string')
    @$t(value)
  else
    path = value.path
    locale = value.locale
    args = value.args
    choice = value.choice
    @$t(path, args)

export default i18n
