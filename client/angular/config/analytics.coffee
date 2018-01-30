angular.module('loomioApp').config ['$analyticsProvider', ($analyticsProvider) ->
  $analyticsProvider.firstPageview(true)
  $analyticsProvider.withAutoBase(true)
]
