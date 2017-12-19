angular.module('loomioApp').config ($animateProvider) ->
  # this should make stuff faster but you need to add "animated" class to animated things.
  # http://www.bennadel.com/blog/2935-enable-animations-explicitly-for-a-performance-boost-in-angularjs.htm
  if window.Loomio.environment == 'test'
    $animateProvider.classNameFilter(/no-elements-shall-animate-on-test/)
  else
    $animateProvider.classNameFilter(/animated/)
