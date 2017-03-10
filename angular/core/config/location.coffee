  # enable html5 pushstate mode
angular.module('loomioApp').config ($locationProvider) ->
  $locationProvider.html5Mode(true)
