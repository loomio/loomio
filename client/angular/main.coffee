moment = require 'moment-timezone'

AppConfig = require 'shared/services/app_config'

{ exportGlobals, hardReload, unsupportedBrowser, initServiceWorker } = require 'shared/helpers/window'
{ bootDat } = require 'shared/helpers/boot'

hardReload('/417.html') if unsupportedBrowser()
exportGlobals()
initServiceWorker()

bootDat (appConfig) ->
  _.merge AppConfig, _.merge appConfig,
    timeZone: moment.tz.guess()
    pendingIdentity: appConfig.userPayload.pendingIdentity
  window.Loomio = AppConfig

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
