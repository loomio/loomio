import Vue from 'vue'
import VueI18n from 'vue-i18n'

Vue.use(VueI18n)

Vue.prototype.$lt = (value) ->
  if (typeof value == 'string')
    @$t(value)
  else
    path = value.path
    locale = value.locale
    args = value.args
    choice = value.choice
    @$t(path, args)


export default new VueI18n({locale: 'en', fallbackLocale: 'en'})
