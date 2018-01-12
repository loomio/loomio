{ exportGlobals, checkBrowser, initServiceWorker } = require 'shared/helpers/window.coffee'

checkBrowser()
exportGlobals()
initServiceWorker()

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
