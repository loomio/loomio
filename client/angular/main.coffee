{ exportGlobals, hardReload, unsupportedBrowser, initServiceWorker } = require 'shared/helpers/window'

hardReload('/417.html') if unsupportedBrowser()
exportGlobals()
initServiceWorker()

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
