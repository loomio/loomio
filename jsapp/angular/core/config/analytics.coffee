angular.module('loomioApp').config ($analyticsProvider) ->
  $analyticsProvider.firstPageview(true)
  $analyticsProvider.withAutoBase(true)
