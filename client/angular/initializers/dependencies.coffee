require 'angular-animate'
require 'angular-aria'
require 'angular-clipboard'
require 'angular-gravatar'
require 'angular-inview'
require 'angular-material'
require 'angular-recaptcha'
require 'angular-sanitize'
require 'angular-scroll'
require 'angular-translate'
require 'angular-translate-loader-url'
require 'angulartics'
require 'angulartics-google-tag-manager'
require 'angular-sortable-view'
require 'loomio-angular-router'
require 'loomio-angular-marked'
require 'marked'
require 'ment.io'
require 'private_pub'

angular.module('loomioApp', [
  'ngNewRouter',
  'pascalprecht.translate',
  'ngSanitize',
  'ngFileUpload',
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
  'ngAnimate',
  'angular-sortable-view'
])
