window.VueI18n = require('vue-i18n')
window.Vue     = require('vue')
Vue.use(VueI18n)

window.i18n = new VueI18n(
  locale: 'en',
  fallbackLocale: 'en',
  messages:
    en:
      test: "hello bonjour"
)

fetch('/api/v1/translations?lang=en').then (res)->
  res.json().then (data) ->
    i18n.setLocaleMessage('en', data)
    
# vue = new Vue(
#   el: '#app',
#   components:
#     TimeAgo:       require('vue/components/time_ago/time_ago.coffee')
#     ThreadPreview: require('vue/components/thread_preview/thread_preview.coffee')
#   i18n: i18n
# )

angular.module('loomioApp').value('TimeAgo', require 'vue/components/time_ago/time_ago.coffee')
angular.module('loomioApp').value('ThreadPreview', require 'vue/components/thread_preview/thread_preview.coffee')
angular.module('loomioApp').config ['$ngVueProvider', ($ngVueProvider) ->
  $ngVueProvider.setRootVueInstanceProps({
    i18n: i18n
  })
]
