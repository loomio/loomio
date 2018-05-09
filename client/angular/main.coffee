moment = require 'moment-timezone'

AppConfig     = require 'shared/services/app_config'
RestfulClient = require 'shared/record_store/restful_client'

{ exportGlobals, hardReload, unsupportedBrowser, initServiceWorker } = require 'shared/helpers/window'

hardReload('/417.html') if unsupportedBrowser()
exportGlobals()
initServiceWorker()

new RestfulClient('boot').get('site').then (response) ->
  if response.ok
    response.json().then (config) ->
      _.merge AppConfig, config, timeZone: moment.tz.guess()

      require './dependencies/vendor'
      angular.module('loomioApp', [
        'ngNewRouter',
        'pascalprecht.translate',
        'ngSanitize',
        'hc.marked',
        'mentio',
        'ngAnimate',
        'angular-inview',
        'ui.gravatar',
        'duScroll',
        'angular-clipboard',
        'ngMaterial',
        'angulartics',
        'angulartics.google.tagmanager',
        'vcRecaptcha',
        'angular-sortable-view'
        ])

      require './dependencies/config'
      require './dependencies/templates'
      require './dependencies/pages'
      require './dependencies/components'
      window.Loomio = AppConfig
  else
    console.log 'Unable to boot Loomio!', response
