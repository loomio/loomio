angular.module('loomioApp').config ($mdThemingProvider) ->
  $mdThemingProvider.theme('default')
    .primaryPalette('orange', {'default': '400'})
    .accentPalette('cyan', {default: '500'});
