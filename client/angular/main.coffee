moment = require 'moment-timezone'

AppConfig     = require 'shared/services/app_config.coffee'
RestfulClient = require 'shared/record_store/restful_client.coffee'

{ exportGlobals, checkBrowser, initServiceWorker } = require 'shared/helpers/window.coffee'

checkBrowser()
exportGlobals()
initServiceWorker()

new RestfulClient('boot').get('site').then (response) ->
  if response.ok
    response.json().then (config) ->
      _.merge AppConfig, config, timeZone: moment.tz.guess()

      require './dependencies/vendor.coffee'
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

      require './dependencies/config.coffee'
      require './dependencies/templates.coffee'
      require './dependencies/pages.coffee'
      require './dependencies/components.coffee'
  else
    console.log 'Unable to boot Loomio!', response
