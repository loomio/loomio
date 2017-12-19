angular.module('loomioApp').config ($compileProvider) ->
  # disable angular debug stuff in production
  $compileProvider.debugInfoEnabled(false) if window.Loomio.environment == 'production'
