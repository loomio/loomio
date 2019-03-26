AppConfig = require 'shared/services/app_config'

angular.module('loomioApp').config ['$animateProvider', ($animateProvider) ->
  # this should make stuff faster but you need to add "animated" class to animated things.
  # http://www.bennadel.com/blog/2935-enable-animations-explicitly-for-a-performance-boost-in-angularjs.htm
  if AppConfig.environment == 'test'
    $animateProvider.classNameFilter(/no-elements-shall-animate-on-test/)
  else
    $animateProvider.classNameFilter(/animated/)
]
